//
//  DtImagePickerGroupController.m
//  CustomImagePicker
//
//  Created by hcy on 15/8/18.
//  Copyright (c) 2015年 hcy. All rights reserved.
//

#import "HCYImagePickerGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HCYImagePickerGroupCell.h"
#import "HCYImagePickerContentItem.h"
#import "HCYImagePickerCollector.h"
#import "UIView+DanteImagePicker.h"
#import "HCYImagePickerHeader.h"
#import "HCYImagePickerGroupBottomView.h"
#import "HCYPhotoBrowser.h"
#import "HCYPhoto.h"
static NSString *collectionViewReuseId=@"DtImagePickerGroupCell";
@interface HCYImagePickerGroupController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HCYImagePickerGroupCellDelegate,HCYPhotoBrowserDataSource,
    HCYPhotoBrowserDelegate,HCYImagePickerCollectorDelegate>

@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)id<HCYImagePickerListItem> groupItem;
@property(strong,nonatomic)HCYImagePickerGroupBottomView *bottomView;
@property(strong,nonatomic)NSArray *dataArr;
//和预览相关的View
@property(weak,nonatomic)UIButton *selectBtn;
@property(weak,nonatomic)UIButton *sourceBtn;
@property(weak,nonatomic)UIButton *sendBtn;
@property(weak,nonatomic)UILabel *sourceLabel;
@property(weak,nonatomic)UIView *browserTopView;
@property(weak,nonatomic)UIView *browserBottomView;
@property(assign,nonatomic)NSInteger currentIndex;
@end

CGFloat    HCYImagePickerGroupItemEdgeLeft=3;
NSInteger  HCYImagePickerGroupColumnCount=4;

@implementation HCYImagePickerGroupController
-(instancetype)initWithListItem:(id<HCYImagePickerListItem>)item {
    if (self=[super init]) {
        _groupItem=item;
        _bottomView=[[HCYImagePickerGroupBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setupSubviews];
    self.title=[_groupItem albumTitle];
    [self readPic];
    [[HCYImagePickerCollector sharedCollector] addDelegate:self];
}
-(void)dealloc{
    [[HCYImagePickerCollector sharedCollector] removeDelegate:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=NO;
    if ([UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleLightContent) {
        [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleDefault;
    }
}
-(void)setupSubviews{
    CGFloat bottomHeight=44;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing=HCYImagePickerGroupItemEdgeLeft;
    layout.minimumInteritemSpacing=0;
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-bottomHeight) collectionViewLayout:layout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView registerClass:[HCYImagePickerGroupCell class] forCellWithReuseIdentifier:collectionViewReuseId];
    self.collectionView.backgroundColor=[UIColor clearColor];
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    CGFloat itemWidth=[[HCYImagePickerUtil sharedUtil] contentImageSize].width;
    
    CGFloat rowCount=self.dataArr.count/HCYImagePickerGroupColumnCount;
    CGFloat y=rowCount*itemWidth+(rowCount-1)*HCYImagePickerGroupItemEdgeLeft;
    _bottomView.top=_collectionView.bottom;
    _bottomView.left=0;
    _bottomView.width=self.view.width;
    _bottomView.height=self.view.height-_bottomView.top;
    [self.collectionView setContentOffset:CGPointMake(0, y) animated:NO];
    [self.view addSubview:_bottomView];

}

//CGFloat itemWidth;
-(void)readPic{
    [_groupItem allAlbumImagesWithCompletion:^(NSArray *contentArr, NSError *error) {
        _dataArr=[[HCYImagePickerUtil sharedUtil] fillContentDataWithSource:contentArr];
        [_collectionView reloadData];
    }];
}

#pragma mark collectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HCYImagePickerGroupCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:collectionViewReuseId forIndexPath:indexPath];
    [cell refreshWithItem:self.dataArr[indexPath.row]];
    if (!cell.deleate) {
        cell.deleate=self;
    }
    return cell;
}
#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
            HCYPhotoBrowser *browser=[HCYPhotoBrowser new];
//        HCYPhotoBrowser *browser=[[HCYPhotoBrowser alloc] initWithPhotos:photos];
            browser.browserDataSource=self;
        browser.browserDelegate=self;
        browser.currentIndex=indexPath.row;
        _currentIndex=indexPath.row;
    
        [self.navigationController pushViewController:browser animated:YES];
}
#pragma mark cellDelegate
-(void)cell:(HCYImagePickerGroupCell *)cell selected:(BOOL)select{
    NSIndexPath *indexPath=[self.collectionView indexPathForCell:cell];
    HCYImagePickerContentItem *item=self.dataArr[indexPath.row];
    if (select) {
        [[HCYImagePickerCollector sharedCollector] addItem:item];
    }else{
        [[HCYImagePickerCollector sharedCollector] removeItem:item];
    }
    [self refreshCustomView];
//    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}
#pragma mark collectorDelegate
-(void)collectorItemBeyond:(HCYImagePickerCollector *)collector{
    
}
-(void)collector:(HCYImagePickerCollector *)collector addItem:(id)item{
    [self refreshCustomView];
}
-(void)collector:(HCYImagePickerCollector *)collector removeItem:(id)item{
    [self refreshCustomView];
}
#pragma mark collectionViewLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [[HCYImagePickerUtil sharedUtil] contentImageSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(HCYImagePickerGroupItemEdgeLeft, HCYImagePickerGroupItemEdgeLeft, 0, HCYImagePickerGroupItemEdgeLeft);
}

#pragma mark photoBrowserDataSource
-(NSUInteger)numberOfPhotosInBrowser:(HCYPhotoBrowser *)browser{
    return _dataArr.count;
}
-(HCYPhoto *)photoWithIndex:(NSUInteger)index{
    HCYPhoto *photo=[HCYPhoto new];
    photo.photoType=HCYPhotoTypeAsync;
    photo.autoResize=YES;
    photo.photoIdentifier=[NSString stringWithFormat:@"%ld",index];
    id<HCYImagePickerContentItem> item=_dataArr[index];
    photo.sourceBlock=^(){
        dispatch_semaphore_t t=dispatch_semaphore_create(0);
        __block UIImage *image;
        [item previewImageWithCompletion:^(id<HCYImagePickerContentItem> data, UIImage *result) {
            image=result;
            dispatch_semaphore_signal(t);
        }];
        dispatch_semaphore_wait(t, DISPATCH_TIME_FOREVER);
        return image;
//    photo.sourceImageView=[[UIImageView alloc] initWithImage:image];
    };
    return photo;
}

#pragma mark photoBrowserDelegate
-(void)browserDidLoad:(HCYPhotoBrowser *)browser{
    browser.automaticallyAdjustsScrollViewInsets=NO;
    UIView *topView=[self browserTopView];
    [browser.view addSubview:topView];
    _browserTopView=topView;
    
    UIView *bottomView=[self browserBottomView];
    [browser.view addSubview:bottomView];
    _browserBottomView=bottomView;
    
}
-(void)browserWillAppear:(HCYPhotoBrowser *)browser{
    browser.navigationController.navigationBar.hidden=YES;
    if ([UIApplication sharedApplication].statusBarStyle!=UIStatusBarStyleLightContent) {
        [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;;
    }
}

-(void)browser:(HCYPhotoBrowser *)browser showPhotoAtIndex:(NSInteger)index{
    _currentIndex=index;
    [self refreshCustomView];
}
-(void)browser:(HCYPhotoBrowser *)browser TapPhoto:(HCYPhoto *)photo{
    BOOL target=!_browserTopView.hidden;
    _browserTopView.hidden=target;
    _browserBottomView.hidden=target;
}
-(void)browser:(HCYPhotoBrowser *)browser LongPressedPhoto:(HCYPhoto *)photo{

}
#pragma mark photoBrowser自定义view
-(UIView *)browserTopView{
    UIView *customNaviBar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    UIColor *bgColor=[UIColor colorWithRed:40/255.f green:40/255.f blue:40/255.f alpha:1.f];
    [customNaviBar setBackgroundColor:bgColor];

    UIControl *control=[[UIControl alloc] initWithFrame:CGRectMake(0, 20, 64, 44)];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hcyimagepicker_arrowback"]];
    imageView.top=10;
    imageView.left=15;
    imageView.width=13;
    imageView.height=24;
    [control addSubview:imageView];
    [control addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [customNaviBar addSubview:control];
    
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"hcyimagepicker_preview_uncheck@2x"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"hcyimagepicker_overlay_checked@2x"] forState:UIControlStateHighlighted];
    [rightBtn setImage:[UIImage imageNamed:@"hcyimagepicker_overlay_checked@2x"] forState:UIControlStateSelected];
    rightBtn.top=30;
    rightBtn.width=24;
    rightBtn.height=24;
    rightBtn.right=self.view.width-20;
    [customNaviBar addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn=rightBtn;
    return customNaviBar;
}
-(UIView *)browserBottomView{
    UIView *bottomView=[UIView new];
    UIColor *bgColor=[UIColor colorWithRed:40/255.f green:40/255.f blue:40/255.f alpha:1.f];

    bottomView.backgroundColor=bgColor;
    bottomView.left=0;
    bottomView.width=self.view.width;
    bottomView.height=44.f;
    bottomView.bottom=self.view.bottom;
    UIButton *sourceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [sourceBtn setImage:[UIImage imageNamed:@"hcyimagepicker_hdimage_uncheck@2x"] forState:UIControlStateNormal];
    [sourceBtn setImage:[UIImage imageNamed:@"hcyimagepicker_hdimage_checked@2x"] forState:UIControlStateHighlighted];
    [sourceBtn setImage:[UIImage imageNamed:@"hcyimagepicker_hdimage_checked@2x"] forState:UIControlStateSelected];
    [sourceBtn sizeToFit];
    sourceBtn.top=(bottomView.height-sourceBtn.height)*.5;
    sourceBtn.left=10;
    [sourceBtn addTarget:self action:@selector(sourceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sourceBtn];

    self.sourceBtn=sourceBtn;
    UILabel *lab=[UILabel new];
    lab.text=NSLocalizedString(@"原图", nil);
    lab.textColor=[UIColor grayColor];
    [lab sizeToFit];
    lab.left=sourceBtn.right+5;
    lab.top=sourceBtn.top;
    [bottomView addSubview:lab];
    self.sourceLabel=lab;
    UIButton *sendBtn=[UIButton buttonWithType:UIButtonTypeCustom];

    UIColor *sendBgColor=[UIColor colorWithRed:23/255.f green:215/255.f blue:177/255.f alpha:1.f];
    [sendBtn setTitleColor:sendBgColor forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sendBtn];
    self.sendBtn=sendBtn;
    [self refreshCustomView];
    sendBtn.top=(bottomView.height-sendBtn.height)*0.5;
    sendBtn.right=bottomView.right-20;
    return bottomView;
}

-(void)back{
    UIViewController *vc=[[self.navigationController viewControllers] lastObject];
    [vc.navigationController popViewControllerAnimated:YES];
}

-(void)selectBtnClick:(UIButton *)btn{
    btn.selected=!btn.selected;
    id<HCYImagePickerContentItem> item=_dataArr[_currentIndex];
    if (btn.isSelected) {
        [[HCYImagePickerCollector sharedCollector] addItem:item];
    }else{
        [[HCYImagePickerCollector sharedCollector] removeItem:item];
    }
    [self refreshCustomView];
}

-(void)sourceBtnClick:(UIButton *)btn{
    btn.selected=!btn.selected;
    id<HCYImagePickerContentItem> item=_dataArr[_currentIndex];
    if (btn.isSelected) {
        if (![item isSelected]) {
            [[HCYImagePickerCollector sharedCollector] addItem:item];
        }
        [item setSourceImage:YES];
    }else{
        [item setSourceImage:NO];
    }
    [self refreshCustomView];
}

-(void)sendBtnClicked:(UIButton *)btn{
    if(![[HCYImagePickerCollector sharedCollector] itemCount]){
        id<HCYImagePickerContentItem> item=_dataArr[_currentIndex];
        [[HCYImagePickerCollector sharedCollector] addItem:item];
    }
    if([_delegate respondsToSelector:@selector(groupControllerSendBtnClicked:)]){
        [_delegate groupControllerSendBtnClicked:self];
    }
}
-(void)refreshCustomView{
    NSInteger count=[[HCYImagePickerCollector sharedCollector] itemCount];
     NSString *str=[NSString stringWithFormat:@"发送(%ld)",count];
    if (!count) {
        str=@"发送";
    }
    [_bottomView setselectItemCount:count];
    [_sendBtn setTitle:str forState:UIControlStateNormal];
    [_sendBtn sizeToFit];
    [_sendBtn sizeToFit];
    _sendBtn.right=_bottomView.right-20;
    
    id<HCYImagePickerContentItem> item=_dataArr[_currentIndex];
    
    _selectBtn.selected=[item isSelected];
    if([item sourceImage]){
        _sourceLabel.text=[NSString stringWithFormat:@"原图(%@)",[item sourceLength]];
        _sourceBtn.selected=YES;
    }else{
        _sourceLabel.text=@"原图";
        _sourceBtn.selected=NO;
    }
    [_sourceLabel sizeToFit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
