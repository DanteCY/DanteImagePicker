//
//  DtImagePickerSelectItem.m
//  DanteImagePicker
//
//  Created by hcy on 15/11/5.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerContentItem.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface HCYImagePickerContentItem()
{
    BOOL _select;
    BOOL _source;
}
@property(strong,nonatomic)id data;
@property(copy,nonatomic)NSString *sourceLengthStr;
@end
@implementation HCYImagePickerContentItem
+(instancetype)contentItemWithData:(id)data{
    return [[self alloc] initWithData:data];
}
-(instancetype)initWithData:(id)data{
    if (self=[super init]) {
        _data=data;
    }
    return self;
}
-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]]) {
        return [_data isEqual:[object data]];
    }
    return NO;
}
#pragma mark contentItem
#ifdef __IPHONE_8_0
-(void)thumbImageWithCompletion:(void (^)(id<HCYImagePickerContentItem>, UIImage *))completion{
    if (completion) {
        CGSize contentSize=[[HCYImagePickerUtil sharedUtil] contentImageSize];
        PHAsset *asset=(PHAsset *)_data;
        [[[HCYImagePickerUtil sharedUtil] cacheManager] requestImageForAsset:asset targetSize:contentSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            completion(self,result);
        }];
    }
}
-(void)previewImageWithCompletion:(void (^)(id<HCYImagePickerContentItem>, UIImage *))completion{
    if (completion) {
        PHAsset *asset=(PHAsset *)_data;
//        NSCondition* itlock = [[NSCondition alloc] init];//搞个事件来同步下
        PHImageRequestOptions *options=[PHImageRequestOptions new];
        options.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [[[HCYImagePickerUtil sharedUtil] cacheManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image=[UIImage imageWithData:imageData];
            NSString *fileSie=[[HCYImagePickerUtil sharedUtil] fileSizeStrWithByteLength:imageData.length];
            _sourceLengthStr=fileSie;
//            [itlock lock];
//            [itlock signal];//设置事件,下面那个等待就可以收到事件返回了
//            [itlock unlock];
            completion(self,image);
        }];
//        [itlock lock];
//        [itlock wait];
//        [itlock unlock];
    }
}
-(void)sendedImageWithCompletion:(void (^)(id<HCYImagePickerContentItem>, UIImage *))completion{
    __weak typeof(self) wself=self;
    if (completion) {
        PHAsset *asset=(PHAsset *)_data;
        PHImageRequestOptions *options=[PHImageRequestOptions new];
        options.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [[[HCYImagePickerUtil sharedUtil] cacheManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image=[UIImage imageWithData:imageData];
            if ([wself sourceImage]) {
                completion(self,image);
            }else{
                CGSize size=[UIScreen mainScreen].bounds.size;
                UIGraphicsBeginImageContext(size);
                [image drawInRect:CGRectMake(0,0, size.width, size.height)];
                UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                completion(self,scaledImage);
            }
        }];
    }
}
-(NSString *)sourceLength{
    return [_sourceLengthStr copy];
}
//-(void)sourceLengthStrWithCompletion:(void (^)(id<HCYImagePickerContentItem>, NSString *))completion{
//    if (completion) {
//        if (_sourceLengthStr) {
//            completion(self,[_sourceLengthStr copy]);
//        }else{
//            PHAsset *asset=(PHAsset *)_data;
//            [[[HCYImagePickerUtil sharedUtil] cacheManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                _sourceLengthStr=[[HCYImagePickerUtil sharedUtil] lengthStrWithLength:imageData.length];
//                completion(self,[_sourceLengthStr copy]);
//            }];
//        }
//    }
//}
-(BOOL)sourceImage{
    return _source;
}
-(void)setSourceImage:(BOOL)sourceImage{
    _source=sourceImage;
}
-(BOOL)selected{
    return _select;
}
-(BOOL)isSelected{
    return _select;
}
-(void)setSelected:(BOOL)selected{
    _select=selected;
}
#else

#endif
//+(instancetype)itemWithALAsset:(ALAsset *)als{
//    
//    return [[self alloc] initWithAlAsset:als];
//}
//-(instancetype)initWithAlAsset:(ALAsset *)als{
//    if (self=[super init]) {
//        self.als=als;
//        NSDictionary *dict=[als valueForProperty:ALAssetPropertyURLs];
//        NSURL *val=nil;
//        if (dict) {
//            val=dict[@"public.jpeg"];
//        }
//        self.sourceSize=-1;
//        if ([val isKindOfClass:[NSURL class]]) {
//            self.alsUrl=val.absoluteString;
//        }
//        
//    }
//    return self;
//}
//
//- (BOOL)isEqual:(HCYImagePickerContentItem *)other
//{
//    if (other == self) {
//        return YES;
//    } else {
//        SEL selector=@selector(alsUrl);
//        if ([other respondsToSelector:selector]) {
//            return [[self alsUrl] isEqualToString:[other alsUrl]];
//        }else{
//            return NO;
//        }
//    }
//}
//
//-(UIImage *)image{
//    CGImageRef cgref;
//    if (self.isSource) {
//       cgref=[[self.als defaultRepresentation] fullResolutionImage];
//    }else{
//        cgref=[self.als aspectRatioThumbnail];
//    }
//    return [UIImage imageWithCGImage:cgref];
//}
//-(UIImage *)detailImage{
//    CGImageRef cgref;
//    if (self.isSource) {
//        cgref=[[self.als defaultRepresentation] fullResolutionImage];
//    }else{
//        cgref=[self.als aspectRatioThumbnail];
//    }
//    return [UIImage imageWithCGImage:cgref];
//}
//-(NSInteger)sourceSize{
//    if (self.isSource) {
//        if (_sourceSize==-1) {
//            ALAssetRepresentation *resp=[[self als] defaultRepresentation];
//            int bufferSize=1024;
//            uint8_t buffer[bufferSize];
//            unsigned long long read=0,length=0;
//            for (; read<[resp size]; ) {
//                length=[resp getBytes:buffer fromOffset:read length:bufferSize error:nil];
//                read+=length;
//            }
//            self.sourceSize=length;
//        }
//        return _sourceSize;
//    }else{
//        return 0;
//    }
//}
@end
