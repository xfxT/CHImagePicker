//
//  CHDemoViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHDemoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface CHDemoViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
// 所有的相册
@property (nonatomic, strong) NSMutableArray *albumArray;
// 所有的图片资源
@property (nonatomic, strong) NSMutableArray *imagesAssetsArray;

@property (nonatomic, strong) NSMutableArray *imagesArray;
@end

@implementation CHDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self capturePhotoWithAL];
    
    [self capturePhotoWithPH];
}

- (void)capturePhotoWithPH {
    // 列出所有相册智能相册
    //
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (int i = 0; i < smartAlbums.count; i++) {
        // 获取一个相册
        PHAssetCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            // 从每一个智能相册中获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
            
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        } else {
            NSAssert(NO, @"fetch collection is not PHCollection: %@", collection);
        }
    }
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 获取所有资源的集合，按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    // 这里的PHFetchResult包含的就是各个资源(PHAsset)
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    // 在资源集合中获取第一个集合，并获取其中的图片
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    // PHAsset代表一个资源，与AL中的ALAsset类似，通过PHAsset可以获取和保存资源
    PHAsset *asset = assetsFetchResults.firstObject;
    CGSize size = CGSizeMake(2208, 1473);
    // PHImageRequestOptions 控制加载图片时的一系列参数
    [imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        // 得到一张image，展示
        
    }];
}

- (void)capturePhotoWithAL {
    // 提示语
    NSString *tipTextWhenNoPhotosAuthorization;
    // 授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 限制 || 禁止 ,显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
        NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
        NSLog(@"--没有开启授权");
    }
    
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    // 如果已经授权的话，就可以获取相册列表
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _albumArray = [[NSMutableArray alloc] init];
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            // 筛选出所有的图片
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group.numberOfAssets > 0) {
                // 把相册存储到数组中，方便后面展示相册使用
                [_albumArray addObject:group];
            }
        } else {
            
            NSLog(@"albumArray : %@", self.albumArray);
            // 已经获取到所有的相册了，现在开始获取相册中的资源
            _imagesAssetsArray = [[NSMutableArray alloc] init];
            for (ALAssetsGroup *group in self.albumArray) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        // ALAsset为单个的图片或者视频资源
                        [_imagesAssetsArray addObject:result];
                    } else {
                        // result为nil，即遍历相册或者视频完毕，可以展示资源列表
                        NSLog(@"imagesAssetsArray : %@", self.imagesAssetsArray);
                        
                        
                        _imagesArray = [[NSMutableArray alloc] init];
                        // 遍历imagesAssetsArray，获取到所有的image
                        for (ALAsset *asset in self.imagesAssetsArray) {
                            ALAssetRepresentation *representation = [asset defaultRepresentation];
                            UIImage *contentImage = [UIImage imageWithCGImage:representation.fullScreenImage];
                            [_imagesArray addObject:contentImage];
                        }
                        
                        NSLog(@"imagesArray : %@", self.imagesArray);
                        
                    }
                }];
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"没有发现任何资源");
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
