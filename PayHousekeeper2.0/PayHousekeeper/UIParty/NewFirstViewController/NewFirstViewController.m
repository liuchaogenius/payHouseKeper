//
//  NewFirstViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "NewFirstViewController.h"
//#import "PlayVideoViewController.h"
#import "FourthViewController.h"
#import "PopMeneuView.h"
#import "AddFriendViewController.h"
#import "NewFirstVCManager.h"
#import "NewFirstVCTableviewCell.h"
#import "SVPullToRefresh.h"
#import "NewFirstData.h"
#import "FMDBNewFirstManager.h"
#import "SegmentedView.h"
#import "GroomCollectionView.h"

#define kSizeCount 20

@interface NewFirstViewController ()<NewFirstVCTableviewCellDelegate, SegmentedViewDelegate, GroomCollectionViewDelegate>
{
    NewFirstData *nfData;
    UIScrollView *contentView;
}
@property (nonatomic, strong) NSMutableArray *dataArry;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NewFirstVCManager *manager;
@property (nonatomic, assign)int segmentedPage;
@property (nonatomic, strong)GroomCollectionView *collView_rec;
@property (nonatomic, strong)GroomCollectionView *collView_malgod;
@property (nonatomic, strong)GroomCollectionView *collView_godness;
@property (nonatomic, strong)GroomCollectionView *collView_active;
@property (nonatomic, strong)GroomCollectionView *collView4_rookie;
@end

@implementation NewFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.segmentedPage = 0;
    // Do any additional setup after loading the view.
    [self settitleLabel:@"咚咚"];
    self.manager = [[NewFirstVCManager alloc] init];
    //self.titleLabel.textColor = kFcolorFontGreen;
    [self setLeftButton:[UIImage imageNamed:@"search_person_center"] title:nil target:self action:@selector(leftitem)];
    [self setRightButton:[UIImage imageNamed:@"search_add"] title:nil titlecolor:nil target:self action:@selector(righitem)];
    
    NSArray *arr = @[@"推荐", @"男神", @"女神", @"活跃", @"新秀"];
    SegmentedView *topView = [[SegmentedView alloc] initWithTitleArr:arr];
    topView.delegate = self;
    CGFloat x = 40;
    if (kMainScreenWidth == 320) {
        x = 30;
    }
    topView.frame = CGRectMake(x, 0, kMainScreenWidth - x * 2, 45);
    [self.view addSubview:topView];
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), kMainScreenWidth * arr.count, kMainScreenHeight - CGRectGetMaxY(topView.frame) - self.navigationController.navigationBar.height - 74-49)];
    contentView.contentSize = CGSizeMake(kMainScreenWidth * arr.count, contentView.height);
    [self.view addSubview:contentView];
    
    [self createContentSubviews];

}

- (void)createContentSubviews
{
    self.collView_rec = [[GroomCollectionView alloc] initWithFrame:CGRectMake(0 * kMainScreenWidth, 0, kMainScreenWidth, contentView.height) collectionData:nil];
    self.collView_rec.delegate = self;
    self.collView_rec.viewType = e_recommend;
    [contentView addSubview:self.collView_rec];
    
    self.collView_malgod = [[GroomCollectionView alloc] initWithFrame:CGRectMake(1 * kMainScreenWidth, 0, kMainScreenWidth, contentView.height) collectionData:nil];
    self.collView_malgod.delegate = self;
    self.collView_rec.viewType = e_malegods;
    [contentView addSubview:self.collView_malgod];
    
    self.collView_godness = [[GroomCollectionView alloc] initWithFrame:CGRectMake(2 * kMainScreenWidth, 0, kMainScreenWidth, contentView.height) collectionData:nil];
    self.collView_godness.delegate = self;
    self.collView_rec.viewType = e_goddess;
    [contentView addSubview:self.collView_godness];
    
    self.collView_active = [[GroomCollectionView alloc] initWithFrame:CGRectMake(3 * kMainScreenWidth, 0, kMainScreenWidth, contentView.height) collectionData:nil];
    self.collView_active.delegate = self;
    self.collView_rec.viewType = e_active;
    [contentView addSubview:self.collView_active];
    
    self.collView4_rookie = [[GroomCollectionView alloc] initWithFrame:CGRectMake(4 * kMainScreenWidth, 0, kMainScreenWidth, contentView.height) collectionData:nil];
    self.collView4_rookie.delegate = self;
    self.collView_rec.viewType = e_rookie;
    [contentView addSubview:self.collView4_rookie];
    
}

#pragma mark 按钮的点击事件
- (void)leftitem
{
    [self showPersonCenterViewController];
}
- (void)righitem
{
    [self showPopMeneuView];
}
- (void)showPopMeneuView
{
    PopMeneuView *popv = [[PopMeneuView alloc] init];
    NSArray *tarry = @[@"小视频",@"添加好友"];
    [popv showPopMenue:self.view titles:tarry clickItem:^(int aClickIndex) {
       /* if (aClickIndex == 0)
        {
            [self showPlayVideoViewController];
        }
        else if (aClickIndex == 1)
        {
            [self showAddFriendViewController];
        }*/
    }];
}

- (void)showPlayVideoViewController
{
    //PlayVideoViewController *vc = [[PlayVideoViewController alloc]init];
   // [self.navigationController pushViewController:vc animated:YES];
}
- (void)showPersonCenterViewController
{
    FourthViewController *vc = [[FourthViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAddFriendViewController
{
    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark 
- (void)firstMovingToParentvc
{
//    [self.view makeCenterToastActivity];
    
 
}
#pragma mark 头部button回调函数
- (void)segmentedViewDidClickedPlusButton:(NSInteger)tag
{
    contentView.contentOffset = CGPointMake(tag * kMainScreenWidth, 0);
    self.segmentedPage = tag;
}
#pragma mark collectview中的item点击回调 
- (void)groomCell:(UICollectionView *)collectionView didSelectItem:(NSIndexPath *)indexPath
{
    MLOG(@"%ld", (long)indexPath.item);
}

@end
