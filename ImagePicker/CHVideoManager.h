//
//  CHVideoManager.h
//  ImagePicker
//
//  Created by Charles on 16/10/11.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h> // 8.0 之后
#import <AssetsLibrary/AssetsLibrary.h>

@class CHVideoManager, CHAssetModel;
typedef void(^CHVideoManagerSingleVideoInfoCaptureHandle)(CHVideoManager *defaultManager, AVPlayerItem *playerItem, NSDictionary *videoInfo);
typedef void(^CHVideoManagerSingleVideoInfoExportHandle)(CHVideoManager *defaultManager, NSString *exportPath, BOOL succeed, BOOL isExporting);
@interface CHVideoManager : NSObject

+ (instancetype)defaultManager;

- (void)videoWithAssetModel:(CHAssetModel *)assetModel captureHandle:(CHVideoManagerSingleVideoInfoCaptureHandle)captureHandle;

- (void)videoExportPathWithAssetModel:(CHAssetModel *)assetModel exportHandle:(CHVideoManagerSingleVideoInfoExportHandle)exportHandle;

@end
