//
//  DtImagePickerListCell.h
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCYImagePickerHeader.h"
@interface HCYImagePickerListCell : UITableViewCell
-(void)refreshData:(id<HCYImagePickerListItem>)data isLast:(BOOL)isLast;
@end
