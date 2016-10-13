//
//  CHImageBrowserViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageBrowserViewController.h"
#import "CHImageBrowserViewCell.h"
#import "CHImageListBottomToolBar.h"
#import "CHImagePickerViewController.h"

@interface CHImageBrowserViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) CHImageListBottomToolBar *toolBar;
@end

static NSString *const cellID = @"cellID";

@implementation CHImageBrowserViewController
- (CHImageListBottomToolBar *)toolBar {
    if (!_toolBar) {
        CHImageListBottomToolBar *toolBar = [CHImageListBottomToolBar toolBar];
        [self.view addSubview:toolBar];
        _toolBar = toolBar;
        toolBar.hiddenPreViewItem = YES;
        toolBar.backgroundColor = [UIColor blackColor];
        toolBar.itemClickHandle = ^(CHImageListBottomToolBar *toolBar, CHImageListBottomToolBarItemType itemType) {
            switch (itemType) {
                case CHImageListBottomToolBarItemTypeSend: {
                    CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
                    NSArray *array = imagePickerViewController.imageArray;
                    if ([imagePickerViewController.imagePickerDelegate respondsToSelector:@selector(imagePickerViewController:didFinishSelectWithImageArray:)]) {
                        [imagePickerViewController.imagePickerDelegate imagePickerViewController:imagePickerViewController didFinishSelectWithImageArray:array];
                    }
                    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
    return _toolBar;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 50);
    self.toolBar.frame = CGRectMake(0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, self.view.frame.size.width, 50);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"大图预览";
    [self.collectionView registerClass:[CHImageBrowserViewCell class] forCellWithReuseIdentifier:cellID];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    CHImagePickerViewController *imagePickerViewController = (CHImagePickerViewController *)self.navigationController;
    self.toolBar.count = imagePickerViewController.assetModelArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1. 创建cell
    CHImageBrowserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    // 2. 设置数据
    cell.assetModel = self.assetModelArray[indexPath.item];
    
    __weak typeof(self) weakself = self;
    cell.selectHandle = ^(CHImageBrowserViewCell *cell, CHAsset *assetModel) {
        __strong typeof(self) strongSelf = weakself;
        if ([weakself.delegate respondsToSelector:@selector(imageBrowserViewController:assetModelSelectTypeDidChange:index:)]) {
            NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
            [weakself.delegate imageBrowserViewController:strongSelf assetModelSelectTypeDidChange:assetModel index:indexPath.item];
        }
        
        NSInteger newCount = strongSelf.toolBar.count;
        if (assetModel.selectType == CHAssetSelectTypeUnSelect) {
            newCount = newCount - 1;
        } else {
            newCount = newCount + 1;
        }
        strongSelf.toolBar.count = newCount;
    };
    
    // 3. 返回cell
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 50) collectionViewLayout:layout];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor blackColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
