//
//  CHImageListViewController.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerBaseViewController.h"

@class CHAlbumModel, CHImageListViewController;
@protocol CHImageListViewControllerDelegate <NSObject> 
- (void)imageListViewControllerDidFinishSelect:(CHImageListViewController *)imageListViewController;
@end

@interface CHImageListViewController : CHImagePickerBaseViewController

- (instancetype)initWithCurrentIndex:(NSInteger)currentIndex;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic, weak) id <CHImageListViewControllerDelegate> delegate;
@property (nonatomic, strong) CHAlbumModel *albumModel;

@end
