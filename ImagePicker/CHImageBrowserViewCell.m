//
//  CHImageBrowserViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageBrowserViewCell.h"
#import "CHAssetModel.h"
#import "CHImageManager.h"

@interface CHImageBrowserViewCell ()
@property (nonatomic, weak) UIButton *actionBtn;
@property (nonatomic, weak) UIImageView *imgView;
@end

@implementation CHImageBrowserViewCell

- (void)setAssetModel:(CHAssetModel *)assetModel {
    _assetModel = assetModel;
    
    [[CHImageManager defaultManager] imageWithAssetModel:assetModel targetSize:self.imgView.frame.size captureHandle:^(CHImageManager *defaultManager, UIImage *image, NSDictionary *imageInfo) {
        self.imgView.image = image;
    }];
    
    self.actionBtn.selected = assetModel.selectType;
}

- (UIButton *)actionBtn {
    if (!_actionBtn) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:actionBtn];
        _actionBtn = actionBtn;
        actionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [actionBtn setTitle:@"未选中" forState:UIControlStateNormal];
        [actionBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [actionBtn setTitle:@"选中" forState:UIControlStateSelected];
        [actionBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [actionBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionBtn;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:imgView];
        _imgView = imgView;
        imgView.clipsToBounds = YES;
    }
    return _imgView;
}

- (void)actionBtnClick:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    self.assetModel.selectType = btn.selected;
    
    if (self.selectHandle) {
        self.selectHandle(self, self.assetModel);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgView.frame = self.contentView.bounds;
    
    CGFloat actionBtnX = self.contentView.frame.size.width - 80;
    CGFloat actionBtnY = 20;
    CGFloat actionBtnW = 60;
    CGFloat actionBtnH = 20;
    self.actionBtn.frame = CGRectMake(actionBtnX, actionBtnY, actionBtnW, actionBtnH);
}
@end
