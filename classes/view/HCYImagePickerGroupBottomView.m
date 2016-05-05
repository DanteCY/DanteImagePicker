//
//  DtImagePickerBottomView.m
//  DanteImagePicker
//
//  Created by hcy on 15/11/5.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerGroupBottomView.h"
#import "UIView+DanteImagePicker.h"
@interface HCYImagePickerGroupBottomView()
@property(strong,nonatomic)UIImageView *bgImageView;
@property(strong,nonatomic)UIButton *previewBtn;
@property(strong,nonatomic)UIButton *editBtn;
@property(strong,nonatomic)UIButton *sendBtn;
@end
@implementation HCYImagePickerGroupBottomView

-(instancetype)init{
    if (self=[super init]) {
     [self setSubviews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     [self setSubviews];   
    }
    return self;
}
-(void)setSubviews{
    _bgImageView=[[UIImageView alloc] init];
    _bgImageView.image=[UIImage imageNamed:@"hcyimagepicker_bg"];
    [self addSubview:_bgImageView];
//    
//    UIImage *disableImage=[UIImage imageNamed:@"hcyimagepicker_btn_preview_disable"];
//    UIImage *normalImage=[UIImage imageNamed:@"hcyimagepicker_btn_preview_normal"];
//    UIImage *highImage=[UIImage imageNamed:@"hcyimagepicker_btn_preview_pressed"];
//    UIColor *disableTextColor=[UIColor lightGrayColor];
//    UIColor *normalTextColor=[UIColor blackColor];
    UIFont *font=[UIFont systemFontOfSize:13.f];
//    _previewBtn=[UIButton new];
//    [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
//    [_previewBtn setBackgroundImage:disableImage forState:UIControlStateDisabled];
//    [_previewBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
//    [_previewBtn setBackgroundImage:highImage forState:UIControlStateHighlighted];
//    [_previewBtn setTitleColor:disableTextColor forState:UIControlStateDisabled];
//    [_previewBtn setTitleColor:normalTextColor forState:UIControlStateNormal];
//    _previewBtn.titleLabel.font=font;
//    
//    [self addSubview:_previewBtn];
//    
//    _editBtn=[UIButton new];
//    [_editBtn setTitle:@"美化" forState:UIControlStateNormal];
//    [_editBtn setBackgroundImage:disableImage forState:UIControlStateDisabled];
//    [_editBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
//    [_editBtn setBackgroundImage:highImage forState:UIControlStateHighlighted];
//    [_editBtn setTitleColor:disableTextColor forState:UIControlStateDisabled];
//    [_editBtn setTitleColor:normalTextColor forState:UIControlStateNormal];
//    _editBtn.titleLabel.font=font;
//    [self addSubview:_editBtn];
    
    _sendBtn=[UIButton new];
    [_sendBtn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"hcyimagepicker_send_disabled"] forState:UIControlStateDisabled];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"hcyimagepicker_send_normal"] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"hcyimagepicker_send_pressed"] forState:UIControlStateHighlighted];
    _sendBtn.titleLabel.font=font;
    [self addSubview:_sendBtn];
    [_sendBtn addTarget:self action:@selector(sendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled=NO;
    _previewBtn.enabled=NO;
    _editBtn.enabled=NO;

}
#pragma mark UI
-(void)setSubviewFrame{
    _bgImageView.frame=self.bounds;
    CGFloat offset=7.f;
    CGFloat left=10.f;
    CGFloat width=45.f;
    
    _previewBtn.top=offset;
    _previewBtn.left=left;
    _previewBtn.width=width;
    _previewBtn.height=self.height-offset*2;
    
    _editBtn.top=offset;
    _editBtn.left=_previewBtn.right+left;
    _editBtn.width=_previewBtn.width;
    _editBtn.height=self.height-offset*2;
    
    _sendBtn.top=offset;
    _sendBtn.right=self.width-left;
    _sendBtn.width=70.f;
    _sendBtn.height=self.height-offset*2;
    
}
-(void)setselectItemCount:(NSInteger)count{
    _sendBtn.enabled=count;
    _previewBtn.enabled=count;
    _editBtn.enabled=count;
    NSString *title=@"发送";
    if (count) {
        title=[NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"发送", nil),count];
    }
    [_sendBtn setTitle:title forState:UIControlStateNormal];
    
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setSubviewFrame];

}
#pragma mark Event
-(void)sendBtnClicked:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupBottomView:clickedSendBtn:)])
    {
        [self.delegate groupBottomView:self clickedSendBtn:btn];
    }
}
@end
