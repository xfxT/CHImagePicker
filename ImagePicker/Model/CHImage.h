//
//  CHImage.h
//  ImagePicker
//
//  Created by Charles on 16/10/12.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDictionary *imageInfo;
@end
