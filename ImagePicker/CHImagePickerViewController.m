//
//  CHImagePickerViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerViewController.h"
#import "CHAlbumListViewController.h"
#import "CHAlbumManager.h"
#import "CHAsset.h"
#import "CHImage.h"

@implementation CHImagePickerViewController

- (NSArray *)imageArray {
   
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (CHAsset *assetModel in self.assetModelArray) {
        [[CHAlbumManager defaultManager] imageWithAssetModel:assetModel imageWidth:[UIScreen mainScreen].bounds.size.width captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
            if (image.image) {
                [mutableArray addObject:image];
            }
        }];
    }
    return mutableArray.copy;
}

- (NSMutableArray *)assetModelArray {
    if (!_assetModelArray) {
        _assetModelArray = [NSMutableArray new];
    }
    return _assetModelArray;
}

- (instancetype)init {
    self = [super initWithRootViewController:[[CHAlbumListViewController alloc] init]];
    if (self) {
        self.maximumCount = 9;
    }
    return self;
}

- (void)setMaximumCount:(NSInteger)maximumCount {
    _maximumCount = maximumCount;
    [CHAlbumManager defaultManager].maximumCount = maximumCount;
}

@end
