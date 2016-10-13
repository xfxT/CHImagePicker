//
//  CHImageListViewCell.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHImageListViewCell, CHAsset;

/**
 *  单个相册的相片列表的单个相片选中/未选中的回调类型
 *
 *  @param cell       单个相册的相片列表的单个相片所在的cell
 *  @param assetModel 单个相册的相片列表的单个相片的数据模型
 *  @param actionBtn  单个相册的相片列表的单个相片的选中/未选中按钮
 */
typedef void(^CHImageListViewCellSelectHandle)(CHImageListViewCell *cell, CHAsset *assetModel, UIButton *actionBtn);

@interface CHImageListViewCell : UICollectionViewCell
/**
 *  单个相册的相片列表的单个相片的数据模型
 */
@property (nonatomic, strong) CHAsset *assetModel;

/**
 *  单个相册的相片列表的单个相片选中/未选中的回调
 */
@property (nonatomic, copy) CHImageListViewCellSelectHandle selectHandle;
@end
