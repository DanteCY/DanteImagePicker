//
//  HCYImagePickerUtil.h
//  dfgdf
//
//  Created by hcy on 16/4/7.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef  __IPHONE_8_0
#import <Photos/Photos.h>
#endif
@interface HCYImagePickerUtil : NSObject
+(instancetype)sharedUtil;
/**
 *  列表图片大小
 *
 *  @return 
 */
-(CGSize)listImageSize;

/**
 *  collectionView图片大小
 *
 *  @return <#return value description#>
 */
-(CGSize)contentImageSize;
/**
 *  previewImage大小
 *
 *  @return
 */
-(CGSize)previewImageSize;
/**
 *  列表行高
 *
 *  @return 
 */
-(CGFloat)listCellheight;
-(UIImage *)imageWithColor:(UIColor *)color;
-(NSString *)lengthStrWithLength:(long long)fileLength;
/**
 *  用来缓存图片大小
 *
 *  @return 
 */
-(NSMutableDictionary *)fileSizeDict;
-(NSString *)fileSizeStrWithByteLength:(NSUInteger)fileLength;
#ifdef __IPHONE_8_0
-(PHCachingImageManager *)cacheManager;
#endif
//中介
/**
 *  用提供的数据源提供列表数据
 *
 *  @param source 从系统框架里获得的原始数据源
 *
 *  @return 适用于本框架的数据源
 */
-(NSArray *)fillListDataWithSource:(NSArray *)source;
-(NSArray *)fillContentDataWithSource:(NSArray *)source;
@end
