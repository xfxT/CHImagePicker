//
//  ViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "ViewController.h"
#import "CHImagePickerViewController.h"
#import "CHActionSheet.h"

@interface ViewController () <CHImagePickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"获取图片";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CHActionSheet *actionSheet = [CHActionSheet actionSheetWithCancelTitle:@"取消" alertTitle:@"选取图片或视频" SubTitles:@"拍照", @"从相册中获取图片", @"从相册中获取视频", nil];
    [actionSheet setActionSheetItemClickHandle:^(CHActionSheet *actionSheet, NSInteger currentIndex, NSString *title) {
        if (currentIndex == 0) {
            // 拍照
        } else if (currentIndex == 1) {
            // 从相册中获取图片
            CHImagePickerViewController *imagePickerViewController = [[CHImagePickerViewController alloc] init];
            imagePickerViewController.imagePickerDelegate = self;
            [self.navigationController presentViewController:imagePickerViewController animated:YES completion:nil];
        } else {
            // 从相册中获取视频
        }
    }];
    [actionSheet show];
}

- (void)imagePickerViewController:(CHImagePickerViewController *)imagePickerViewController didFinishSelectWithImageArray:(NSArray<UIImage *> *)imageArray {
    NSLog(@"didFinishSelectWithImageArray : %@", imageArray);
}

- (void)imagePickerViewControllerDidCancel:(CHImagePickerViewController *)imagePickerViewController {
    
}
@end
