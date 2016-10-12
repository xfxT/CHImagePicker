//
//  CHImageListViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerBaseViewController.h"

@class CHAlbum, CHImageListViewController;
@protocol CHImageListViewControllerDelegate <NSObject>
/**
 *  某个相册中的点击了选择完成
 *
 *  @param imageListViewController 某个相册的相片列表控制器
 */
- (void)imageListViewControllerDidFinishSelect:(CHImageListViewController *)imageListViewController;
@end

@interface CHImageListViewController : CHImagePickerBaseViewController

/**
 *  构造方法
 *
 *  @param currentIndex 相册所在的索引
 *
 *  @return 相片列表控制器实例对象
 */
- (instancetype)initWithCurrentIndex:(NSInteger)currentIndex;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, weak) id <CHImageListViewControllerDelegate> delegate;

/**
 *  某个相册的数据模型
 */
@property (nonatomic, strong) CHAlbum *albumModel;

@end
