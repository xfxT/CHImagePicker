//
//  CHAlbumListViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHAlbumListViewController.h"
#import "CHAlbumManager.h"
#import "CHAlbumListViewCell.h"
#import "CHImageListViewController.h"
#import "CHImagePickerViewController.h"
#import "CHAsset.h"
#import "CHAlbum.h"

@interface CHAlbumListViewController () <CHImageListViewControllerDelegate>
@property (nonatomic, strong) NSArray *albumModelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@end
static NSString * const reuseIdentifier = @"Cell";
@implementation CHAlbumListViewController

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray new];
    }
    return _imageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([CHAlbumListViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:reuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.title = @"相册列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CHAlbumManager defaultManager].authorizationStatusAuthorized) {
        // 获取所有的相册信息
        CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
        [[CHAlbumManager defaultManager] allAlbumModelsWithCaptureHandle:^(CHAlbumManager *defaultManager, NSArray<CHAlbum *> *albumModelArray) {
            self.albumModelArray = albumModelArray;
            for (CHAlbum *albumModel in self.albumModelArray) {
                NSMutableArray *selectedAssets = [NSMutableArray new];
                NSMutableArray *selectedAssetURLs = [NSMutableArray new];
                for (CHAsset *assetModel in imagePickerViewController.assetModelArray) {
                    if ([assetModel.asset isKindOfClass:[PHAsset class]]) {
                        [selectedAssets addObject:assetModel.asset];
                    } else {
                        ALAsset *alAsset = (ALAsset *)assetModel.asset;
                        [selectedAssetURLs addObject:[alAsset valueForProperty:ALAssetPropertyURLs]];
                    }
                }
                
                // 获取单个相册的图片数组, 遍历图片数组，然后看看总的选中的中有没有该图片，如果有的话，那么标记
                [[CHAlbumManager defaultManager] allAssetModelsWithAlbumModel:albumModel captureHandle:^(CHAlbumManager *defaultManager, NSArray<CHAsset *> *assetModelArray) {
                    for (CHAsset *assetModel in assetModelArray) {
                        id asset = assetModel.asset;
                        if ([asset isKindOfClass:[PHAsset class]]) {
                            if ([selectedAssets containsObject:asset]) {
                                albumModel.selectedAssetModelsCount += 1;
                            }
                        } else if ([asset isKindOfClass:[ALAsset class]]) {
                            ALAsset *alAsset = (ALAsset *)asset;
                            id value = [alAsset valueForProperty:ALAssetPropertyURLs];
                            if ([selectedAssetURLs containsObject:value]) {
                                albumModel.selectedAssetModelsCount += 1;
                            }
                        }
                    }
                }];
            }
            [self.tableView reloadData];
        }];
    } else {
        NSString *tipTextWhenNoPhotosAuthorization;
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
        NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:tipTextWhenNoPhotosAuthorization preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)dismiss { 
    CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
    if ([imagePickerViewController.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [imagePickerViewController.imagePickerDelegate imagePickerViewControllerDidCancel:imagePickerViewController];
    }
    
    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    // 1. 创建cell
    CHAlbumListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // 2. 设置数据
    CHAlbum *albumModel = self.albumModelArray[indexPath.row];
    cell.albumModel = albumModel;
    
    // 3. 返回cell
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHImageListViewController *imageListViewController = [[CHImageListViewController alloc] initWithCurrentIndex:indexPath.row];
    CHAlbum *albumModel = self.albumModelArray[indexPath.row];
    imageListViewController.delegate = self;
    imageListViewController.albumModel = albumModel;
    imageListViewController.navigationItem.title = albumModel.albumName;
    [self.navigationController pushViewController:imageListViewController animated:YES];
}

- (void)imageListViewController:(CHImageListViewController *)imageListViewController didChangeSelectImageCountWithAlbumModel:(CHAlbum *)albumModel {
    
    NSInteger index = imageListViewController.currentIndex;
    NSMutableArray *mutableModels = self.albumModelArray.mutableCopy;
    [mutableModels replaceObjectAtIndex:index withObject:albumModel];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)imageListViewControllerDidFinishSelect:(CHImageListViewController *)imageListViewController {
    CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)imageListViewController.navigationController;
    
    NSArray *array = imagePickerViewController.imageArray;
    if ([imagePickerViewController.imagePickerDelegate respondsToSelector:@selector(imagePickerViewController:didFinishSelectWithImageArray:)]) {
        [imagePickerViewController.imagePickerDelegate imagePickerViewController:imagePickerViewController didFinishSelectWithImageArray:array];
    }
    
    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
    
}
@end
