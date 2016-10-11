//
//  CHImageBrowserViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerBaseViewController.h"

@class CHImageBrowserViewController;
@class CHAssetModel;
@protocol CHImageBrowserViewControllerDelegate <NSObject>
- (void)imageBrowserViewController:(CHImageBrowserViewController *)imageBrowserViewController assetModelSelectTypeDidChange:(CHAssetModel *)assetModel index:(NSInteger)index;
@end

@interface CHImageBrowserViewController: CHImagePickerBaseViewController
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) NSArray <CHAssetModel *>*assetModelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, weak) id <CHImageBrowserViewControllerDelegate> delegate;
@end
