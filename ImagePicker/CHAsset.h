//
//  CHAsset.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  相片选中类型
 */
typedef NS_ENUM(NSUInteger, CHAssetSelectType) {
    /**
     *  未选中
     */
    CHAssetSelectTypeUnSelect = 0,
    /**
     *  选中
     */
    CHAssetSelectTypeSelected,
};
@interface CHAsset : NSObject

/**
 *  相片的asset，是PHAsset对象或者是ALAsset对象
 */
@property (nonatomic, strong) id asset;
/**
 *  相片选中类型
 */
@property (nonatomic, assign) CHAssetSelectType selectType;
@end
