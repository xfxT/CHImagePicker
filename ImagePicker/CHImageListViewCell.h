//
//  CHImageListViewCell.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHAssetModel,CHImageListViewCell ;
typedef void(^CHImageListViewCellSelectHandle)(CHImageListViewCell *cell, CHAssetModel *assetModel);
@interface CHImageListViewCell : UICollectionViewCell
@property (nonatomic, strong) CHAssetModel *assetModel;
@property (nonatomic, copy) CHImageListViewCellSelectHandle selectHandle;
@end
