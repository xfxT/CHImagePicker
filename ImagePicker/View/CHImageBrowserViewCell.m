//
//  CHImageBrowserViewCell.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageBrowserViewCell.h"
#import "CHAsset.h"
#import "CHImage.h"
#import "CHAlbumManager.h"

@interface CHImageBrowserViewCell () <UIScrollViewDelegate>
/**
 *  容器滚动视图
 */
@property (nonatomic, weak) UIScrollView *scrollView;
/**
 *  相片
 */
@property (nonatomic, weak) UIImageView *imgView;
/**
 *  相片背景视图
 */
@property (nonatomic, weak) UIView *bgView;
/**
 *  选中/未选中
 */
@property (nonatomic, weak) UIButton *actionBtn;
@end

@implementation CHImageBrowserViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTapGest];
    }
    return self;
}

/**
 *  添加双击手势
 */
- (void)addTapGest {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestHandle:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
}

/**
 *  双击手势处理事件 
 */
- (void)doubleTapGestHandle:(UITapGestureRecognizer *)doubleTapGest {
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    if (zoomScale <= 1.0) {
        CGPoint point = [doubleTapGest locationInView:self.imgView];
        CGFloat maximumZoomScale = self.scrollView.maximumZoomScale;
        CGFloat zoomX = self.frame.size.width / maximumZoomScale;
        CGFloat zoomY = self.frame.size.height / maximumZoomScale;
        CGRect zoomRect = CGRectMake(point.x - zoomX / 2.0, point.y - zoomY / 2.0, zoomX, zoomY);
        [self.scrollView zoomToRect:zoomRect animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

/**
 *  设置预览界面的单个相片的数据模型
 *
 *  @param assetModel 预览界面的单个相片的数据模型
 */
- (void)setAssetModel:(CHAsset *)assetModel {
    _assetModel = assetModel;
    [[CHAlbumManager defaultManager] imageWithAssetModel:assetModel imageWidth:self.imgView.frame.size.width captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
        [self configWithImage:image.image];
    }];
    self.actionBtn.selected = assetModel.selectType;
}

/**
 *  获取到了UIImage对象之后处理
 */
- (void)configWithImage:(UIImage *)image {
    
    // 1. 设置数据
    self.imgView.image = image;
    
    // 2. 让scrollView还原
    self.scrollView.zoomScale = 1.0;
    
    // 3. 重新布局
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 容器滚动视图
    CGFloat scX = 8;
    CGFloat scY = 0;
    CGFloat scW = self.contentView.frame.size.width - scX * 2.0;
    CGFloat scH = self.contentView.frame.size.height;
    self.scrollView.frame = CGRectMake(scX, scY, scW, scH);
    
    // 相片背景视图
    CGFloat bgViewX = 0.0;
    CGFloat bgViewY = 0.0;
    CGFloat bgViewW = scW;
    CGFloat bgViewH = 0.0;
    
    UIImage *image = self.imgView.image;
    if (image) {
        CGFloat imgDelta = image.size.height / image.size.width;
        CGFloat scDelta = self.contentView.frame.size.height / self.contentView.frame.size.width;
        if (imgDelta > scDelta) {
            bgViewH = floor(image.size.height / (image.size.width / scW));
        } else {
            bgViewH = imgDelta * scW;
        }
        bgViewH = bgViewH > self.contentView.frame.size.height ? self.contentView.frame.size.height : bgViewH;
    }
    bgViewY = (scH - bgViewH) / 2.0;
    self.bgView.frame = CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH);
    
    // 相片
    self.imgView.frame = self.bgView.bounds;
    
    CGFloat contentSizeW = scW;
    CGFloat contentSizeH = bgViewH > self.contentView.frame.size.height ? bgViewH : self.contentView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(contentSizeW, contentSizeH);
    
    // 选中/未选中
    CGFloat actionW = 50;
    CGFloat actionH = 30;
    CGFloat actionX = self.contentView.frame.size.width - 10 - actionW;
    CGFloat actionY = 20;
    self.actionBtn.frame = CGRectMake(actionX, actionY, actionW, actionH);
    [self.contentView bringSubviewToFront:self.actionBtn];
}

- (void)actionBtnClick:(UIButton *)btn {
    
    [UIView animateWithDuration:0.1 animations:^{
        btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 animations:^{
                btn.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                if (finished) {
                    btn.selected = !btn.selected;
                    self.assetModel.selectType = btn.selected;
                    
                    if (self.selectHandle) {
                        self.selectHandle(self, self.assetModel);
                    }
                }
            }];
        }
    }];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.bgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.bgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIButton *)actionBtn {
    if (!_actionBtn) {
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:actionBtn];
        _actionBtn = actionBtn;
        [actionBtn setImage:[UIImage imageNamed:@"picture_normal"] forState:UIControlStateNormal];
        [actionBtn setImage:[UIImage imageNamed:@"picture_selected"] forState:UIControlStateSelected];
        [actionBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionBtn;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scroll = [[UIScrollView alloc] init];
        [self.contentView addSubview:scroll];
        _scrollView = scroll;
        scroll.scrollsToTop = NO;
        scroll.delegate = self;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.canCancelContentTouches = YES;
        scroll.maximumZoomScale = 2.0;
        scroll.minimumZoomScale = 1.0;
        scroll.multipleTouchEnabled = YES;
    }
    return _scrollView;
}

- (UIView *)bgView {
    if (!_bgView) {
        UIView *bgView = [[UIView alloc] init];
        [self.scrollView addSubview:bgView];
        _bgView = bgView;
        bgView.clipsToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        UIImageView *img = [[UIImageView alloc] init];
        [self.bgView addSubview:img];
        _imgView = img;
        img.clipsToBounds = YES;
    }
    return _imgView;
}
@end
