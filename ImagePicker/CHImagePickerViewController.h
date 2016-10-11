//
//  CHImagePickerViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHImagePickerConstant.h"

@class CHImagePickerViewController;


@protocol CHImagePickerViewControllerDelegate <NSObject>
- (void)imagePickerViewController:(CHImagePickerViewController *)imagePickerViewController didFinishSelectWithImageArray:(NSArray <UIImage *>*)imageArray;
- (void)imagePickerViewControllerDidCancel:(CHImagePickerViewController *)imagePickerViewController;
@end

@interface CHImagePickerViewController : UINavigationController
@property (nonatomic, weak) id <CHImagePickerViewControllerDelegate> imagePickerDelegate;
@property (nonatomic, strong) NSMutableArray *assetModelArray;

@property (nonatomic) CHImagePickerViewControllerSourceType sourceType;
@end
