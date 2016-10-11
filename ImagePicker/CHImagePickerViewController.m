//
//  CHImagePickerViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerViewController.h"
#import "CHAlbumListViewController.h"
#import "CHImageManager.h"
#import "CHAssetModel.h"
@implementation CHImagePickerViewController

- (NSArray *)imageArray {
   
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (CHAssetModel *assetModel in self.assetModelArray) {
        [[CHImageManager defaultManager] imageWithAssetModel:assetModel targetSize:[UIScreen mainScreen].bounds.size captureHandle:^(CHImageManager *defaultManager, UIImage *image, NSDictionary *imageInfo) {
            [mutableArray addObject:image];
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
        self.maximumCount = 3;
        self.sourceType = CHImagePickerViewControllerSourceTypeImage;
    }
    return self;
}

- (void)setMaximumCount:(NSInteger)maximumCount {
    _maximumCount = maximumCount;
    [CHImageManager defaultManager].maximumCount = maximumCount;
} 

- (void)setSourceType:(CHImagePickerViewControllerSourceType)sourceType {
    _sourceType = sourceType;
    [CHImageManager defaultManager].sourceType = sourceType;
}

@end
