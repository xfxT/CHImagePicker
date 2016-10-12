//
//  CHImageBrowserViewController.m
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "CHImageBrowserViewController.h"
#import "CHImageBrowserViewCell.h"

@interface CHImageBrowserViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@end

static NSString *const cellID = @"cellID";

@implementation CHImageBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"大图预览";
    [self.collectionView registerClass:[CHImageBrowserViewCell class] forCellWithReuseIdentifier:cellID];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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
    };
    
    // 3. 返回cell
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = self.view.frame.size;
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
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
