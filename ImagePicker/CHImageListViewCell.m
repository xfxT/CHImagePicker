//
//  CHImageListViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageListViewCell.h"
#import "CHAssetModel.h"
#import "CHImageManager.h"

@interface CHImageListViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation CHImageListViewCell

- (void)setAssetModel:(CHAssetModel *)assetModel {
    _assetModel = assetModel;
    
    self.actionBtn.selected = assetModel.selectType;
    
    [[CHImageManager defaultManager] imageWithAssetModel:assetModel targetSize:self.imgView.frame.size captureHandle:^(CHImageManager *defaultManager, UIImage *image, NSDictionary *imageInfo) {
         self.imgView.image = image;
     }];
}

- (IBAction)actionBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    self.assetModel.selectType = sender.selected;
    
    if (self.selectHandle) {
        self.selectHandle(self, self.assetModel);
    }
}
@end
