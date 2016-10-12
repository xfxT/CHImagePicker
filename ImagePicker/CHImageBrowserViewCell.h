//
//  CHImageBrowserViewCell.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHAsset.h"

@class CHImageBrowserViewCell;

/**
 *  选择了单个相片之后的回调类型
 *
 *  @param cell       预览界面的单个相片所在的cell
 *  @param assetModel 预览界面的单个相片的数据模型
 */
typedef void(^CHImageBrowserViewCellSelectHandle)(CHImageBrowserViewCell *cell, CHAsset *assetModel);

@interface CHImageBrowserViewCell : UICollectionViewCell

/**
 *  预览界面的单个相片的数据模型
 */
@property (nonatomic, strong) CHAsset *assetModel;

/**
 *  选择了单个相片之后的回调
 */
@property (nonatomic, copy) CHImageBrowserViewCellSelectHandle selectHandle;

@end
