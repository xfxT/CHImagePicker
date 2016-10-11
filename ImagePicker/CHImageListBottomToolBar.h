//
//  CHImageListBottomToolBar.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CHImageListBottomToolBarItemType) {
    CHImageListBottomToolBarItemTypePreView,
    CHImageListBottomToolBarItemTypeFullImage,
    CHImageListBottomToolBarItemTypeDone,
};
@class CHImageListBottomToolBar;

typedef void(^CHImageListBottomToolBarItemClickHandle)(CHImageListBottomToolBar *toolBar, CHImageListBottomToolBarItemType itemType);
@interface CHImageListBottomToolBar : UIView
+ (instancetype)toolBar;
@property (nonatomic, assign) CGFloat dataLength;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) CHImageListBottomToolBarItemClickHandle itemClickHandle;
@end
