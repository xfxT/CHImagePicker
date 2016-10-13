//
//  CHImageBrowserViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerBaseViewController.h"

@class CHImageBrowserViewController, CHAsset;

@protocol CHImageBrowserViewControllerDelegate <NSObject>
- (void)imageBrowserViewController:(CHImageBrowserViewController *)imageBrowserViewController
     assetModelSelectTypeDidChange:(CHAsset *)assetModel
                             index:(NSInteger)index;
@end

@interface CHImageBrowserViewController: CHImagePickerBaseViewController

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) NSArray <CHAsset *>*assetModelArray; 
@property (nonatomic, weak) id <CHImageBrowserViewControllerDelegate> delegate;

@end
