//
//  CHAlbumManager.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h> // 8.0 之后
#import <AssetsLibrary/AssetsLibrary.h>

@class CHAlbumManager, CHAlbum, CHAsset, CHImage;

/**
 *  获取相机胶卷的数据模型回调类型
 *
 *  @param defaultManager 相册管理类
 *  @param albumModel     相机胶卷的数据模型
 */
typedef void(^CHAlbumManagerCameraRollAlbumCaptureHandle)(CHAlbumManager *defaultManager, CHAlbum *albumModel);

/**
 *  获取所有相册的数据模型数组回调类型
 *
 *  @param defaultManager  相册管理类
 *  @param albumModelArray 所有相册的数据模型数组
 */
typedef void(^CHAlbumManagerAllAlbumModelsCaptureHandle)(CHAlbumManager *defaultManager, NSArray <CHAlbum *>*albumModelArray);

/**
 *  获取单个相册的所有相片数据模型数组回调类型
 *
 *  @param defaultManager  相册管理类
 *  @param assetModelArray 单个相册的所有相片数据模型数组
 */
typedef void(^CHAlbumManagerAllAssetModelsCaptureHandle)(CHAlbumManager *defaultManager, NSArray <CHAsset *>*assetModelArray);

/**
 *  获取单个相片的相片信息模型回调类型
 *
 *  @param defaultManager 相册管理类
 *  @param image          单个相片的相片信息模型回调
 */
typedef void(^CHAlbumManagerSingleImageInfoCaptureHandle)(CHAlbumManager *defaultManager, CHImage *image);

/**
 *  获取单个相册的相册封面信息模型回调类型
 *
 *  @param defaultManager 相册管理类
 *  @param image          单个相册的相册封面信息模型
 */
typedef void(^CHAlbumManagerAlbumCoverImageCaptureHandle)(CHAlbumManager *defaultManager, CHImage *image);

/**
 *  单个图片保存到相册的完成回调类型
 *
 *  @param defaultManager 相册管理类
 *  @param error          错误信息
 */
typedef void(^CHAlbumManagerSaveImageCompletionHandle)(CHAlbumManager *defaultManager, NSError *error);

@interface CHAlbumManager : NSObject

/**
 *  用户是否开启了相机/相册权限
 */
@property (nonatomic, readonly) BOOL authorizationStatusAuthorized;

/**
 *  最大可选相片数量
 */
@property (nonatomic) NSInteger maximumCount; 

/**
 *  创建相册管理类单例
 *
 *  @return 相册管理类单例
 */
+ (instancetype)defaultManager;

/**
 *  获取相机胶卷的数据模型
 *
 *  @param captureHandle 获取相机胶卷的数据模型回调
 */
- (void)cameraRollAlbumModelWithCaptureHandle:(CHAlbumManagerCameraRollAlbumCaptureHandle)captureHandle;

/**
 *  获取所有相册的数据模型数组
 *
 *  @param captureHandle 获取所有相册的数据模型数组回调
 */
- (void)allAlbumModelsWithCaptureHandle:(CHAlbumManagerAllAlbumModelsCaptureHandle)captureHandle;

/**
 *  获取单个相册的所有相片数据模型数组
 *
 *  @param albumModel    单个相册的数据模型
 *  @param captureHandle 获取单个相册的所有相片数据模型数组回调
 */
- (void)allAssetModelsWithAlbumModel:(CHAlbum *)albumModel captureHandle:(CHAlbumManagerAllAssetModelsCaptureHandle)captureHandle;

/**
 *  获取单个相片的相片信息模型
 *
 *  @param assetModel    单个相片的相片数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle  获取单个相片的相片信息模型回调
 */
- (void)imageWithAssetModel:(CHAsset *)assetModel imageWidth:(CGFloat)imageWidth captureHandle:(CHAlbumManagerSingleImageInfoCaptureHandle)captureHandle;
/**
 *  获取单个相片的原图信息模型
 *
 *  @param assetModel    单个相片的相片数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle  获取单个相片的原图信息模型回调
 */
- (void)originalImageWithAssetModel:(CHAsset *)assetModel captureHandle:(CHAlbumManagerSingleImageInfoCaptureHandle)captureHandle; 

/**
 *  获取单个相册的相册封面信息模型
 *
 *  @param albumModel    单个相册的数据模型
 *  @param imageWidth    图片指定的宽度
 *  @param captureHandle 获取单个相册的相册封面信息模型回调
 */
- (void)albumCoverImageWithAlbumModel:(CHAlbum *)albumModel imageWidth:(CGFloat)imageWidth captureHandle:(CHAlbumManagerAlbumCoverImageCaptureHandle)captureHandle;

/**
 *  单个图片保存到相册
 *
 *  @param image            图片
 *  @param completionHandle 单个图片保存到相册的完成回调
 */
- (void)saveImage:(UIImage *)image completionHandle:(CHAlbumManagerSaveImageCompletionHandle)completionHandle;

@end
