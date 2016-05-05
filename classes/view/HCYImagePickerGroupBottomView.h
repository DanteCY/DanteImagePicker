//
//  DtImagePickerBottomView.h
//  DanteImagePicker
//
//  Created by hcy on 15/11/5.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HCYImagePickerCollector,HCYImagePickerGroupBottomView;
@protocol HCYImagePickerGroupBottomViewDelegate <NSObject>

@optional
-(void)groupBottomView:(HCYImagePickerGroupBottomView *)view clickedSendBtn:(UIButton *)btn;

@end

@interface HCYImagePickerGroupBottomView : UIView
-(instancetype)initWithCollector:(HCYImagePickerCollector *)collector;
-(void)setselectItemCount:(NSInteger)count;
@property(weak,nonatomic) id<HCYImagePickerGroupBottomViewDelegate> delegate;
@end
