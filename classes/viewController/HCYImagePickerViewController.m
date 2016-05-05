//
//  DtImagePickerViewController.m
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//
#define IS_IOS8 [[UIDevice currentDevice].systemVersion hasPrefix:@"8"]
#define IS_IOS9 [[UIDevice currentDevice].systemVersion hasPrefix:@"9"]


#import "HCYImagePickerViewController.h"
#import "Availability.h"
#import <AssetsLibrary/AssetsLibrary.h>
#if __IPHONE_8_0
#import <Photos/Photos.h>
#endif
#import "HCYImagePickerListCell.h"
#import "HCYImagePickerGroupController.h"
#import "HCYImagePickerCollector.h"
#import "UIView+DanteImagePicker.h"
@interface HCYImagePickerViewController ()<UITableViewDataSource,UITableViewDelegate,HCYImagePickerCollectorDelegate,HCYImagePickerGroupControllerDelegate>
@property(strong,nonatomic) ALAssetsLibrary *lib;
@property(strong,nonatomic)NSArray *dataArr;
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)HCYImagePickerCollector *collector;
@end

@implementation HCYImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"相册", nil);
    self.collector=[HCYImagePickerCollector sharedCollector];
    self.collector.maxCount=self.selectCount;
    [self.collector addDelegate:self];
    [self setupSubviews];
    [self readPictures];
    UIBarButtonItem *item= [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(readPictures)];
   UINavigationBar *bar= [UINavigationBar appearance];
    [bar setTintColor:[UIColor redColor]];
    
    self.navigationItem.backBarButtonItem=item;
 
}
-(void)dealloc{
    [HCYImagePickerCollector destroy];
    NSLog(@"imagePickerDealloc");
}
-(void)readPictures{
#if __IPHONE_8_0
    [self readPicWithPhotos];
#else
    [self readPicWithALAsset];
#endif
   
}
#pragma  mark photos
#if __IPHONE_8_0
-(void)readPicWithPhotos{
    PHFetchResult *smartAlbum=[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *userAlbum=[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    NSMutableArray *allAlbums=[NSMutableArray array];
    for (PHCollection *collection in smartAlbum) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            [allAlbums addObject:collection];
        }
    }
    for (PHCollection *collection in userAlbum) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            [allAlbums addObject:collection];
        }
    }
    __weak typeof(self) wself=self;
    //只显示要的智能相册
    [allAlbums filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PHAssetCollection * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if(evaluatedObject.assetCollectionType==PHAssetCollectionTypeSmartAlbum){
            return  [[wself customAssetsCollectionSort] containsObject:@(evaluatedObject.assetCollectionSubtype)];
        }else{
            return YES;
        }
    }]];
    //排除没有照片的相册
    [allAlbums filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PHAssetCollection * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        PHFetchOptions *options=[PHFetchOptions new];
        options.predicate =[NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *result= [PHAsset fetchAssetsInAssetCollection:evaluatedObject options:options];
        return result.count;
    }]];
    //cache listImage加快效率

    [allAlbums sortUsingComparator:^NSComparisonResult(PHAssetCollection *collection1, PHAssetCollection *collection2) {
        NSInteger index1=[[wself customAssetsCollectionSort] indexOfObject:@(collection1.assetCollectionSubtype)];
        NSInteger index2=[[wself customAssetsCollectionSort] indexOfObject:@(collection2.assetCollectionSubtype)];
        return index1>index2?NSOrderedDescending:NSOrderedAscending;
    }];

    NSArray *listDataArr=[[HCYImagePickerUtil sharedUtil] fillListDataWithSource:allAlbums];
    _dataArr=listDataArr;
    [_tableView reloadData];
}
-(NSArray *)customAssetsCollectionSort{
    static NSArray *customAssetsCollectionSortArr;
    customAssetsCollectionSortArr=@[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                    @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                    @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                    @(PHAssetCollectionSubtypeSmartAlbumScreenshots),
                                    @(PHAssetCollectionSubtypeAlbumSyncedAlbum)];
    return customAssetsCollectionSortArr;
}
#endif
#pragma mark ALAssetLibrary
-(void)readPicWithALAsset{
    [self.lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //不读取没照片的相册
        NSMutableArray *arrM=[NSMutableArray array];
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets]) {
                [arrM addObject:group];
            }
        }else{
            _dataArr=[arrM copy];
            [_tableView reloadData];
            *stop=YES;
        }
    } failureBlock:^(NSError *error) {
        if (error.code==-3311) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
            NSLog(@"授权失败");
        }
        NSLog(@"error:%@",error);
    }];
}
#pragma mark subViews
-(void)setupSubviews{
    self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    _tableView.contentOffset=CGPointMake(0, 64);
    [self.view addSubview:_tableView];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 40, 30);
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem*  negativeSpacer=  [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer.width=-10;
    self.navigationItem.rightBarButtonItems=@[negativeSpacer,rightItem];
}
#pragma mark Delegate
-(void)back:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerDidCanceled:)]){
        [self.delegate imagePickerDidCanceled:self];
    }
}
#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseId=@"DtImagePickerTableCell";
    HCYImagePickerListCell *cell=[tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell=[[HCYImagePickerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    id<HCYImagePickerListItem> item=_dataArr[indexPath.row];
    [cell refreshData:item isLast:NO];
    return  cell;
}
#pragma mark tableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[HCYImagePickerUtil sharedUtil] listCellheight]; 
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<HCYImagePickerListItem> item=_dataArr[indexPath.row];
    HCYImagePickerGroupController *groupVC=[[HCYImagePickerGroupController alloc] initWithListItem:item];
    groupVC.delegate=self;
    [self.navigationController pushViewController:groupVC animated:YES];
}
#pragma mark collectorDelegate
-(void)groupControllerSendBtnClicked:(HCYImagePickerGroupController *)controller{
    if ([_delegate respondsToSelector:@selector(imagePicker:selectWithImages:)]) {
#warning 提示框
        __weak typeof(self) wself=self;
        [[HCYImagePickerCollector sharedCollector] allImagesWithCompletion:^(NSArray *images) {
            if (wself) {
                [wself.delegate imagePicker:wself selectWithImages:images];
            }
        }];
    }
}
-(void)itemBeyond{
    if ([self.delegate respondsToSelector:@selector(imagePickerselectItemBeyondMark:)]) {
        [self.delegate imagePickerselectItemBeyondMark:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:flag completion:^(){
        [HCYImagePickerCollector destroy];
        if (completion) {
            completion();
        }
    }];
}
#pragma mark properties lazy load
-(ALAssetsLibrary *)lib{
    if (!_lib) {
        _lib=[[ALAssetsLibrary alloc] init];
    }
    return _lib;
}

@end
