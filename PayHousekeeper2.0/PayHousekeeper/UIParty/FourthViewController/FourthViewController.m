//
//  FourthViewController.m
//  YHB_Prj
//
//  Created by  striveliu on 14-11-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "FourthViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import "UserInfoData.h"
#import "PersonInfoVipInfoCell.h"
#import "TPItemBuilder.h"
#import "TPItemCompontentCell.h"
#import "DongBiViewController.h"
#import "PersonVIPViewController.h"
#import "DongBiViewController.h"
#import "MyWalletViewController.h"
#import "PersonLevelViewController.h"
#import "PersonInfoModifyVC.h"
#import "PersonSettingViewController.h"
#import "EditMoodsControl.h"
#import "DDLoginManager.h"
#import "InviteFriendViewController.h"
#import "GPUImageManager.h"
#import "UIViewAdaptive.h"
#import "PersonInfoManager.h"
#import "DDSystemInfoManager.h"
#import "AppDelegate.h"

#define kCurrentTHeadViewHeight FitSize(307*kMainScreenHeight/667)

@interface FourthViewController ()<UITableViewDelegate, UITableViewDataSource>
{
//    UIView *contentview;
//    NSString *strHeadUrl;
//    NSString *strNick;
//    int sexType;
//    NSString *strUserid;
    NSString *strSingContent;
    UIImageView *headImgview;
    UIImage *userHeadImg;
    UILabel *namelabel;
    UILabel *numLabel;
    UILabel *xzLabel;
    UILabel *ageLabel;
    UILabel *singLabel;
//    int isVip;
//    int vipLevel;
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic) BOOL isVip;
@property (nonatomic, strong) NSString *vipName;
@property (nonatomic) BOOL isSwithOn;
@property (nonatomic, strong)UIImageView *imgView;
@end

@implementation FourthViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.baseRatio = RatioBaseOn_6_ScaleFor5;
        self.manager = [[PersonInfoManager alloc] init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavgationBarClear];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = kClearColor;//[UIColor colorWithHexValue:0x00d898];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isSwithOn = [DDSystemInfoManager sharedInstance].isOn;
//    contentview = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kMainScreenWidth, kMainScreenHeight-64)];
//    contentview.backgroundColor = kClearColor;
//    [self.view addSubview:contentview];
//    [self setUserIsCurrentUse];
//    [self addHeadBgview];
//    [self settitleLabel:@"个人资料"];
//    vipLevel = [UserInfoData shareUserInfoData].userLeval;
    [self setLeftButton:[UIImage imageNamed:@"topleftimg"] title:nil target:self action:@selector(topLeftButtonItem)];
    [self setRightButton:[UIImage imageNamed:@"toprightimg"] title:nil titlecolor:nil target:self action:@selector(topRightButtoItem)];
    
    [self setupTableView];
}

- (void)setHeadBgview:(UIView*)aView
{
    UIImageView *bgview = [[UIImageView alloc] initWithFrame:aView.bounds];
    //    bgview.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    
    if(userHeadImg)
    {
//        [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
        UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:userHeadImg];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        [bgview setImage:tempImg];
        //            });
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl]];
            UIImage *image = [UIImage imageWithData:imgdata];
            if(image)
            {
//                [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
                UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [bgview setImage:tempImg];
                });
            }
        });
    }
    
    
    //    [bgview sd_setImageWithURL:[NSURL URLWithString:strHeadUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    //       if(image)
    //       {
    //           [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
    //           UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:image];
    //           bgview.backgroundColor = [UIColor colorWithPatternImage:tempImg];
    //       }
    //    }];
    //    bgview.contentMode = UIViewContentModeScaleAspectFill;
    [aView addSubview:bgview];
    //    [aView sendSubviewToBack:bgview];
    //    [self.view sendSubviewToBack:contentview];
}


- (void)topRightButtoItem
{
//    WeakSelf(self)
//    [[EditMoodsControl sharedInstance] show];
//    [EditMoodsControl sharedInstance].endEditMoods = ^(NSString *string){
//        if(!string|| string.length == 0)
//        {
//            [weakself.view makeToast:@"请输入心情" duration:0.6 position:CSToastPositionCenter];
//            return;
//        }
//        [[DDLoginManager shareLoginManager] requestMood:string completeBlock:^(BOOL ret) {
//            
//        }];
//    };
    [self pushIntoModifyInfoVC];
}

- (void)topLeftButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 添加tableview
- (void)setupTableView
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width,kMainScreenHeight) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = kFTableViewColor;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.tableHeaderView = [self tableviewHeadview];
//    [self.tableview setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
    [self.view addSubview:self.tableview];
}

#pragma mark 控制不上啦
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y <= 0)
    {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}
#pragma mark add talbleivew headview
- (UIView *)tableviewHeadview
{
    // 父控件/背景图
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, FitSize(321))];
    self.imgView.backgroundColor = kClearColor;//[UIColor colorWithHexValue:0x00d898];
//    [self setHeadBgview:view];
    
    // 圆头像
    headImgview = [[UIImageView alloc] initWithFrame:CGRectIntegral(CGRectMake((kMainScreenWidth-FitSize(70))/2, FitSize(78), FitSize(70), FitSize(70)))];
    MLOG(@"fourthVCHeadurl = %@",[UserInfoData shareUserInfoData].strHeadUrl);
    //    [headImgview sd_setImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] placeholderImage:[UIImage imageNamed:@"personInfoheadimg"]];
    [headImgview setImage:[UIImage imageNamed:@"personInfoheadimg"]];
    
    WeakSelf(self);
    // 设置圆头像图片
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if(del.headBluryImg)
    {
        [self.imgView setImage:del.headBluryImg];
    }
    else
    {
        if(del.headUserImg)
        {
//            [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
            UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:del.headUserImg];
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [self.imgView setImage:tempImg];
            del.headBluryImg = tempImg;
        }
    }
    if(del.headUserImg)
    {
        [headImgview setImage:del.headUserImg];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSData *tempImgData = [NSData dataWithContentsOfURL:URL([UserInfoData shareUserInfoData].strHeadUrl)];
        if(tempImgData)
        {
            UIImage *img = [UIImage imageWithData:tempImgData];
//            [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
            UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:img];
            dispatch_async(dispatch_get_main_queue(), ^{
                [headImgview setImage:img];
                [weakself.imgView setImage:tempImg];
                del.headBluryImg = tempImg;
                del.headUserImg = img;
            });
        }
    });
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        if (image)
//        {
////            [weakself.imgView setImage:image];
//            [headImgview setImage:image];
//            [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
//            UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:image];
////            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakself.imgView setImage:tempImg];
//            del.headUserImg = image;
//            del.headBluryImg = tempImg;
////            });
//            
//        }
//    }];
    
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        
//        if (image)
//        {
//            [headImgview setImage:image];
//            userHeadImg = image;
//            
//            [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
//            UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:image];
////            dispatch_async(dispatch_get_main_queue(), ^{
//                [imgView setImage:tempImg];
////            });
//            
//        }
//        
//    }];
    
    
    headImgview.userInteractionEnabled = YES;
    headImgview.layer.cornerRadius = FitSize(35.f);
    headImgview.layer.masksToBounds = YES;
    
    [self.imgView addSubview:headImgview];
    
    if([UserInfoData shareUserInfoData].isVip)
    {
        UIImage *vipImg = [UIImage imageNamed:@"VIPIMG"];
        UIImageView *vipImgview = [[UIImageView alloc] initWithFrame:CGRectMake(headImgview.right-FitSize(20), headImgview.bottom-FitSize(20), FitSize(20), FitSize(20))];
        [vipImgview setImage:vipImg];
        [self.imgView addSubview:vipImgview];
    }
    NSString *name = [UserInfoData shareUserInfoData].strUserNick;
    //    CGSize namesize = [name sizeWithFont:kFont17];
    //    int offsetx = (kMainScreenWidth-namesize.width-2-36-2)/2;
    namelabel = [self.view labelWithFrame:CGRectMake(0, headImgview.bottom+FitSize(15), self.view.width, FitSize(19)) text:name textFont:kFont17 textColor:kcolorWhite];
    namelabel.textAlignment = NSTextAlignmentCenter;
    [self.imgView addSubview:namelabel];
    
    int sx = ((kMainScreenWidth-FitSize(37)*3-FitSize(6))/2);
    
    UIView *sexview = [[UIView alloc] initWithFrame:CGRectMake(sx, namelabel.bottom+FitSize(9), FitSize(37), FitSize(15))];
    sexview.layer.cornerRadius = FitSize(7.5f);
    sexview.layer.masksToBounds = YES;
    UIImage *sIcon = nil;
    if([[UserInfoData shareUserInfoData].strSex compare:@"男"] == 0)
    {
        sIcon = [UIImage imageNamed:@"p_boy_icon"];
        sexview.backgroundColor = RGBCOLOR(0, 144, 255);
    }
    else
    {
        sIcon = [UIImage imageNamed:@"p_girl_Icon"];
        sexview.backgroundColor = RGBCOLOR(251, 187, 187);
    }
    UIImageView *simgview = [[UIImageView alloc] initWithFrame:CGRectMake(FitSize(6), FitSize(3), FitSize(7),FitSize(15))];
    simgview.center = CGPointMake(FitSize(10), FitSize(7.5));
    [simgview setImage:sIcon];
    simgview.contentMode = UIViewContentModeScaleAspectFit; // 原来选AspectFill
    [sexview addSubview:simgview];
    //    NSString *sage = [NSString stringWithFormat:@"%d",[UserInfoData shareUserInfoData].strAge];
    ageLabel = [self.view labelWithFrame:CGRectMake(simgview.right, 0, sexview.width-simgview.right, sexview.height) text:[UserInfoData shareUserInfoData].strAge textFont:kFont10 textColor:kcolorWhite];
    ageLabel.textAlignment = NSTextAlignmentCenter;
    [sexview addSubview:ageLabel];
    [self.imgView addSubview:sexview];
    
    //星座
    UIView *xzview = [[UIView alloc] initWithFrame:CGRectMake(sexview.right+FitSize(3), namelabel.bottom+FitSize(9), FitSize(37), FitSize(15))];
    xzview.layer.cornerRadius = FitSize(7.5f);
    xzview.layer.masksToBounds = YES;
    xzview.backgroundColor = RGBCOLOR(130, 185, 227);
    [UIView getTPFitScale:self];
    // kFont10 的数值改为 8 了
    xzLabel = [self.view labelWithFrame:CGRectMake(0, 0, xzview.width, sexview.height) text:[UserInfoData shareUserInfoData].strConstellation textFont:kFont10 textColor:kcolorWhite];
    xzLabel.textAlignment = NSTextAlignmentCenter;
    [xzview addSubview:xzLabel];
    [self.imgView addSubview:xzview];
    
    //////关注数
    UIView *gzview = [[UIView alloc] initWithFrame:CGRectMake(xzview.right+FitSize(3), namelabel.bottom+FitSize(9), FitSize(37), FitSize(15))];
    gzview.layer.cornerRadius = FitSize(7.5f);
    gzview.layer.masksToBounds = YES;
    gzview.backgroundColor = RGBCOLOR(255, 207, 62);
    UIImage *xxIcon = nil;
    xxIcon = [UIImage imageNamed:@"p_xx_icon"];
    UIImageView *xximgview = [[UIImageView alloc] initWithFrame:CGRectMake(FitSize(6), FitSize(3), FitSize(11), FitSize(10))];
    xximgview.center = CGPointMake(FitSize(10), FitSize(7.5));
    [xximgview setImage:xxIcon];
    xximgview.contentMode = UIViewContentModeScaleAspectFit;
    [gzview addSubview:xximgview];
    
    numLabel = [self.view labelWithFrame:CGRectMake(xximgview.right, 0, sexview.width-simgview.right, sexview.height) text:[NSString stringWithFormat:@"%d",[UserInfoData shareUserInfoData].userLeval] textFont:kFont10 textColor:kcolorWhite];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [gzview addSubview:numLabel];
    [self.imgView addSubview:gzview];
    
    NSString *userid = [NSString stringWithFormat:@"咚咚号:%@",[UserInfoData shareUserInfoData].strUserCode];
    UILabel *idlabel = [self.view labelWithFrame:CGRectMake(0, gzview.bottom+FitSize(12), kMainScreenWidth, FitSize(12)) text:userid textFont:kFont12 textColor:kcolorWhite];
    idlabel.textAlignment = NSTextAlignmentCenter;
    [self.imgView addSubview:idlabel];
    strSingContent = [UserInfoData shareUserInfoData].strUserSign;
    if ([strSingContent isEqualToString:@"(null)"]) {
        strSingContent = nil;
    }
    strSingContent = strSingContent?strSingContent:@"好的签名更加吸引人";
    NSString *sigcontent = [NSString stringWithFormat:@"%@",strSingContent];
    CGSize ssize = [sigcontent sizeWithFont:kFont14];
    int line = 1;
    if(ssize.width > (kMainScreenWidth-FitSize(80)))
    {
        line = 2;
    }
    
    singLabel = [self.view labelWithFrame:CGRectMake(FitSize(40), idlabel.bottom+FitSize(10), kMainScreenWidth-FitSize(80), line*ssize.height+FitSize(4)) text:sigcontent textFont:kFont14 textColor:kcolorWhite];
    singLabel.numberOfLines = line;
    singLabel.textAlignment = NSTextAlignmentCenter;
    [self.imgView addSubview:singLabel];
    return self.imgView;
}




#pragma mark push to modifyvc

- (void)pushIntoModifyInfoVC
{
    
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    self.statusBarView.backgroundColor = [UIColor whiteColor];
    [self.tableview addSubview:self.statusBarView];
    
    
    PersonInfoModifyVC *vc = [[PersonInfoModifyVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark Tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, FitSize(15))];
    view.backgroundColor = kClearColor;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount = 0;
    if(section == 0)
    {
        rowCount = 1;
    }
    else if(section == 1)
    {
        rowCount = 3;
        if (self.isSwithOn)
        {
            rowCount--;
        }
    }
    else if(section == 2)
    {
        rowCount = 1;
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    if(indexPath.section == 0)
    {
        rowHeight = FitSize(111);
    }
    else if(indexPath.section == 1)
    {
        rowHeight = FitSize(44);
    }
    else if(indexPath.section == 2)
    {
        rowHeight = FitSize(44);
    }
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        WeakSelf(self);
        PersonInfoVipInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personInfocellIdentifier"];
        if(!cell)
        {
            cell = [[PersonInfoVipInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personInfocellIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        [cell setCellData:[UserInfoData shareUserInfoData].isVip vipName:self.vipName vipLevel:[UserInfoData shareUserInfoData].userLeval buttonClick:^(int tag) {
            [weakself userVipAndLevelItem:tag];
        }];
        return cell;
    }
    else if(indexPath.section == 1)
    {
        NSString *strTitle = nil;
        NSString *strDBCount = @" ";
        if(indexPath.row == 0)
        {
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            strTitle = @"我的充值";
            strDBCount = @"";//[NSString stringWithFormat:@"%lld咚币",[UserInfoData shareUserInfoData].moneyCount];//@"0咚币";
        }
        else if(indexPath.row == 1)
        {
            strTitle = @"我的收益";
            strDBCount = @"";//[NSString stringWithFormat:@"%lld咚果",[UserInfoData shareUserInfoData].shellCount];//@"0咚贝";
            if (self.isSwithOn)
            {
                strTitle = @"邀请好友";
            }
        }
        else if(indexPath.row == 2)
        {
            strTitle = @"邀请好友";
        }
        TPItemCompontentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personinfosetcionOneIdentifier"];
        if(!cell)
        {
            cell = [TPItemCompontentCell itemPersonCellWithBlock:UITableViewCellStyleDefault reuseIdentifier:@"personinfosetcionOneIdentifier" cellHeight:FitSize(44) buildBlock:^(TPItemBuilder *builder) {
                builder.leftContent = strTitle;
                builder.isHiddenArrow = NO;
//                builder.isTopLine = YES;
                builder.isBottomLine = YES;
                builder.rightContent = strDBCount;
                builder.rightTextColor = [UIColor colorWithHexValue:0x00d898];
//                if(indexPath.row == 2||(self.isSwithOn&&indexPath.row==1))
//                {
//                    builder.isBottomLine = YES;
//                }
                if([strTitle isEqualToString:@"邀请好友"])
                {
                    builder.isBottomLine = NO;
                }
            }];
        }
        else
        {
            [cell updateLeftContent:strTitle];
            [cell updateRightContent:strDBCount];
        }
        return cell;
    }
    else if(indexPath.section == 2)
    {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        NSString *strTitle = @"设置";
        TPItemCompontentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personinfosetcionTwoIdentifier"];
        if(!cell)
        {
            cell = [TPItemCompontentCell itemPersonCellWithBlock:UITableViewCellStyleDefault reuseIdentifier:@"personinfosetcionTwoIdentifier" cellHeight:FitSize(44) buildBlock:^(TPItemBuilder *builder) {
                builder.leftContent = strTitle;
                builder.isHiddenArrow = NO;
//                builder.isTopLine = YES;
//                builder.isBottomLine = YES;
            }];
        }
        else
        {
            [cell updateLeftContent:strTitle];
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView sele];
    
    
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    self.statusBarView.backgroundColor = [UIColor whiteColor];
    [self.tableview addSubview:self.statusBarView];

    
    
    if(indexPath.section == 1)
    {
        UIViewController *vc = nil;
        if(indexPath.row == 0)
        {
            
            vc = [[DongBiViewController alloc] init];

        }
        else if(indexPath.row == 1)
        {
            if (self.isSwithOn)
            {
                vc = [[InviteFriendViewController alloc] init];
            }
            else
            {
                vc = [[MyWalletViewController alloc] init];
            }
        }
        else if(indexPath.row == 2)
        {
            vc = [[InviteFriendViewController alloc] init];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 2)
    {
        PersonSettingViewController *setvc = [[PersonSettingViewController alloc] init];
        [self.navigationController pushViewController:setvc animated:YES];
    }
}

#pragma mark 处理vip和level的button点击事件
- (void)userVipAndLevelItem:(int)aTag
{
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    self.statusBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.statusBarView];
    
    
    WeakSelf(self)
    if(aTag == 0)
    {
        PersonVIPViewController *vc = [[PersonVIPViewController alloc] init];
        vc.vipName = weakself.vipName;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        PersonLevelViewController *vc = [[PersonLevelViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    [super viewWillAppear:animated];
    if(self.imgView.image)
    {
        
//        WeakSelf(self);
//        
//        // 设置圆头像图片
//        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            if (image)
//            {
//                [weakself.imgView setImage:image];
//                [headImgview setImage:image];
//                
//                [[GPUImageManager sharedInstance] setBlurFilterValue:0.4];
//                UIImage *tempImg = [[GPUImageManager sharedInstance] getBlurImage:image];
//                //            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakself.imgView setImage:tempImg];
//                //            });
//                
//            }
//        }];
//        
//        namelabel.text = [UserInfoData shareUserInfoData].strUserNick;
//        numLabel.text = [NSString stringWithFormat:@"%d", [UserInfoData shareUserInfoData].userLeval];
//        xzLabel.text = [UserInfoData shareUserInfoData].strConstellation;
//        ageLabel.text = [UserInfoData shareUserInfoData].strAge;
//        singLabel.text = [UserInfoData shareUserInfoData].strUserSign;
//
        self.tableview.tableHeaderView = [self tableviewHeadview];
        [self.tableview reloadData];
    }
    
    
    [self firstMovingToParentvc];
}


//
- (void)firstMovingToParentvc
{
    
    
    WeakSelf(self);
    [self.manager getUserExtInfo:^(BOOL isVip, NSString *vipName) {
        if(vipName)
        {
            if(isVip != [UserInfoData shareUserInfoData].isVip)
            {
                [[UserInfoData shareUserInfoData] setUserVip:isVip];
            }
            weakself.vipName = vipName;
            
            
            // 重新设置头部数据
//            weakself.tableview.tableHeaderView = [weakself tableviewHeadview];
            
            [weakself.tableview reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
