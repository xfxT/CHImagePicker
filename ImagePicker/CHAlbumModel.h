//
//  CHAlbumModel.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHAssetModel;
@interface CHAlbumModel : NSObject
@property (nonatomic, strong) id fetchResult;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger totalAssetModelsCount;
@property (nonatomic, assign) NSInteger selectedAssetModelsCount;
@property (nonatomic, strong) NSMutableArray *selectedAssetModelArray;
@end
