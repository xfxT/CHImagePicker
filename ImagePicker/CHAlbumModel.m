//
//  CHAlbumModel.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHAlbumModel.h"

@implementation CHAlbumModel
- (NSMutableArray *)selectedAssetModelArray {
    if (!_selectedAssetModelArray) {
        _selectedAssetModelArray = [NSMutableArray new];
    }
    return _selectedAssetModelArray;
}
@end
