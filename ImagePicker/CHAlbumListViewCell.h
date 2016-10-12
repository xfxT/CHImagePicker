//
//  CHAlbumListViewCell.h
//  ImagePicker
//
//  Created by Charles on 16/10/10.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHAlbum;
@interface CHAlbumListViewCell : UITableViewCell
@property (nonatomic, strong) CHAlbum *albumModel;
@end
