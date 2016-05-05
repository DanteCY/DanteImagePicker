//
//  HCYImagePickerHeader.h
//  dfgdf
//
//  Created by hcy on 16/4/6.
//  Copyright © 2016年 hcy. All rights reserved.
//

#ifndef HCYImagePickerHeader_h
#define HCYImagePickerHeader_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef __IPHONE_8_0
#import <Photos/Photos.h>
#endif
#import "HCYImagePickerUtil.h"
/**
 *  列表item协议
 */
@protocol HCYImagePickerListItem<NSObject>
@required
-(NSString *)albumTitle;
-(void)albumThumbImageWithData:(id<HCYImagePickerListItem>)data completion:(void(^)(id<HCYImagePickerListItem> item, UIImage *image))completion;
-(NSString *)albumImageCountStr;
/**
 *  真实类型数据 PHAssetCollection or ALAsset
 *
 *  @return
 */
-(id)data;
//数据相关
/**
 *  获得所有的内容(资源)PHAssetor ALAsset
 *
 *  @param completion 
 */
-(void)allAlbumImagesWithCompletion:(void(^)(NSArray *contentArr,NSError *error))completion;
@end
/**
 *  内容item协议
 */
@protocol HCYImagePickerContentItem <NSObject>
/**
 *  小图
 *
 *  @param completion 回调
 */
-(void)thumbImageWithCompletion:(void(^)(id<HCYImagePickerContentItem> data,UIImage *result))completion;
/**
 *  大图(用于preview展示)
 *
 *  @param completion 回调
 */
-(void)previewImageWithCompletion:(void(^)(id<HCYImagePickerContentItem> data,UIImage *result))completion;

/**
 *  发送时调用获取要发送的图片
 *
 *  @param completion 
 */
-(void)sendedImageWithCompletion:(void(^)(id<HCYImagePickerContentItem> item,UIImage *image))completion;
-(NSString *)sourceLength;
/**
 *  选中否
 */
@property(assign,nonatomic,getter=isSelected)BOOL selected;
/**
 *  原图否
 */
@property(assign,nonatomic)BOOL sourceImage;
@end


#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif /* HCYImagePickerHeader_h */
