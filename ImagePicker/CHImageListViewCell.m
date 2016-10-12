//
//  CHImageListViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageListViewCell.h"
#import "CHAsset.h"
#import "CHImage.h"
#import "CHAlbumManager.h"

@interface CHImageListViewCell ()
/**
 *  选中/未选中
 */
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

/**
 *  相片
 */
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation CHImageListViewCell

/**
 *  设置单个相册的相片列表的单个相片的数据模型
 *
 *  @return 单个相册的相片列表的单个相片的数据模型
 */
- (void)setAssetModel:(CHAsset *)assetModel {
    _assetModel = assetModel;
    
    // 1. 设置选中未选中
    self.actionBtn.selected = assetModel.selectType;
    
    // 2. 设置数据
    [[CHAlbumManager defaultManager] imageWithAssetModel:assetModel imageWidth:self.imgView.frame.size.width captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
         self.imgView.image = image.image;
     }];
}

- (IBAction)actionBtnClick:(UIButton *)sender {
    
    if (self.selectHandle) {
        self.selectHandle(self, self.assetModel, sender);
    }
}
@end
