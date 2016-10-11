//
//  CHImageListViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageListViewController.h"
#import "CHImageListViewCell.h"
#import "CHImageManager.h"
#import "CHImageBrowserViewController.h"
#import "CHImageListBottomToolBar.h"
#import "CHImagePickerViewController.h"
#import "CHAssetModel.h"
#import "CHAlbumModel.h"

@interface CHImageListViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CHImageBrowserViewControllerDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *assetModelArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) CHImageListBottomToolBar *toolBar;

@end

static NSString *const cellID = @"cellID";
@implementation CHImageListViewController

- (instancetype)initWithCurrentIndex:(NSInteger)currentIndex {
    if (self = [super init]) {
        _currentIndex = currentIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([CHImageListViewCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:cellID];
    
    // 获取本相册所有的相片 然后展示
    [[CHImageManager defaultManager] allAssetModelsWithAlbumModel:self.albumModel captureHandle:^(CHImageManager *defaultManager, NSArray<CHAssetModel *> *assetModelArray) {
        
        // 当前界面的所有图片数据模型
        self.assetModelArray = assetModelArray;
        
        // 筛选已经选择过的
        CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
        // PHPhotoKit
        NSMutableArray *selectAssets = [NSMutableArray new];
        // AL
        NSMutableArray *selectAssetURLs = [NSMutableArray new];
        
        // 遍历已经选中的,看看是否是否存在
        [self.albumModel.selectedAssetModelArray removeAllObjects];
        
        for (int i = 0; i < imagePickerViewController.assetModelArray.count; i++) {
            CHAssetModel *assetModel = imagePickerViewController.assetModelArray[i];
            id asset = assetModel.asset;
            if ([asset isKindOfClass:[PHAsset class]]) {
                [selectAssets addObject:asset];
            } else if ([asset isKindOfClass:[ALAsset class]]) {
                ALAsset *alAsset = (ALAsset *)assetModel.asset;
                [selectAssetURLs addObject:[alAsset valueForProperty:ALAssetPropertyURLs]];
            }
        }
        
        for (CHAssetModel *assetModel in assetModelArray) {
            id asset = assetModel.asset;
            if ([asset isKindOfClass:[PHAsset class]]) {
                if ([selectAssets containsObject:asset]) {
                    assetModel.selectType = CHAssetModelSelectTypeSelected;
                    [self.albumModel.selectedAssetModelArray addObject:assetModel];
                } else {
                    assetModel.selectType = CHAssetModelSelectTypeUnSelect;
                }
            } else if ([asset isKindOfClass:[ALAsset class]]) {
                ALAsset *alAsset = (ALAsset *)assetModel.asset;
                if ([selectAssetURLs containsObject:[alAsset valueForProperty:ALAssetPropertyURLs]]) {
                    assetModel.selectType = CHAssetModelSelectTypeSelected;
                    [self.albumModel.selectedAssetModelArray addObject:assetModel];
                } else {
                    assetModel.selectType = CHAssetModelSelectTypeUnSelect;
                }
            }
        }
        
        [self.collectionView reloadData];
    }];
    
    self.toolBar.count = self.albumModel.selectedAssetModelsCount;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 50);
    self.toolBar.frame = CGRectMake(0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, self.view.frame.size.width, 50);
}

- (void)gotoPreViewWithIndex:(NSInteger)index {
    CHImageBrowserViewController *browserViewController = [[CHImageBrowserViewController alloc] init];
    browserViewController.assetModelArray = self.assetModelArray;
    browserViewController.currentIndex = index;
    browserViewController.delegate = self;
    [self.navigationController pushViewController:browserViewController animated:YES];
}

- (void)callBackHandleWithAssetModel:(CHAssetModel *)assetM {
    [self handleAssetModel:assetM];
}

- (void)handleAssetModel:(CHAssetModel *)assetM {
    CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
    
    // 处理选中图片
    NSMutableArray *selectAssetModelArray = imagePickerViewController.assetModelArray.mutableCopy;
    NSMutableArray *selectAssets = [NSMutableArray new];
    NSMutableArray *selectAssetURLs = [NSMutableArray new];
    
    if (imagePickerViewController.assetModelArray.count == 0) {
        [imagePickerViewController.assetModelArray addObject:assetM];
    } else {
        for (int i = 0; i < selectAssetModelArray.count; i++) {
            CHAssetModel *assetModel = selectAssetModelArray[i];
            id asset = assetModel.asset;
            if ([asset isKindOfClass:[PHAsset class]]) {
                [selectAssets addObject:asset];
                if ([selectAssets containsObject:assetM.asset] && assetM.selectType == CHAssetModelSelectTypeUnSelect) {
                    [imagePickerViewController.assetModelArray removeObject:assetModel];
                    [selectAssetModelArray removeObject:assetModel];
                    [selectAssets removeObject:asset];
                } else {
                    if (assetM.selectType == CHAssetModelSelectTypeSelected) {
                        if (![imagePickerViewController.assetModelArray containsObject:assetM]) {
                            [imagePickerViewController.assetModelArray addObject:assetM];
                        }
                    }
                }
            } else if ([asset isKindOfClass:[ALAsset class]]) {
                ALAsset *alAsset = (ALAsset *)asset;
                [selectAssetURLs addObject:[alAsset valueForProperty:ALAssetPropertyURLs]];
                if ([selectAssetURLs containsObject:[alAsset valueForProperty:ALAssetPropertyURLs]] && assetM.selectType == CHAssetModelSelectTypeUnSelect) {
                    [imagePickerViewController.assetModelArray removeObject:assetModel];
                    [selectAssetModelArray removeObject:assetModel];
                    [selectAssetURLs removeObject:[alAsset valueForProperty:ALAssetPropertyURLs]];
                } else {
                    if (assetM.selectType == CHAssetModelSelectTypeSelected) {
                        if (![imagePickerViewController.assetModelArray containsObject:assetM]) {
                            [imagePickerViewController.assetModelArray addObject:assetM];
                        }
                    }
                }
            }
        }
    }
    
    NSLog(@"assetModelArray=%@", imagePickerViewController.assetModelArray);
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1. 创建cell
    CHImageListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    // 2. 设置数据
    cell.assetModel = self.assetModelArray[indexPath.item];
    
    __weak typeof(self) weakSelf = self;
    cell.selectHandle = ^(CHImageListViewCell *cell, CHAssetModel *assetModel) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf callBackHandleWithAssetModel:assetModel];
        if (assetModel.selectType == CHAssetModelSelectTypeUnSelect) {
            if ([strongSelf.albumModel.selectedAssetModelArray containsObject:assetModel]) {
                [strongSelf.albumModel.selectedAssetModelArray removeObject:assetModel];
            }
        } else if (assetModel.selectType == CHAssetModelSelectTypeSelected) {
            if (![strongSelf.albumModel.selectedAssetModelArray containsObject:assetModel]) {
                [strongSelf.albumModel.selectedAssetModelArray addObject:assetModel];
            }
        }
        strongSelf.albumModel.selectedAssetModelsCount += assetModel.selectType == CHAssetModelSelectTypeUnSelect ? (-1) : 1;
        strongSelf.toolBar.count = strongSelf.albumModel.selectedAssetModelsCount;
        [[CHImageManager defaultManager] imagesDataLengthWithAssetModels:strongSelf.albumModel.selectedAssetModelArray completionHandle:^(CHImageManager *defaultManager, CGFloat dataLength) {
            strongSelf.toolBar.dataLength = dataLength;
        }];
    };
    
    // 3. 返回cell
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoPreViewWithIndex:indexPath.item];
}

#pragma mark - CHImageBrowserViewControllerDelegate
- (void)imageBrowserViewController:(CHImageBrowserViewController *)imageBrowserViewController assetModelSelectTypeDidChange:(CHAssetModel *)assetModel index:(NSInteger)index {
    
    CHAssetModel *currentAssetModel = self.assetModelArray[index];
    currentAssetModel.selectType = assetModel.selectType;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    [self handleAssetModel:assetModel];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat itemWH = self.view.frame.size.width / 3.0;
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSArray *)assetModelArray {
    if (!_assetModelArray) {
        _assetModelArray = [NSArray array];
    }
    return _assetModelArray;
}

- (CHImageListBottomToolBar *)toolBar {
    if (!_toolBar) {
        CHImageListBottomToolBar *toolBar = [CHImageListBottomToolBar toolBar];
        [self.view addSubview:toolBar];
        _toolBar = toolBar;
        __weak typeof(self) weakSelf = self;
        toolBar.itemClickHandle = ^(CHImageListBottomToolBar *toolBar, CHImageListBottomToolBarItemType itemType) {
            __strong typeof(self) strongSelf = weakSelf;
            switch (itemType) {
                case CHImageListBottomToolBarItemTypePreView: {
                    [self gotoPreViewWithIndex:0];
                }
                    break;
                    
                case CHImageListBottomToolBarItemTypeFullImage: {
                    [[CHImageManager defaultManager] imagesDataLengthWithAssetModels:strongSelf.albumModel.selectedAssetModelArray completionHandle:^(CHImageManager *defaultManager, CGFloat dataLength) {
                        strongSelf.toolBar.dataLength = dataLength;
                    }];
                }
                    break;
                    
                case CHImageListBottomToolBarItemTypeDone: {
                    if ([strongSelf.delegate respondsToSelector:@selector(imageListViewControllerDidFinishSelect:)]) {
                        [strongSelf.delegate imageListViewControllerDidFinishSelect:strongSelf];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
    return _toolBar;
}
@end
