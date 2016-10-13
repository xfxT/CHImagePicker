//
//  CHImagePickerViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h> 

@class CHImagePickerViewController, CHAsset;

@protocol CHImagePickerViewControllerDelegate <NSObject>
/**
 *  选择相片完成回调事件
 *
 *  @param imagePickerViewController 相片选择控制器
 *  @param imageArray                相片数组
 */
- (void)imagePickerViewController:(CHImagePickerViewController *)imagePickerViewController didFinishSelectWithImageArray:(NSArray <UIImage *>*)imageArray;

/**
 *  取消选择相片回调事件
 *
 *  @param imagePickerViewController 相片选择控制器
 */
- (void)imagePickerViewControllerDidCancel:(CHImagePickerViewController *)imagePickerViewController;
@end

@interface CHImagePickerViewController : UINavigationController

/**
 *  最大可选相片数量 默认是9
 */
@property (nonatomic, assign) NSInteger maximumCount;

@property (nonatomic, weak) id <CHImagePickerViewControllerDelegate> imagePickerDelegate;

/**
 *  相片数据模型数组
 */
@property (nonatomic, strong) NSMutableArray <CHAsset *>*assetModelArray;

/**
 *  UIImage实例对象数组
 */
@property (nonatomic, strong, readonly) NSArray <UIImage *>*imageArray;

@end
