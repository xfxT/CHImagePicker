//
//  CHAlbumListViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHAlbumListViewCell.h"
#import "CHAlbum.h"
#import "CHAlbumManager.h"
#import "CHImage.h"

@interface CHAlbumListViewCell ()
/**
 *  选中数量
 */
@property (weak, nonatomic) IBOutlet UILabel *selectCountL;
/**
 *  封面视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
/**
 *  名字
 */
@property (weak, nonatomic) IBOutlet UILabel *nameL;
/**
 *  总数量
 */
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

- (void)setAlbumModel:(CHAlbum *)albumModel {
    _albumModel = albumModel;
     
    self.nameL.text = albumModel.albumName;
    if (albumModel.selectedAssetModelsCount == 0) {
        self.selectCountL.backgroundColor = [UIColor clearColor];
    } else {
        self.selectCountL.backgroundColor = [UIColor orangeColor];
    }
    self.selectCountL.text = albumModel.selectedAssetModelsCount > 0 ? [NSString stringWithFormat:@"%ld", albumModel.selectedAssetModelsCount] : @"";
    
    self.countL.text = [NSString stringWithFormat:@"%ld", albumModel.totalAssetModelsCount];
    
    [[CHAlbumManager defaultManager] albumCoverImageWithAlbumModel:albumModel imageWidth:self.coverImgView.frame.size.width captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
        self.coverImgView.image = image.image;
    }];
}

@end
