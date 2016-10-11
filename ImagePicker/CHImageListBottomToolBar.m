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
@property (nonatomic, weak) UILabel *doneLeftCountL;
@end

@implementation CHImageListBottomToolBar

+ (instancetype)toolBar {
    return [[self alloc] init];
}

- (void)setDataLength:(CGFloat)dataLength {
    _dataLength = dataLength;
    self.dataLengthL.hidden = dataLength == 0;
    self.dataLengthL.text = [NSString stringWithFormat:@"%.1f", dataLength];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self.doneLeftCountL setText:[NSString stringWithFormat:@"%ld", count]];
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

- (UILabel *)doneLeftCountL {
    if (!_doneLeftCountL) {
        UILabel *doneLeftCount = [[UILabel alloc] init];
        [self addSubview:doneLeftCount];
        _doneLeftCountL = doneLeftCount;
        doneLeftCount.textColor = [UIColor whiteColor];
        doneLeftCount.font = [UIFont boldSystemFontOfSize:13];
        doneLeftCount.textAlignment = NSTextAlignmentCenter;
        doneLeftCount.backgroundColor = [UIColor greenColor];
        doneLeftCount.layer.cornerRadius = 15.0;
        doneLeftCount.layer.masksToBounds = YES;
        doneLeftCount.layer.shouldRasterize = YES;
    }
    return _doneLeftCountL;
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
    
    CGFloat dataLX = self.fullImageBtn.frame.origin.x + self.fullImageBtn.frame.size.width + 10;
    CGFloat dataLY = preY;
    CGFloat dataLW = 40;
    CGFloat dataLH = preH;
    self.dataLengthL.frame = CGRectMake(dataLX, dataLY, dataLW, dataLH);
    
    CGFloat doneW = 40;
    CGFloat doneX = self.frame.size.width - doneW - 20;
    CGFloat doneY = preY;
    CGFloat doneH = preH;
    self.doneBtn.frame = CGRectMake(doneX, doneY, doneW, doneH);
    
    CGFloat doneLeftCountLW = 30;
    CGFloat doneLeftCountLX = self.doneBtn.frame.origin.x - doneLeftCountLW;
    CGFloat doneLeftCountLY = preY;
    CGFloat doneLeftCountLH = 30;
    self.doneLeftCountL.frame = CGRectMake(doneLeftCountLX, doneLeftCountLY, doneLeftCountLW, doneLeftCountLH);
    
}

@end
