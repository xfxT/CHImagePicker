//
//  CHImagePickerViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHImagePickerConstant.h"

@class CHImagePickerViewController, CHAssetModel;
@protocol CHImagePickerViewControllerDelegate <NSObject>
- (void)imagePickerViewController:(CHImagePickerViewController *)imagePickerViewController didFinishSelectWithImageArray:(NSArray <UIImage *>*)imageArray;
- (void)imagePickerViewControllerDidCancel:(CHImagePickerViewController *)imagePickerViewController;
@end

@interface CHImagePickerViewController : UINavigationController

// default is 1
@property (nonatomic, assign) NSInteger maximumCount;

// default is CHImagePickerViewControllerSourceTypeImage
@property (nonatomic) CHImagePickerViewControllerSourceType sourceType;

@property (nonatomic, weak) id <CHImagePickerViewControllerDelegate> imagePickerDelegate;

@property (nonatomic, strong) NSMutableArray <CHAssetModel *>*assetModelArray;

// the result or get the result from the imagePickerDelegate
@property (nonatomic, strong, readonly) NSArray <UIImage *>*imageArray;

@end
