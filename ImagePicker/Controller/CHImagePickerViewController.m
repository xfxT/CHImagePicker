//
//  CHImagePickerViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImagePickerViewController.h"
#import "CHAlbumListViewController.h"
#import "CHAlbumManager.h"
#import "CHAsset.h"
#import "CHImage.h"

@implementation CHImagePickerViewController

+ (void)initialize {
    [super initialize];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    NSMutableDictionary *atts = [NSMutableDictionary new];
    atts[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:atts forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = YES;
    self.navigationBar.barStyle = UIBarStyleBlack;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (NSArray *)imageArray {
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (CHAsset *assetModel in self.assetModelArray) {
        [[CHAlbumManager defaultManager] imageWithAssetModel:assetModel imageWidth:[UIScreen mainScreen].bounds.size.width captureHandle:^(CHAlbumManager *defaultManager, CHImage *image) {
            if (image.image) {
                [mutableArray addObject:image];
            }
        }];
    }
    return mutableArray.copy;
}

- (NSMutableArray *)assetModelArray {
    if (!_assetModelArray) {
        _assetModelArray = [NSMutableArray new];
    }
    return _assetModelArray;
}

- (instancetype)init {
    self = [super initWithRootViewController:[[CHAlbumListViewController alloc] init]];
    if (self) {
        self.maximumCount = 9;
    }
    return self;
}

- (void)setMaximumCount:(NSInteger)maximumCount {
    _maximumCount = maximumCount;
    [CHAlbumManager defaultManager].maximumCount = maximumCount;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        UIImage *image = [UIImage imageNamed:@"back_white"];
        [btn setImage:image forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 60, 35);
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    [super pushViewController:viewController animated:animated];
}
@end
