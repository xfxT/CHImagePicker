//
//  CHAlbumListViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHAlbumListViewCell.h"
#import "CHAlbumModel.h"
#import "CHImageManager.h"

@interface CHAlbumListViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *selectCountL;
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *countL;
@end

@implementation CHAlbumListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectCountL.layer.cornerRadius = 15.0;
    self.selectCountL.layer.masksToBounds = YES;
    self.selectCountL.layer.shouldRasterize = YES;
    self.coverImgView.clipsToBounds = YES;
}

- (void)setAlbumModel:(CHAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    self.coverImgView.image = nil;
    self.nameL.text = albumModel.name;
    if (albumModel.selectedCount == 0) {
        self.selectCountL.backgroundColor = [UIColor clearColor];
    } else {
        self.selectCountL.backgroundColor = [UIColor orangeColor];
    }
    self.selectCountL.text = albumModel.selectedCount > 0 ? [NSString stringWithFormat:@"%ld", albumModel.selectedCount] : @"";
    
    self.countL.text = [NSString stringWithFormat:@"%ld", albumModel.count];
    
    [[CHImageManager defaultManager] albumCoverImageWithAlbumModel:albumModel targetSize:self.coverImgView.frame.size captureHandle:^(CHImageManager *defaultManager, UIImage *image) {
        self.coverImgView.image = image;
    }];
}

@end
