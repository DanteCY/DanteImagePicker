//
//  DtImagePickerGroupCell.m
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerGroupCell.h"
#import "HCYImagePickerContentItem.h"
#import "UIView+DanteImagePicker.h"
#import <AssetsLibrary/ALAsset.h>
#import "HCYImagePickerCollector.h"
@interface HCYImagePickerGroupCell()<HCYImagePickerCollectorDelegate>

@property(strong,nonatomic)UIImageView *imageView;
//照片独有
@property(strong,nonatomic)UIButton *stateBtn;
//视频独有
@property(strong,nonatomic)UIImageView *videoBottomImaeView;
@property(strong,nonatomic)UIImageView *videoIconImageView;

@property(copy,nonatomic)NSString *title;

@property(strong,nonatomic)id<HCYImagePickerContentItem> item;
@end
@implementation HCYImagePickerGroupCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _imageView=[UIImageView new];
        _imageView.contentMode=UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds=YES;
        [self.contentView addSubview:_imageView];
        _stateBtn=[UIButton new];
        [_stateBtn setBackgroundImage:[UIImage imageNamed:@"hcyimagepicker_overlay_uncheck"] forState:UIControlStateNormal];
        [_stateBtn setBackgroundImage:[UIImage imageNamed:@"hcyimagepicker_overlay_checked"] forState:UIControlStateSelected];
        [self.contentView addSubview:_stateBtn];
        [_stateBtn addTarget:self action:@selector(stateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [[HCYImagePickerCollector sharedCollector] addDelegate:self];
      }
    return self;
}
-(void)dealloc{
    [[HCYImagePickerCollector sharedCollector] removeDelegate:self];
}
-(void)refreshWithItem:(id<HCYImagePickerContentItem>)item{
    _item=item;
    _imageView.image=nil;
    [item thumbImageWithCompletion:^(id<HCYImagePickerContentItem> data, UIImage *result) {
        if ([data isEqual:_item]) {
            dispatch_async_main_safe(^{
                _imageView.image=result;
                [self setNeedsDisplay];
            });
        }
    }];
}
#pragma mark events
-(void)stateBtnClicked:(UIButton *)btn{
    btn.selected=!btn.selected;
    if ([_deleate respondsToSelector:@selector(cell:selected:)]) {
        [_deleate cell:self selected:btn.selected];
    }
}
#pragma mark collectorDelegate
-(void)collector:(HCYImagePickerCollector *)collector addItem:(id)item{
    if (item==_item && ![_stateBtn isSelected]) {
        _stateBtn.selected=YES;
    }
}
-(void)collector:(HCYImagePickerCollector *)collector removeItem:(id)item{
    if (item==_item && [_stateBtn isSelected]) {
        _stateBtn.selected=NO;
    }
}
#pragma refresh UI
-(void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame=self.bounds;
    static CGFloat offset=6;
    _stateBtn.size=CGSizeMake(25, 25);
    _stateBtn.right=self.width-offset;
    _stateBtn.bottom=self.height-offset;
}


@end
