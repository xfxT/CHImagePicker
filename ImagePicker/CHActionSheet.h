//
//  CHActionSheet.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHActionSheet;
typedef void(^CHActionSheetItemClickHandle)(CHActionSheet *actionSheet, NSInteger currentIndex, NSString *title);
@interface CHActionSheet : UIView


/**
 *  初始化
 *
 *  @param cancelTitle 取消
 *  @param alertTitle  提示文字
 *  @param title       子控件文本
 */
+ (instancetype)actionSheetWithCancelTitle:(NSString *)cancelTitle alertTitle:(NSString *)alertTitle SubTitles:(NSString *)title,...NS_REQUIRES_NIL_TERMINATION;

- (void)setActionSheetItemClickHandle:(CHActionSheetItemClickHandle)itemClickHandle;

- (void)setActionSheetDismissItemClickHandle:(CHActionSheetItemClickHandle)dismissItemClickHandle;

- (void)show;
@end
