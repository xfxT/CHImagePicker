//
//  CHImageListBottomToolBar.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  item的类型
 */
typedef NS_ENUM(NSUInteger, CHImageListBottomToolBarItemType) {
    /**
     *  预览
     */
    CHImageListBottomToolBarItemTypePreView,
    /**
     *  完成
     */
    CHImageListBottomToolBarItemTypeSend,
};

@class CHImageListBottomToolBar;

/**
 *  点击item的回调类型
 *
 *  @param toolBar  单个相册相片列表的底部选项栏
 *  @param itemType 单个相册相片列表的底部选项栏item
 */
typedef void(^CHImageListBottomToolBarItemClickHandle)(CHImageListBottomToolBar *toolBar, CHImageListBottomToolBarItemType itemType);

@interface CHImageListBottomToolBar : UIView

/**
 *  已经选择的相片的数量
 */
@property (nonatomic) NSInteger count;
- (void)setCount:(NSInteger)count animated:(BOOL)animated;

/**
 *  点击item的回调
 */
@property (nonatomic, copy) CHImageListBottomToolBarItemClickHandle itemClickHandle;

@property (nonatomic) BOOL hiddenPreViewItem;

/**
 *  构造方法
 *
 *  @return 单个相册相片列表的底部选项栏实例对象
 */
+ (instancetype)toolBar;

@end
