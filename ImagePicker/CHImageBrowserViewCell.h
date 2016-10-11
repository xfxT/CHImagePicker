//
//  CHImageBrowserViewCell.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHAssetModel.h"

@class CHImageBrowserViewCell;

typedef void(^CHImageBrowserViewCellSelectHandle)(CHImageBrowserViewCell *cell, CHAssetModel *assetModel);

@interface CHImageBrowserViewCell : UICollectionViewCell
@property (nonatomic, strong) CHAssetModel *assetModel;
@property (nonatomic, copy) CHImageBrowserViewCellSelectHandle selectHandle;
@end
