//
//  CHVideoManager.m
//  ImagePicker
//
//  Created by Charles on 16/10/11.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHVideoManager.h"
#import "CHAssetModel.h"

@implementation CHVideoManager

+ (instancetype)defaultManager {
    static CHVideoManager *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (void)videoWithAssetModel:(CHAssetModel *)assetModel captureHandle:(CHVideoManagerSingleVideoInfoCaptureHandle)captureHandle {
    id asset = assetModel.asset;
    if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *as = (ALAsset *)asset;
        ALAssetRepresentation *assetRepresentation = as.defaultRepresentation;
        NSString *uti = assetRepresentation.UTI;
        id value = [as valueForProperty:ALAssetPropertyURLs];
        NSURL *url = [value valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        if (captureHandle) {
            captureHandle(self, playerItem, nil);
        }
    } else {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        [[PHImageManager defaultManager] requestPlayerItemForVideo:(PHAsset *)asset options:videoRequestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (captureHandle) {
                captureHandle(self, playerItem, info);
            }
        }];
    }
}

- (void)videoExportPathWithAssetModel:(CHAssetModel *)assetModel exportHandle:(CHVideoManagerSingleVideoInfoExportHandle)exportHandle {
    id asset = assetModel.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
            AVURLAsset *urlAsset = (AVURLAsset*)avasset;
            [self exportVideoWithURLAsset:urlAsset exportHandle:exportHandle];
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        NSURL *url =[asset valueForProperty:ALAssetPropertyAssetURL];
        AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:url options:nil];
        [self exportVideoWithURLAsset:urlAsset exportHandle:exportHandle];
    }
    
}

- (void)exportVideoWithURLAsset:(AVURLAsset *)urlAsset exportHandle:(CHVideoManagerSingleVideoInfoExportHandle)exportHandle {
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:urlAsset];
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:urlAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        session.shouldOptimizeForNetworkUse = true;
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            return;
        } else {
            session.outputFileType = supportedTypeArray.firstObject;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[self tmpPath]]) {
            [fileManager createDirectoryAtPath:[self tmpPath] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            if (exportHandle) {
                if (session.status == AVAssetExportSessionStatusCompleted) {
                    exportHandle(self, outputPath, YES, NO);
                } else if (session.status == AVAssetExportSessionStatusExporting) {
                    exportHandle(self, outputPath, YES, YES);
                } else if (session.status == AVAssetExportSessionStatusFailed) {
                    exportHandle(self, outputPath, NO, NO);
                }
                
            }
        }];
    }
}

- (NSString *)tmpPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}
@end
