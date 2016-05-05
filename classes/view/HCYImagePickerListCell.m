//
//  DtImagePickerListCell.m
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerListCell.h"
#import "UIView+DanteImagePicker.h"
@interface HCYImagePickerListCell()
@property(strong,nonatomic)UIImageView *thumbnailImageView;
@property(strong,nonatomic)UIImageView *customSeparImageView;
@property(strong,nonatomic)UIImageView *accImageView;
@property(strong,nonatomic)UILabel *groupNameLabel;
@property(strong,nonatomic)UILabel *countLabel;

@property(strong,nonatomic)id<HCYImagePickerListItem> data;
@end;
@implementation HCYImagePickerListCell

- (void)awakeFromNib {
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _thumbnailImageView=[[UIImageView alloc] init];
        _customSeparImageView=[[UIImageView alloc] initWithImage:[[HCYImagePickerUtil sharedUtil] imageWithColor:[UIColor lightGrayColor]]];
        _accImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yx_icon_arrow"]];
        
        _groupNameLabel=[UILabel new];
        _countLabel=[UILabel new];
        _countLabel.textColor=[UIColor grayColor];
        
        UIView *contentView=self.contentView;
        
        [contentView addSubview:_thumbnailImageView];
        [contentView addSubview:_customSeparImageView];
        [contentView addSubview:_accImageView];
        [contentView addSubview:_groupNameLabel];
        [contentView addSubview:_countLabel];
    }
    return self;
}
-(void)refreshData:(id<HCYImagePickerListItem>)item isLast:(BOOL)isLast{
    _data=item;
    __weak typeof(self) wself=self;
    _thumbnailImageView.image=nil;
    [item albumThumbImageWithData:item completion:^(id<HCYImagePickerListItem> item, UIImage *image) {
        if (item==wself.data && image) {
            wself.thumbnailImageView.image=image;
        }
    }];
    _groupNameLabel.text=[item albumTitle];
    _countLabel.text=[NSString stringWithFormat:@"(%@)",[item albumImageCountStr]];
    _customSeparImageView.hidden=isLast;
}
-(void)layoutSubviews{
    [super layoutSubviews];

    CGSize imageSize=[[HCYImagePickerUtil sharedUtil] listImageSize];
    _thumbnailImageView.width=imageSize.width;
    _thumbnailImageView.height=imageSize.height;
    _thumbnailImageView.left=10;
    _thumbnailImageView.top=(self.height-_thumbnailImageView.height)*.5;
    
    CGFloat nameLabelLeftToThumbnail=10;
    
    [_groupNameLabel sizeToFit];
    _groupNameLabel.left=_thumbnailImageView.right+nameLabelLeftToThumbnail;
    _groupNameLabel.top=(self.height-_groupNameLabel.height)*.5;
    [_countLabel sizeToFit];
    _countLabel.left=_groupNameLabel.right+nameLabelLeftToThumbnail;
    _countLabel.top=(self.height-_countLabel.height)*.5;
    
    [_accImageView sizeToFit];
    
    _accImageView.right=self.width-nameLabelLeftToThumbnail;
    _accImageView.top=(self.height-_accImageView.height)*.5;
    
    _customSeparImageView.top=self.height-1;
    _customSeparImageView.left=_groupNameLabel.left;
    _customSeparImageView.width=self.width-_customSeparImageView.left;
    _customSeparImageView.height=1;
}
@end
