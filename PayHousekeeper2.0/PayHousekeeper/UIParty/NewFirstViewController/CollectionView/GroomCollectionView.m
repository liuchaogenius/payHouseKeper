//
//  ManGodView.m
//  DongDong
//
//  Created by BY on 2017/3/14.
//  Copyright © 2017年 BestLife. All rights reserved.
//  推荐模块

#import "GroomCollectionView.h"
#import "GroomData.h"
#import "GroomCell.h"
#import "SVPullToRefresh.h"

@interface GroomCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *groomData;
@end

@implementation GroomCollectionView

static NSString *const ID = @"groom";

- (NSMutableArray *)groomData
{
    if (_groomData == nil) {
        self.groomData = [NSMutableArray array];
        
        // 临时使用数据 
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Shop" ofType:@"plist"];
        NSArray* points = [NSMutableArray arrayWithContentsOfFile:path];
        

        // 1.初始化数据
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSDictionary *dic in points) {
            GroomData *data = [GroomData unPacketData:dic];
            
            [arr addObject:data];
        }
        
        
        [self.groomData addObjectsFromArray:arr];
        
    }
    return _groomData;
}

- (instancetype)initWithFrame:(CGRect)frame collectionData:(NSArray *)collectionData
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        CGFloat gap = 8;
        
        CGFloat W = (self.width - gap) / 2;
        CGFloat H = W * (364.0 / 371.0);
        
        // 设置每个格子的尺寸
        layout.itemSize = CGSizeMake(W, H);
        // 设置整个collectionView的内边距
        layout.sectionInset = UIEdgeInsetsMake(gap, 0, gap, 0);
        // 设置每一行之间的间距
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        
        // 2.创建UICollectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
        collectionView.backgroundColor = RGBCOLOR(238, 238, 238);
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        [collectionView registerClass:[GroomCell class] forCellWithReuseIdentifier:ID];
        
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        
        // 添加tableView的刷新
        [self addTableviewRefreshAndLoadMore];

        // 自定义显示的文字
        [collectionView.pullToRefreshView setTitle:@"下拉以刷新" forState:SVPullToRefreshStateTriggered];
        [collectionView.pullToRefreshView setTitle:@"刷新完了呀" forState:SVPullToRefreshStateStopped];
        [collectionView.pullToRefreshView setTitle:@"不要命的加载中..." forState:SVPullToRefreshStateLoading];
        
        // 自定义刷新时的动画，可以把view换成imageView等控件实现动画效果
//        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//        view.backgroundColor = [UIColor blueColor];
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:3];
//        view.alpha = 0.5 ;
//        [UIView commitAnimations];
//        [collectionView.pullToRefreshView setCustomView:view forState:SVPullToRefreshStateAll];
        
        
    }

    return self;
}

#pragma mark - UICollectionView刷新方法
- (void)addTableviewRefreshAndLoadMore
{
    WeakSelf(self);
    
    [self.collectionView addPullToRefreshWithActionHandler:^{
        
//        weakself.page = 1;
//
//        weakself.manager = [[NewFirstVCManager alloc] init];
//        
//        [weakself.manager requestWithStrUserId:[UserInfoData shareUserInfoData].strUserId Page:weakself.page size:kSizeCount searchDataCompleteBloock:^(NewFirstData *searchData) {
//            
//            
//            [weakself.dataArry removeAllObjects];
//            
//            weakself.dataArry = searchData.datalist;
//            
//            [weakself.tableview reloadData];
//            
//        }];
        
        //做网络请求 下拉刷新
        [weakself.collectionView.pullToRefreshView stopAnimating];
    }];
    
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        
//        weakself.manager = [[NewFirstVCManager alloc] init];
//        
//        [weakself.manager requestWithStrUserId:[UserInfoData shareUserInfoData].strUserId Page:++weakself.page size:kSizeCount searchDataCompleteBloock:^(NewFirstData *searchData) {
//            
//            
//            if (searchData) {
//                for (NewFirstVCCellData *data in searchData.datalist) {
//                    [weakself.dataArry addObject:data];
//                }
//            }
//            
//            [weakself.tableview reloadData];
//            
//        }];
        
        //网络请求 上拉加载更多
        [weakself.collectionView.infiniteScrollingView stopAnimating];
    }];
}



#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.groomData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    
    cell.data = self.groomData[indexPath.item];
    
    
    
    return cell;
}

- (void)collectionView:(GroomCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(groomCell: didSelectItem:)])
    {
        [self.delegate groomCell:collectionView didSelectItem:indexPath];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, self.width, self.height);
}

@end
