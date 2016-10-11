//
//  CHAssetModel.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHImagePickerConstant.h"

typedef NS_ENUM(NSUInteger, CHAssetModelSelectType) {
    CHAssetModelSelectTypeUnSelect = 0,
    CHAssetModelSelectTypeSelected,
};
@interface CHAssetModel : NSObject

@property (nonatomic, strong) id asset; 
@property (nonatomic, assign) CHAssetModelSelectType selectType;
@property (nonatomic, copy) NSString *timeLength;
@property (nonatomic, assign) CHImagePickerViewControllerSourceType currentSourceType;
@end
