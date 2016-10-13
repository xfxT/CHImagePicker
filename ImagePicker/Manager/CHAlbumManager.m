//
//  CHAlbumManager.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHAlbumManager.h"
#import "CHAsset.h"
#import "CHAlbum.h"
#import "CHImage.h"
#import "UIImage+CHAddition.h"
#import <objc/runtime.h>

static const char CHAlbumManagerSaveImageCompletionHandleKey;

@interface CHAlbumManager () 
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation CHAlbumManager

/**
 *  创建相册管理类单例
 *
 *  @return 相册管理类单例
 */
+ (instancetype)defaultManager {
    
    static CHAlbumManager *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

/**
 *  获取相机胶卷的数据模型
 *
 *  @param captureHandle 获取相机胶卷的数据模型回调
 */
- (void)cameraRollAlbumModelWithCaptureHandle:(CHAlbumManagerCameraRollAlbumCaptureHandle)captureHandle {
    if (captureHandle == nil) {
        return ;
    }
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) { // photo kit
        // 获取相册
        PHFetchResult *smartAndRegularAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        // 排序
        // creationDate
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
        fetchOptions.sortDescriptors = sortDescriptors;
        for (PHAssetCollection *assetCollection in smartAndRegularAlbums) {
            // 过滤掉PHCollectionList对象 ， PHCollectionList表示一组PHCollection，本身也是一个PHCollection
            // 一个PHAsset可以同时属于不同的PHAssetCollection，例如刚刚拍摄的照片，可以至少同时属于最近添加、相机胶卷、照片-精选三个PHAssetCollection(表示一个相册或者一个时刻，或者是一个智能相册)
            // PHCollection 抽象做为抽象基类
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                // 判断是不是Camera Roll
                BOOL isCameraRoll = NO;
                NSString *systemVersion = [UIDevice currentDevice].systemVersion;
                if ([systemVersion isEqualToString:@"8.0.0"] || [systemVersion isEqualToString:@"8.0.1"] || [systemVersion isEqualToString:@"8.0.2"]) {
                    isCameraRoll = [assetCollection.localizedTitle isEqualToString:@"最近添加"] || [assetCollection.localizedTitle isEqualToString:@"Recently Added"];
                } else {
                    isCameraRoll = [assetCollection.localizedTitle isEqualToString:@"Camera Roll"] || [assetCollection.localizedTitle isEqualToString:@"相机胶卷"] || [assetCollection.localizedTitle isEqualToString:@"所有照片"] || [assetCollection.localizedTitle isEqualToString:@"All Photos"];
                }
                if (isCameraRoll) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                    
                    CHAlbum *albumModel = [[CHAlbum alloc] init];
                    albumModel.fetchResult = result;
                    albumModel.albumName = assetCollection.localizedTitle;
                    albumModel.totalAssetModelsCount = result.count;
                    if (captureHandle) {
                        captureHandle(self, albumModel);
                    }
                    break ;
                }
            }
        }
    } else {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if (group.numberOfAssets > 0) {
                    NSString *groupPropertyName = [group valueForProperty:ALAssetsGroupPropertyName];
                    BOOL isCameraRoll = NO;
                    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
                    if ([systemVersion isEqualToString:@"8.0.0"] || [systemVersion isEqualToString:@"8.0.1"] || [systemVersion isEqualToString:@"8.0.2"]) {
                        isCameraRoll = [groupPropertyName isEqualToString:@"最近添加"] || [groupPropertyName isEqualToString:@"Recently Added"];
                    } else {
                        isCameraRoll = [groupPropertyName isEqualToString:@"Camera Roll"] || [groupPropertyName isEqualToString:@"相机胶卷"] || [groupPropertyName isEqualToString:@"所有照片"] || [groupPropertyName isEqualToString:@"All Photos"];
                    }
                    if (isCameraRoll) {
                        CHAlbum *albumModel = [[CHAlbum alloc] init];
                        albumModel.fetchResult = group;
                        albumModel.totalAssetModelsCount = group.numberOfAssets;
                        albumModel.albumName = groupPropertyName;
                        if (captureHandle) {
                            captureHandle(self, albumModel);
                        }
                        *stop = YES;
                    }
                }
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

/**
 *  获取所有相册的数据模型数组
 *
 *  @param captureHandle 获取所有相册的数据模型数组回调
 */
- (void)allAlbumModelsWithCaptureHandle:(CHAlbumManagerAllAlbumModelsCaptureHandle)captureHandle {
    if (captureHandle == nil) {
        return ;
    }
    NSMutableArray *albumsArray = [NSMutableArray new];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) { // photo kit
        // 获取相册
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        
        // 排序
        // creationDate
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
        fetchOptions.sortDescriptors = sortDescriptors;
        PHFetchResult *smartAndRegularAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // smartAndRegularAlbums/相册数组
        for (PHAssetCollection *assetCollection in smartAndRegularAlbums) {
            // 获取单个相册
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                // 某个相册中的图片
                if (fetchResult.count > 0) {
                    if (![assetCollection.localizedTitle isEqualToString:@"Deleted"] && ![assetCollection.localizedTitle isEqualToString:@"最近删除"]) {
                        // Camera Roll 在最前面
                        CHAlbum *albumModel = [[CHAlbum alloc] init];
                        albumModel.albumName = assetCollection.localizedTitle;
                        albumModel.totalAssetModelsCount = fetchResult.count;
                        albumModel.fetchResult = fetchResult;
                        BOOL isCameraRoll = NO;
                        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
                        if ([systemVersion isEqualToString:@"8.0.0"] || [systemVersion isEqualToString:@"8.0.1"] || [systemVersion isEqualToString:@"8.0.2"]) {
                            isCameraRoll = [assetCollection.localizedTitle isEqualToString:@"最近添加"] || [assetCollection.localizedTitle isEqualToString:@"Recently Added"];
                        } else {
                            isCameraRoll = [assetCollection.localizedTitle isEqualToString:@"Camera Roll"] || [assetCollection.localizedTitle isEqualToString:@"相机胶卷"] || [assetCollection.localizedTitle isEqualToString:@"所有照片"] || [assetCollection.localizedTitle isEqualToString:@"All Photos"];
                        }
                        if (isCameraRoll) {
                            [albumsArray insertObject:albumModel atIndex:0];
                        } else {
                            [albumsArray addObject:albumModel];
                        }
                    }
                }
            }
        }
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        // topLevelUserCollections/相册数组
        for (PHAssetCollection *assetCollection in topLevelUserCollections) {
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                if (fetchResult.count > 0) {
                    CHAlbum *albumModel = [[CHAlbum alloc] init];
                    albumModel.fetchResult = fetchResult;
                    albumModel.totalAssetModelsCount = fetchResult.count;
                    albumModel.albumName = assetCollection.localizedTitle;
                    [albumsArray addObject:albumModel];
                }
            }
        }
        
        if (captureHandle) {
            captureHandle(self, albumsArray);
        }
        
    } else { // < 8.0
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if (group.numberOfAssets > 0) {
                    CHAlbum *albumModel = [[CHAlbum alloc] init];
                    albumModel.fetchResult = group;
                    albumModel.totalAssetModelsCount = group.numberOfAssets;
                    NSString *groupPropertyName = [group valueForProperty:ALAssetsGroupPropertyName];
                    albumModel.albumName = groupPropertyName;
                    BOOL isCameraRoll = NO;
                    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
                    if ([systemVersion isEqualToString:@"8.0.0"] || [systemVersion isEqualToString:@"8.0.1"] || [systemVersion isEqualToString:@"8.0.2"]) {
                        isCameraRoll = [groupPropertyName isEqualToString:@"最近添加"] || [groupPropertyName isEqualToString:@"Recently Added"];
                    } else {
                        isCameraRoll = [groupPropertyName isEqualToString:@"Camera Roll"] || [groupPropertyName isEqualToString:@"相机胶卷"] || [groupPropertyName isEqualToString:@"所有照片"] || [groupPropertyName isEqualToString:@"All Photos"];
                    }
                    if (isCameraRoll) {
                        [albumsArray insertObject:albumModel atIndex:0];
                    } else if ([groupPropertyName isEqualToString:@"My Photo Stream"] || [groupPropertyName isEqualToString:@"我的照片流"]) {
                        if (albumModel.totalAssetModelsCount > 0) {
                            [albumsArray insertObject:albumModel atIndex:1];
                        } else {
                            [albumsArray addObject:albumModel];
                        }
                    } else {
                        [albumsArray addObject:albumModel];
                    }
                }
            } else {
                if (captureHandle) {
                    captureHandle(self, albumsArray);
                }
                
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"assetsLibrary : %@", error);
        }];
    }
    
}

/**
 *  获取单个相册的所有相片数据模型数组
 *
 *  @param albumModel    单个相册的数据模型
 *  @param captureHandle 获取单个相册的所有相片数据模型数组回调
 */
- (void)allAssetModelsWithAlbumModel:(CHAlbum *)albumModel captureHandle:(CHAlbumManagerAllAssetModelsCaptureHandle)captureHandle {
    if (albumModel == nil || captureHandle == nil) {
        return ;
    }
    id result = albumModel.fetchResult;
    NSMutableArray *assetModelArray = [NSMutableArray new];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        for (PHAsset *asset in fetchResult) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                CHAsset *assetModel = [[CHAsset alloc] init];
                assetModel.asset = asset;
                [assetModelArray addObject:assetModel];
            }
        }
        if (captureHandle) {
            captureHandle(self, assetModelArray);
        }
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *assetsGroup = (ALAssetsGroup *)result;
        [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
        
        [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                CHAsset *assetModel = [[CHAsset alloc] init];
                assetModel.asset = result;
                [assetModelArray addObject:assetModel];
            } else {
                if (captureHandle) {
                    captureHandle(self, assetModelArray);
                }
            }
        }];
    }
}

/**
 *  获取单个相片的相片信息模型
 *
 *  @param assetModel    单个相片的相片数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle  获取单个相片的相片信息模型回调
 */
- (void)imageWithAssetModel:(CHAsset *)assetModel imageWidth:(CGFloat)imageWidth captureHandle:(CHAlbumManagerSingleImageInfoCaptureHandle)captureHandle {
    if (assetModel == nil || captureHandle == nil) {
        return ;
    }
    id asset = assetModel.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (imageWidth < [UIScreen mainScreen].bounds.size.width && imageWidth < 600) {
            NSInteger columnNumber = 4;
            CGFloat margin = 4;
            CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - 2 * margin - 4) / columnNumber - margin;
            imageSize = CGSizeMake(itemWH * 2.0, itemWH * 2.0);
        } else {
            PHAsset *as = (PHAsset *)asset;
            CGFloat aspectRatio = as.pixelWidth / (CGFloat)as.pixelHeight;
            CGFloat pixelW = imageWidth * 2.0;
            CGFloat pixelH = pixelW / aspectRatio;
            imageSize = CGSizeMake(pixelW, pixelH);
        }
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            if ([[info objectForKey:PHImageCancelledKey] boolValue] == NO && [info objectForKey:PHImageErrorKey] == nil && image) {
                image = image.fixedOrientationImage;
                if (captureHandle) {
                    CHImage *chImage = [[CHImage alloc] init];
                    chImage.image = image;
                    chImage.imageInfo = info;
                    captureHandle(self, chImage);
                }
            }
            if ([info objectForKey:PHImageResultIsInCloudKey] && !image) {
                options.networkAccessAllowed = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *image = [UIImage imageWithData:imageData scale:0.1];
                    image = [image newImageWithTargetSize:imageSize];
                    if (image) {
                        image = image.fixedOrientationImage;
                        if (captureHandle) {
                            CHImage *chImage = [[CHImage alloc] init];
                            chImage.image = image;
                            chImage.imageInfo = info;
                            captureHandle(self, chImage);
                        }
                    }
                }];
            }
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *as = (ALAsset *)asset;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGImageRef thumbnailImageRef = as.thumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (captureHandle) {
                    CHImage *chImage = [[CHImage alloc] init];
                    chImage.image = thumbnailImage;
                    captureHandle(self, chImage);
                }
            });
        });
    }
}

/**
 *  获取单个相片的原图信息模型
 *
 *  @param assetModel    单个相片的相片数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle  获取单个相片的原图信息模型回调
 */
- (void)originalImageWithAssetModel:(CHAsset *)assetModel captureHandle:(CHAlbumManagerSingleImageInfoCaptureHandle)captureHandle {
    id asset = assetModel.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            if ([[info objectForKey:PHImageCancelledKey] boolValue] == NO && [info objectForKey:PHImageErrorKey] == nil && image) {
                image = image.fixedOrientationImage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (captureHandle) {
                        CHImage *chImage = [[CHImage alloc] init];
                        chImage.image = image;
                        chImage.imageInfo = info;
                        captureHandle(self, chImage);
                    }
                });
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRepresentation = alAsset.defaultRepresentation;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGImageRef imageRef = assetRepresentation.fullResolutionImage;
            UIImage *originalImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (captureHandle) {
                    CHImage *chImage = [[CHImage alloc] init];
                    chImage.image = originalImage;
                    captureHandle(self, chImage);
                }
            });
        });
    }
}

/**
 *  获取单个相册的相册封面信息模型
 *
 *  @param albumModel    单个相册的数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle 获取单个相册的相册封面信息模型回调
 */
- (void)albumCoverImageWithAlbumModel:(CHAlbum *)albumModel imageWidth:(CGFloat)imageWidth captureHandle:(CHAlbumManagerAlbumCoverImageCaptureHandle)captureHandle {
    if (albumModel == nil || captureHandle == nil) {
        return ;
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        if (![albumModel.fetchResult count]) {
            if (captureHandle) {
                captureHandle(self, nil);
            }
            return ;
        }
        
        id asset = [albumModel.fetchResult lastObject];
        CHAsset *assetModel = [[CHAsset alloc] init];
        assetModel.asset = asset;
        [self imageWithAssetModel:assetModel imageWidth:imageWidth captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
            if (captureHandle) {
                captureHandle(defaultManager, image);
            }
        }];
    } else {
        ALAssetsGroup *assetGroup = albumModel.fetchResult;
        CGImageRef imageRef = assetGroup.posterImage;
        UIImage *coverImage = [UIImage imageWithCGImage:imageRef];
        if (captureHandle) {
            CHImage *chImage = [[CHImage alloc] init];
            chImage.image = coverImage;
            captureHandle(self, chImage);
        }
    }
}

/**
 *  单个图片保存到相册
 *
 *  @param image            图片
 *  @param completionHandle 单个图片保存到相册的完成回调
 */
- (void)saveImage:(UIImage *)image completionHandle:(CHAlbumManagerSaveImageCompletionHandle)completionHandle {
    if (image == nil) {
        return ;
    }
    objc_setAssociatedObject(self, &CHAlbumManagerSaveImageCompletionHandleKey, completionHandle, OBJC_ASSOCIATION_COPY);
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    CHAlbumManagerSaveImageCompletionHandle completionHanle = objc_getAssociatedObject(self, &CHAlbumManagerSaveImageCompletionHandleKey);
    if (completionHanle) {
        completionHanle(self, error);
    }
}

- (ALAssetsLibrary *)assetsLibrary {
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 && !_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

/**
 *  用户是否开启了相机/相册权限
 */
- (BOOL)authorizationStatusAuthorized {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            return YES;
        }
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            return YES;
        }
    }
    return NO;
}

@end
