//
//  CHImageListBottomToolBar.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageListBottomToolBar.h"

@interface CHImageListBottomToolBar ()
@property (nonatomic, weak) UIButton *preBtn;
@property (nonatomic, weak) UIButton *fullImageBtn;
@property (nonatomic, weak) UILabel *dataLengthL;
@property (nonatomic, weak) UIButton *doneBtn;
@end

@implementation CHImageListBottomToolBar

+ (instancetype)toolBar {
    return [[self alloc] init];
}

- (void)setDataLength:(CGFloat)dataLength {
    _dataLength = dataLength;
    self.dataLengthL.text = [NSString stringWithFormat:@"%.1f", dataLength];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self.doneBtn setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
}

- (UIButton *)preBtn {
    if (!_preBtn) {
        UIButton *pre = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:pre];
        _preBtn = pre;
        [pre setTitle:@"PreView" forState:UIControlStateNormal];
        pre.titleLabel.font = [UIFont systemFontOfSize:13];
        [pre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pre addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        pre.tag = 1;
    }
    return _preBtn;
}

- (void)btnClick:(UIButton *)btn {
    
    if (btn.tag == 2) {
        self.dataLengthL.hidden = !btn.selected;
    }
    
    if (self.itemClickHandle) {
        self.itemClickHandle(self, btn.tag - 1);
    }
}

- (UIButton *)fullImageBtn {
    if (!_fullImageBtn) {
        UIButton *fullImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:fullImage];
        _fullImageBtn = fullImage;
        [fullImage setTitle:@"Full Image" forState:UIControlStateNormal];
        fullImage.titleLabel.font = [UIFont systemFontOfSize:13];
        [fullImage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [fullImage addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        fullImage.tag = 2;
    }
    return _fullImageBtn;
}

- (UILabel *)dataLengthL {
    if (!_dataLengthL) {
        UILabel *dataLength = [[UILabel alloc] init];
        [self addSubview:dataLength];
        _dataLengthL = dataLength;
        dataLength.hidden = YES;
        dataLength.textColor = [UIColor blackColor];
        dataLength.font = [UIFont systemFontOfSize:13];
    }
    return _dataLengthL;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:done];
        _doneBtn = done;
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        done.titleLabel.font = [UIFont systemFontOfSize:13];
        [done addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        done.tag = 3;
    }
    return _doneBtn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat preX = 10;
    CGFloat preH = 20;
    CGFloat preY = self.frame.size.height / 2.0 - preH / 2.0;
    CGFloat preW = 45;
    self.preBtn.frame = CGRectMake(preX, preY, preW, preH);
    
    CGFloat fullX = 0;
    CGFloat fullY = preY;
    CGFloat fullW = 80;
    CGFloat fullH = preH;
    self.fullImageBtn.frame = CGRectMake(fullX, fullY, fullW, fullH);
    self.fullImageBtn.center = CGPointMake(self.frame.size.width / 2.0, self.fullImageBtn.center.y);
    
    CGFloat doneW = 70;
    CGFloat doneX = self.frame.size.width - doneW - 20;
    CGFloat doneY = preY;
    CGFloat doneH = preH;
    self.doneBtn.frame = CGRectMake(doneX, doneY, doneW, doneH);
}

@end
