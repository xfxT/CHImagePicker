//
//  CHImageManager.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageManager.h"
#import "CHAssetModel.h"
#import "CHAlbumModel.h"
#import "UIImage+CHAddition.h"
#import <objc/runtime.h>

static const char CHImageManagerSaveImageCompletionHandleKey;

@interface CHImageManager ()
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) PHCachingImageManager *phCachingImageManager;
@end

@implementation CHImageManager
- (PHCachingImageManager *)phCachingImageManager {
    if (!_phCachingImageManager) {
        _phCachingImageManager = [PHCachingImageManager new];
    }
    return _phCachingImageManager;
}

- (NSCache *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSCache new];
    }
    return _imageCache;
}

+ (instancetype)defaultManager {
    static CHImageManager *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (BOOL)isCameraRollAlbumWithLocalizedTitle:(NSString *)localizedTitle {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [localizedTitle isEqualToString:@"最近添加"] || [localizedTitle isEqualToString:@"Recently Added"];
    } else {
        return [localizedTitle isEqualToString:@"Camera Roll"] || [localizedTitle isEqualToString:@"相机胶卷"] || [localizedTitle isEqualToString:@"所有照片"] || [localizedTitle isEqualToString:@"All Photos"];
    }
}

- (void)cameraRollAlbumModelWithCaptureHandle:(CHImageManagerCameraRollAlbumCaptureHandle)captureHandle {
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
                if ([self isCameraRollAlbumWithLocalizedTitle:assetCollection.localizedTitle]) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                    
                    CHAlbumModel *albumModel = [[CHAlbumModel alloc] init];
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
                    if ([self isCameraRollAlbumWithLocalizedTitle:groupPropertyName]) {
                        CHAlbumModel *albumModel = [[CHAlbumModel alloc] init];
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

- (void)imagesDataLengthWithAssetModels:(NSArray<CHAssetModel *> *)assetModels completionHandle:(CHImageManagerCaptureDataLengthCompletionHandle)completionHandle {
    __block CGFloat dataLength = 0;
    for (int i = 0; i < assetModels.count; i++) {
        CHAssetModel *model = assetModels[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.currentSourceType != CHImagePickerViewControllerSourceTypeVideo) {
                    dataLength += imageData.length;
                }
                if (i == assetModels.count - 1) {
                    if (completionHandle) {
                        completionHandle(self, dataLength / 1024 / 1024 * 1.0);
                    }
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.currentSourceType != CHImagePickerViewControllerSourceTypeVideo) {
                dataLength += representation.size;
            }
            if (i == assetModels.count - 1) {
                if (completionHandle) {
                    completionHandle(self, dataLength / 1024 / 1024 * 1.0);
                }
            }
        }
    }
}

- (void)allAlbumModelsWithCaptureHandle:(CHImageManagerAllAlbumModelsCaptureHandle)captureHandle {
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
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        // smartAndRegularAlbums/相册数组
        for (PHAssetCollection *assetCollection in smartAndRegularAlbums) {
            // 获取单个相册
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                // 某个相册中的图片
                if (fetchResult.count > 0) {
                    if (![assetCollection.localizedTitle isEqualToString:@"Deleted"] && ![assetCollection.localizedTitle isEqualToString:@"最近删除"]) {
                        // Camera Roll 在最前面
                        CHAlbumModel *albumModel = [[CHAlbumModel alloc] init];
                        albumModel.albumName = assetCollection.localizedTitle;
                        albumModel.totalAssetModelsCount = fetchResult.count;
                        albumModel.fetchResult = fetchResult;
                        
                        if ([self isCameraRollAlbumWithLocalizedTitle:assetCollection.localizedTitle]) {
                            [albumsArray insertObject:albumModel atIndex:0];
                        } else {
                            [albumsArray addObject:albumModel];
                        }
                    }
                }
            }
        }
        
        // topLevelUserCollections/相册数组
        for (PHAssetCollection *assetCollection in topLevelUserCollections) {
            if ([assetCollection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
                if (fetchResult.count > 0) {
                    CHAlbumModel *albumModel = [[CHAlbumModel alloc] init];
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
                    CHAlbumModel *albumModel = [[CHAlbumModel alloc] init];
                    albumModel.fetchResult = group;
                    albumModel.totalAssetModelsCount = group.numberOfAssets;
                    NSString *groupPropertyName = [group valueForProperty:ALAssetsGroupPropertyName];
                    albumModel.albumName = groupPropertyName;
                    if ([self isCameraRollAlbumWithLocalizedTitle:groupPropertyName]) {
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
            
        }];
    }
    
}

- (void)allAssetModelsWithAlbumModel:(CHAlbumModel *)albumModel captureHandle:(CHImageManagerAllAssetModelsCaptureHandle)captureHandle {
    if (albumModel == nil || captureHandle == nil) {
        return ;
    }
    id result = albumModel.fetchResult;
    NSMutableArray *assetModelArray = [NSMutableArray new];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        for (PHAsset *asset in fetchResult) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                CHAssetModel *assetModel = [[CHAssetModel alloc] init];
                assetModel.asset = asset;
                assetModel.timeLength = 0;
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
                CHAssetModel *assetModel = [[CHAssetModel alloc] init];
                assetModel.asset = result;
                assetModel.timeLength = 0;
                [assetModelArray addObject:assetModel];
            } else {
                if (captureHandle) {
                    captureHandle(self, assetModelArray);
                }
            }
        }];
    }
}

- (void)imageWithAssetModel:(CHAssetModel *)assetModel targetSize:(CGSize)targetSize captureHandle:(CHImageManagerSingleImageInfoCaptureHandle)captureHandle {
    if (assetModel == nil || captureHandle == nil) {
        return ;
    }
    CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
    id asset = assetModel.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        
        NSString *Id = [NSString stringWithFormat:@"%@%@", [asset localIdentifier], NSStringFromCGSize(targetSize)];
        if ([self.imageCache objectForKey:Id]) {
            if (captureHandle) {
                UIImage *image = [self.imageCache objectForKey:Id];
                captureHandle(self, image, nil);
            }
            return ;
        }
        
        CGSize imageSize;
        if (photoWidth < [UIScreen mainScreen].bounds.size.width && photoWidth < 600) {
            CGFloat imageSizeWH = [UIScreen mainScreen].bounds.size.width / 3.0;
            imageSize = CGSizeMake(imageSizeWH, imageSizeWH);
        } else {
            PHAsset *as = (PHAsset *)asset;
            CGFloat aspectRatio = as.pixelWidth / as.pixelHeight * 1.0;
            CGFloat pixelW = photoWidth * 2.0;
            CGFloat pixelH = pixelW / aspectRatio;
            imageSize = CGSizeMake(pixelW, pixelH);
        }
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [self.phCachingImageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            
            if (([[info objectForKey:PHImageCancelledKey] boolValue] == NO || [info objectForKey:PHImageErrorKey] == nil)) {
                if (image) {
                    image = image.fixedOrientationImage;
                    if (captureHandle) {
                        captureHandle(self, image, info);
                    }
                    [self.imageCache setObject:image forKey:Id];
                }
            }
            
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && image == nil) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                [self.phCachingImageManager requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [image newImageWithTargetSize:imageSize];
                    if (resultImage) {
                        resultImage = resultImage.fixedOrientationImage;
                        if (captureHandle) {
                            captureHandle(self, resultImage, info);
                        }
                        [self.imageCache setObject:resultImage forKey:Id];
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
                    captureHandle(self, thumbnailImage, nil);
                }
            });
        });
    }
}

- (void)saveImage:(UIImage *)image completionHandle:(CHImageManagerSaveImageCompletionHandle)completionHandle {
    if (image == nil) {
        return ;
    }
    objc_setAssociatedObject(self, &CHImageManagerSaveImageCompletionHandleKey, completionHandle, OBJC_ASSOCIATION_COPY);
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    CHImageManagerSaveImageCompletionHandle completionHanle = objc_getAssociatedObject(self, &CHImageManagerSaveImageCompletionHandleKey);
    if (completionHanle) {
        completionHanle(self, error);
    }
}

- (void)albumCoverImageWithAlbumModel:(CHAlbumModel *)albumModel targetSize:(CGSize)targetSize captureHandle:(CHImageManagerAlbumCoverImageCaptureHandle)captureHandle {
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
        CHAssetModel *assetModel = [[CHAssetModel alloc] init];
        assetModel.asset = asset;
        [self imageWithAssetModel:assetModel targetSize:targetSize captureHandle:^(CHImageManager *defaultManager, UIImage *image, NSDictionary *imageInfo) {
            if (captureHandle) {
                captureHandle(defaultManager, image);
            }
        }];
    } else {
        ALAssetsGroup *assetGroup = albumModel.fetchResult;
        CGImageRef imageRef = assetGroup.posterImage;
        UIImage *coverImage = [UIImage imageWithCGImage:imageRef];
        if (captureHandle) {
            captureHandle(self, coverImage);
        }
    }
}

- (ALAssetsLibrary *)assetsLibrary {
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 && !_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (BOOL)authorizationStatusAuthorized {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [self.phCachingImageManager stopCachingImagesForAllAssets];
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
