//
//  DtImagePickerGroupCell.h
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCYImagePickerHeader.h"
@class HCYImagePickerContentItem,HCYImagePickerGroupCell;
@protocol HCYImagePickerGroupCellDelegate <NSObject>
@optional
/**
 *  选择框被点击
 *
 *  @param cell   单元格
 *  @param select 点击后的状态
 */
-(void)cell:(HCYImagePickerGroupCell *)cell selected:(BOOL)select;
@end


@interface HCYImagePickerGroupCell : UICollectionViewCell
-(void)refreshWithItem:(id<HCYImagePickerContentItem>)item;
@property(weak,nonatomic)id<HCYImagePickerGroupCellDelegate> deleate;

@end
