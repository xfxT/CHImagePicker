//
//  CHImageListBottomToolBar.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageListBottomToolBar.h"

@interface CHImageListBottomToolBar ()
/**
 *  预览
 */
@property (nonatomic, weak) UIButton *preBtn;
/**
 *  完成
 */
@property (nonatomic, weak) UIButton *sendBtn;
/**
 *  数量
 */
@property (nonatomic, weak) UILabel *sendLeftCountL;
@end

@implementation CHImageListBottomToolBar

/**
 *  构造方法
 *
 *  @return 单个相册相片列表的底部选项栏实例对象
 */
+ (instancetype)toolBar {
    return [[self alloc] init];
}

- (void)setHiddenPreViewItem:(BOOL)hiddenPreViewItem {
    _hiddenPreViewItem = hiddenPreViewItem;
    self.preBtn.hidden = hiddenPreViewItem;
}

/**
 *  设置已经选择的相片数量
 *
 *  @param count 已经选择的相片的数量
 */
- (void)setCount:(NSInteger)count {
    [self setCount:count animated:YES];
}

- (void)setCount:(NSInteger)count animated:(BOOL)animated {
    _count = count;
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.sendLeftCountL.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.sendLeftCountL.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self.sendLeftCountL setText:[NSString stringWithFormat:@"%ld", count]];
                    }
                }];
            }
        }];
    } else {
        [self.sendLeftCountL setText:[NSString stringWithFormat:@"%ld", count]];
    }
 

}
- (void)btnClick:(UIButton *)btn { 
    if (self.itemClickHandle) {
        self.itemClickHandle(self, btn.tag - 1);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat preX = 10;
    CGFloat preH = 20;
    CGFloat preY = self.frame.size.height / 2.0 - preH / 2.0;
    CGFloat preW = 45;
    self.preBtn.frame = CGRectMake(preX, preY, preW, preH);
    
    CGFloat sendW = 40;
    CGFloat sendX = self.frame.size.width - sendW - 20;
    CGFloat sendY = preY;
    CGFloat sendH = preH;
    self.sendBtn.frame = CGRectMake(sendX, sendY, sendW, sendH);
    
    CGFloat sendLeftCountLW = 30;
    CGFloat sendLeftCountLX = self.sendBtn.frame.origin.x - sendLeftCountLW;
    CGFloat sendLeftCountLY = preY;
    CGFloat sendLeftCountLH = 30;
    self.sendLeftCountL.frame = CGRectMake(sendLeftCountLX, sendLeftCountLY, sendLeftCountLW, sendLeftCountLH);
    
    self.sendLeftCountL.center = CGPointMake(self.sendLeftCountL.center.x, self.sendBtn.center.y);
    
}

- (UIButton *)preBtn {
    if (!_preBtn) {
        UIButton *pre = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:pre];
        _preBtn = pre;
        [pre setTitle:@"预览" forState:UIControlStateNormal];
        pre.titleLabel.font = [UIFont systemFontOfSize:13];
        [pre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pre addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        pre.tag = 1;
    }
    return _preBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:send];
        _sendBtn = send;
        [send setTitle:@"完成" forState:UIControlStateNormal];
        [send setTitleColor:[UIColor colorWithRed:0.09f green:0.73f blue:0.18f alpha:1.00f] forState:UIControlStateNormal];
        send.titleLabel.font = [UIFont systemFontOfSize:13];
        [send addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        send.tag = 2;
    }
    return _sendBtn;
}

- (UILabel *)sendLeftCountL {
    if (!_sendLeftCountL) {
        UILabel *sendLeftCount = [[UILabel alloc] init];
        [self addSubview:sendLeftCount];
        _sendLeftCountL = sendLeftCount;
        sendLeftCount.textColor = [UIColor whiteColor];
        sendLeftCount.font = [UIFont boldSystemFontOfSize:13];
        sendLeftCount.textAlignment = NSTextAlignmentCenter;
        sendLeftCount.backgroundColor = [UIColor colorWithRed:0.09f green:0.73f blue:0.18f alpha:1.00f];
        sendLeftCount.layer.cornerRadius = 15.0;
        sendLeftCount.layer.masksToBounds = YES;
        sendLeftCount.layer.shouldRasterize = YES;
    }
    return _sendLeftCountL;
}


@end
