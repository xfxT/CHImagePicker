//
//  UIImage+CHAddition.h
//  ImagePicker
//
//  Created by Charles on 16/10/11.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CHAddition)

@property (nonatomic, strong, readonly) UIImage *fixedOrientationImage;

- (UIImage *)newImageWithTargetSize:(CGSize)targetSize;

@end
