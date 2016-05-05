//
//  HCYImagePickerUtil.m
//  dfgdf
//
//  Created by hcy on 16/4/7.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import "HCYImagePickerUtil.h"
#import "HCYImagePickerListItem.h"
#import "HCYImagePickerContentItem.h"

#define HCYImagePicker_IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define HCYImagePicker_IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define HCYImagePicker_IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

@interface HCYImagePickerUtil()
@property(assign,nonatomic) CGSize  listImageSize;
@property(assign,nonatomic) CGFloat listCellHeight;
@property(strong,nonatomic) NSMutableDictionary *fileSizeDict;
@end
@implementation HCYImagePickerUtil
static HCYImagePickerUtil *sharedUtil;
+(instancetype)sharedUtil{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil=[HCYImagePickerUtil new];
    });
    return sharedUtil;
}
-(CGSize)listImageSize{
    if (CGSizeEqualToSize(_listImageSize, CGSizeZero)) {
        CGFloat imageWidth=[self listCellheight]*0.6;
        CGFloat imageHeight=[self listCellheight]*.7;
        _listImageSize=CGSizeMake(imageWidth, imageHeight);
    }
    return _listImageSize;
}
CGFloat columnCount=4;
CGFloat offset=5;
-(CGSize)contentImageSize{
    CGFloat screenWidth=[UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth=(screenWidth-offset*(columnCount-1))/columnCount;
    return CGSizeMake(itemWidth, itemWidth);
}
-(CGSize)previewImageSize{
    return [UIScreen mainScreen].bounds.size;
}
-(CGFloat)listCellheight{
    if (_listCellHeight==0) {
        _listCellHeight=[self availabeHeight]*.1;
    }
    return _listCellHeight;
}
-(CGFloat)availabeHeight{
    //屏幕高度-状态栏-导航栏
    return [UIScreen mainScreen].bounds.size.height-20-44;
}

static int HCYImagePickerFileSizeMax=1024;
-(NSString *)fileSizeStrWithByteLength:(NSUInteger)length{
    int i=0;
    while (length>HCYImagePickerFileSizeMax*0.98) {
        length=length/HCYImagePickerFileSizeMax;
        i++;
    }
    NSString *suffix=@"GB";
    if ([[self fileSizeExtDict] objectForKey:@(i)]) {
        suffix=[[self fileSizeExtDict] objectForKey:@(i)];
        NSString *str=[NSString stringWithFormat:@"%.2f%@",(float)length,suffix];
        return str;
    }
    return @"";
}
-(NSMutableDictionary *)fileSizeDict{
    if(!_fileSizeDict){
        _fileSizeDict=[NSMutableDictionary dictionary];
    }
    return _fileSizeDict;
    
}
-(NSDictionary *)fileSizeExtDict{
    static NSDictionary *fileSizeExtDict;
    fileSizeExtDict=@{@(0):@"B",
                      @(1):@"KB",
                      @(2):@"MB",
                      @(3):@"GB"};
    return fileSizeExtDict;
}
-(UIImage *)imageWithColor:(UIColor *)color{
  
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
}
-(NSArray *)fillListDataWithSource:(NSArray *)source{
    NSMutableArray *arrM=[NSMutableArray arrayWithCapacity:source.count];
    for (id sourceData in source) {
        HCYImagePickerListItem *listItem=[HCYImagePickerListItem listItemWithObj:sourceData];
        [arrM addObject:listItem];
    }
    return  [arrM copy];
    
}
-(NSArray *)fillContentDataWithSource:(NSArray *)source{
    NSMutableArray *arrM=[NSMutableArray arrayWithCapacity:source.count];
    for (id sourceData in source) {
        HCYImagePickerContentItem *contentItem=[HCYImagePickerContentItem contentItemWithData:sourceData];
        [arrM addObject:contentItem];
    }
    return [arrM copy];
}
#ifdef __IPHONE_8_0
static PHCachingImageManager *cacheManager;
-(PHCachingImageManager *)cacheManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheManager=[PHCachingImageManager new];
    });
    return cacheManager;
}
#endif
@end
