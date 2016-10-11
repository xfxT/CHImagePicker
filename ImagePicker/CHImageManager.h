//
//  CHImageManager.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h> // 8.0 之后
#import <AssetsLibrary/AssetsLibrary.h>
#import "CHImagePickerConstant.h"

@class CHImageManager, CHAlbumModel, CHAssetModel;

typedef void(^CHImageManagerCameraRollAlbumCaptureHandle)(CHImageManager *defaultManager, CHAlbumModel *albumModel);
typedef void(^CHImageManagerAllAlbumModelsCaptureHandle)(CHImageManager *defaultManager, NSArray <CHAlbumModel *>*albumModelArray);
typedef void(^CHImageManagerAllAssetModelsCaptureHandle)(CHImageManager *defaultManager, NSArray <CHAssetModel *>*assetModelArray);
typedef void(^CHImageManagerSingleImageInfoCaptureHandle)(CHImageManager *defaultManager, UIImage *image, NSDictionary *imageInfo);
typedef void(^CHImageManagerAlbumCoverImageCaptureHandle)(CHImageManager *defaultManager, UIImage *image);
typedef void(^CHImageManagerSaveImageCompletionHandle)(CHImageManager *defaultManager, NSError *error);
typedef void(^CHImageManagerCaptureDataLengthCompletionHandle)(CHImageManager *defaultManager, CGFloat dataLength);
@interface CHImageManager : NSObject

@property (nonatomic, assign, readonly) BOOL authorizationStatusAuthorized;
@property (nonatomic) CHImagePickerViewControllerSourceType sourceType;

+ (instancetype)defaultManager;

- (void)cameraRollAlbumModelWithCaptureHandle:(CHImageManagerCameraRollAlbumCaptureHandle)captureHandle;

- (void)allAlbumModelsWithCaptureHandle:(CHImageManagerAllAlbumModelsCaptureHandle)captureHandle;

- (void)allAssetModelsWithAlbumModel:(CHAlbumModel *)albumModel captureHandle:(CHImageManagerAllAssetModelsCaptureHandle)captureHandle;

- (void)imageWithAssetModel:(CHAssetModel *)assetModel targetSize:(CGSize)targetSize captureHandle:(CHImageManagerSingleImageInfoCaptureHandle)captureHandle;

- (void)imagesDataLengthWithAssetModels:(NSArray <CHAssetModel *>*)assetModels completionHandle:(CHImageManagerCaptureDataLengthCompletionHandle)completionHandle;

- (void)albumCoverImageWithAlbumModel:(CHAlbumModel *)albumModel targetSize:(CGSize)targetSize captureHandle:(CHImageManagerAlbumCoverImageCaptureHandle)captureHandle;

- (void)saveImage:(UIImage *)image completionHandle:(CHImageManagerSaveImageCompletionHandle)completionHandle;

@end
