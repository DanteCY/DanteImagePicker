//
//  DtImagePickerCollector.h
//  DanteImagePicker
//
//  Created by hcy on 15/11/5.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "HCYImagePickerGroupBottomView.h"
#import "HCYImagePickerHeader.h"
@class HCYImagePickerCollector;
@protocol HCYImagePickerCollectorDelegate <NSObject>
-(void)collector:(HCYImagePickerCollector *)collector addItem:(id)item;
-(void)collector:(HCYImagePickerCollector *)collector removeItem:(id)item;
@optional
/**
 *  添加图片时候超过最大值时候触发
 */
-(void)collectorItemBeyond:(HCYImagePickerCollector *)collector;
@end

/**
 *  收集者。负责记录选择的数据
 */
@interface HCYImagePickerCollector : NSObject
+(instancetype)sharedCollector;
+(void)destroy;
//Data
-(NSInteger)itemCount;
-(NSArray *)images;
-(BOOL)itemSelected:(id<HCYImagePickerContentItem> )item;
-(BOOL)addItem:(id<HCYImagePickerContentItem> )item;
-(void)removeItem:(id<HCYImagePickerContentItem> )item;
/**
 *  获得所有选择好的照片
 *  因为可能有什么别的处理需要干，所以是个异步的
 *  @param completion
 */
-(void)allImagesWithCompletion:(void(^)(NSArray *images))completion;
//Delegate
-(void)addDelegate:(id<HCYImagePickerCollectorDelegate>)delegate;
-(void)removeDelegate:(id<HCYImagePickerCollectorDelegate>)delegate;
@property(assign,nonatomic)NSInteger maxCount;
@end
