//
//  CHAlbum.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHAsset;
@interface CHAlbum : NSObject
@property (nonatomic, strong) id fetchResult;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger totalAssetModelsCount;
@property (nonatomic, assign) NSInteger selectedAssetModelsCount;
@property (nonatomic, strong) NSMutableArray *selectedAssetModelArray;
@end
