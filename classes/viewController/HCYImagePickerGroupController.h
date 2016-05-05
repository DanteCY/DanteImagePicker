//
//  DtImagePickerGroupController.h
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCYImagePickerHeader.h"
@class HCYImagePickerGroupController;
@protocol HCYImagePickerGroupControllerDelegate <NSObject>
-(void)groupControllerSendBtnClicked:(HCYImagePickerGroupController *)controller;
@end

/**
 *  图片选择是单相册
 */
@interface HCYImagePickerGroupController : UIViewController
/**
 *  单相册图片选择器
 *
 *  @param group      相册

 *
 *  @return 
 */
-(instancetype)initWithListItem:(id<HCYImagePickerListItem> )item;

@property(weak,nonatomic)id<HCYImagePickerGroupControllerDelegate> delegate;
@end
