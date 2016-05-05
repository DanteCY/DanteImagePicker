//
//  DtImagePickerCollector.m
//  DanteImagePicker
//
//  Created by hcy on 15/11/5.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerCollector.h"

@interface HCYImagePickerCollector(){
    dispatch_queue_t _imageQueue;
}
@property(strong,nonatomic)NSMutableArray *selectItems;
@property(strong,nonatomic)NSMutableArray *delegateArr;

@end
@implementation HCYImagePickerCollector
static HCYImagePickerCollector *collector;
+(instancetype)sharedCollector{
    if (!collector) {
        collector=[HCYImagePickerCollector new];
        collector.selectItems=[NSMutableArray array];
        collector.delegateArr=[NSMutableArray array];
    }
    return collector;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageQueue=dispatch_queue_create("HCYImagePickerCollectorqueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
+(void)destroy{
    collector=nil;
}


-(NSInteger)itemCount{
    return self.selectItems.count;
}
-(void)addDelegate:(id<HCYImagePickerCollectorDelegate>)delegate{
    [_delegateArr addObject:delegate];
}
-(void)removeDelegate:(id<HCYImagePickerCollectorDelegate>)delegate{
    [_delegateArr removeObject:delegate];
}
-(BOOL)addItem:(id<HCYImagePickerContentItem> )item{
    if (![self.selectItems containsObject:item]) {
        [self.selectItems addObject:item];
        [item setSelected:YES];
    }
    if (self.selectItems.count+1>self.maxCount) {
        for (id delegate in _delegateArr) {
            if ([delegate respondsToSelector:@selector(collectorItemBeyond:)]) {
                [delegate collectorItemBeyond:self];
            }
        }
        return NO;
    }
    
    for (id delegate in _delegateArr) {
        if ([delegate respondsToSelector:@selector(collector:addItem:)]) {
            [delegate collector:self addItem:item];
        }
    }
    return YES;

}
-(void)removeItem:(id<HCYImagePickerContentItem> )item{
    [self.selectItems removeObject:item];
    [item setSelected:NO];
    [item setSourceImage:NO];
    for (id delegate in _delegateArr) {
        if ([delegate respondsToSelector:@selector(collector:removeItem:)]) {
            [delegate collector:self removeItem:item];
        }
    }
}
-(BOOL)itemSelected:(id<HCYImagePickerContentItem>)item{
    __block BOOL result=NO;
    [self.selectItems enumerateObjectsUsingBlock:^(id<HCYImagePickerContentItem> obj, NSUInteger idx, BOOL * stop) {
        if ([obj isEqual:item]) {
            result=YES;
            *stop=YES;
        }
    }];
    return result;
}
-(void)allImagesWithCompletion:(void (^)(NSArray *))completion{
    dispatch_async(_imageQueue, ^{
        __block NSMutableArray *imagesArrM=[NSMutableArray array];
        NSCondition *subCondition=[NSCondition new];
        for (id<HCYImagePickerContentItem> item in _selectItems) {
            [item sendedImageWithCompletion:^(id<HCYImagePickerContentItem> item, UIImage *image) {
                [imagesArrM addObject:image];
                [subCondition lock];
                [subCondition signal];
                [subCondition unlock];
            }];
            [subCondition lock];
            [subCondition wait];
            [subCondition unlock];
            if (completion) {
                NSLog(@"imagesCount:%ld",imagesArrM.count);
                completion([imagesArrM copy]);
            }
        }
    });
    
    
}
#pragma mark groupBottomViewDelegate
//-(void)groupBottomView:(HCYImagePickerGroupBottomView *)view clickedSendBtn:(UIButton *)btn{
//    if(self.delegate && [self.delegate respondsToSelector:@selector(collectorWantSendData)]){
//        [self.delegate collectorWantSendData];
//    }
//}
@end
