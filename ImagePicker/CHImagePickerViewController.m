//
//  CHImagePickerViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerViewController.h"
#import "CHAlbumListViewController.h"

@interface CHImagePickerViewController ()

@end

@implementation CHImagePickerViewController

- (NSMutableArray *)assetModelArray {
    if (!_assetModelArray) {
        _assetModelArray = [NSMutableArray new];
    }
    return _assetModelArray;
}

- (instancetype)init {
    self = [super initWithRootViewController:[[CHAlbumListViewController alloc] init]];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
