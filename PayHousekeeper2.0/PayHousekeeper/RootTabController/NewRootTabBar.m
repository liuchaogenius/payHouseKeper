//
//  NewRootTabBar.m
//  PayHousekeeper
//
//  Created by 1 on 2017/2/16.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "NewRootTabBar.h"
#import "FactoryModel.h"
#import "MQNavigationController.h"
#import "TPResetSubFrameButton.h"
#import "MatchingViewController.h"

#define kTabBarMiddleBtSpace 6
#define kSelectGender [NSString stringWithFormat:@"dongdongSelectGender_%@",[UserInfoData shareUserInfoData].strUserCode]

@interface NewRootTabBar ()<DDAlertViewDelegate>
{
    UIView *bottomview;
    UIView *tabbarBgview;
    UIScrollView *contentScrollview;
    NSMutableArray *navArry;
    UIButton *middleSelButton;
    BOOL isMiddleEx;
    
//    UIView *maskview;
    UIButton *allButton;
    UIButton *femaleButton;
    UIButton *manButton;
    UIButton *tempMiddleBt;
    UIButton *animationBt;
    int oldSelctIndex;
    int currentIndex;
}
@end

@implementation NewRootTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    contentScrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentScrollview];
    contentScrollview.scrollEnabled = NO;
    contentScrollview.pagingEnabled = NO;
    [self addBottomView];
    [self addRootViewController];
}

- (void)addBottomView
{
    bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-kTabBarMiddleBtSpace-70, kMainScreenWidth, 70+kTabBarMiddleBtSpace)];
    bottomview.backgroundColor = kClearColor;//[UIColor redColor];
    [self.view addSubview:bottomview];
    [self.view bringSubviewToFront:bottomview];
    
    tabbarBgview = [[UIView alloc] initWithFrame:CGRectMake(0, bottomview.height-49, kMainScreenWidth, 49)];
    tabbarBgview.backgroundColor = [UIColor whiteColor];
    [bottomview addSubview:tabbarBgview];
}

- (void)addRootViewController
{
    oldSelctIndex= 0;
    NSArray *arry = [[FactoryModel shareFactoryModel] getTabbarArrys];
    navArry = [NSMutableArray arrayWithCapacity:0];
    if(arry && arry.count>0)
    {
        for(int i=0;i<arry.count;i++)
        {
            UIViewController *vc = [arry objectAtIndex:i];
            MQNavigationController *nav = [[MQNavigationController alloc] initWithRootViewController:vc];
            [navArry addObject:nav];
            //去导航底部黑线
            [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            [nav.navigationBar setShadowImage:[[UIImage alloc] init]];
            nav.view.frame = CGRectMake(i*kMainScreenWidth, 0, kMainScreenWidth, kMainScreenHeight);
            [contentScrollview addSubview:nav.view];
        }
        [contentScrollview setContentSize:CGSizeMake(kMainScreenWidth*arry.count, kMainScreenHeight)];
    }
    [self addBottomBt];
}

- (void)addBottomBt
{
    int count = (int)navArry.count;
    
    int offsetx = (bottomview.width-44*2-70)/4;
    int startX = offsetx;
    for(int i=0;i<count;i++)
    {
        TPResetSubFrameButton *button = [[TPResetSubFrameButton alloc] initWithFrame:CGRectMake(startX, bottomview.height-49+4, 44, 44)];
        button.tag = i;
        button.backgroundColor = kClearColor;
        [button addTarget:self action:@selector(chanageRootNav:) forControlEvents:UIControlEventTouchUpInside];
        if(i == 0)
        {
            UIImage *tempImg = [UIImage imageNamed:@"tabbar_firstIcon"];
            [button setImage:tempImg forState:UIControlStateNormal];
            [button setTitle:@"探索" forState:UIControlStateNormal];
            button.imageY = 2;
            button.labelY = 23;
            button.labelOffsetY = 8;
            button.titleLabel.font = kFont10;
            [button setTitleColor:kGrayColor forState:UIControlStateNormal];
            
            [button setImage:[UIImage imageNamed:@"tabbar_firstIcon_sel"] forState:UIControlStateHighlighted];
            [button setTitleColor:kFcolorFontGreen forState:UIControlStateHighlighted];
        }
        else if(i == 1)
        {
            UIImage *btImg = [UIImage imageNamed:@"tabbar_middle_button_nor"];
//            middleSelButton = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, 0, btImg.size.width, btImg.size.height)];
            middleSelButton = (UIButton *)button;
            middleSelButton.frame = CGRectMake((kMainScreenWidth-btImg.size.width)/2, 0, btImg.size.width, btImg.size.height);
            [middleSelButton setImage:btImg forState:UIControlStateNormal];
            [middleSelButton addSubview:[self getanimationBt:middleSelButton.bounds]];
//            [middleSelButton addTarget:self action:@selector(vedioButtonItem) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(i == 2)
        {
            UIImage *tempImg = [UIImage imageNamed:@"tabbar_thirdicon"];
            [button setImage:tempImg forState:UIControlStateNormal];
            [button setTitle:@"朋友" forState:UIControlStateNormal];
            button.imageY = 2;
            button.labelY = 23;
            button.labelOffsetY = 8;
            button.titleLabel.font = kFont10;
            [button setTitleColor:kGrayColor forState:UIControlStateNormal];
            
            [button setImage:[UIImage imageNamed:@"tabbar_thirdicon_sel"] forState:UIControlStateHighlighted];
            [button setTitleColor:kFcolorFontGreen forState:UIControlStateHighlighted];
        }
        [bottomview addSubview:button];
        startX = button.right+offsetx;
    }
}

- (void)chanageRootNav:(UIButton *)aBt
{
    currentIndex = (int)aBt.tag;
    [contentScrollview setContentOffset:CGPointMake(kMainScreenWidth*currentIndex, 0) animated:YES];
    if(currentIndex == 1)
    {
        [self vedioButtonItem];
    }
    else
    {
        [self hiddenMatchBtns];
    }
    oldSelctIndex = currentIndex;
    
}

#pragma mark  中间按钮点击事件
- (void)vedioButtonItem
{
//    if(!maskview)
//    {
//        maskview = [[UIView alloc] initWithFrame:self.view.bounds];
//        [self.view addSubview:maskview];
//        [maskview addTarget:self action:@selector(hiddenMaskview)];
//    }
//    maskview.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
//    maskview.alpha = 0.0;
//    maskview.hidden = NO;
    
    
    UIImage *btImg = [UIImage imageNamed:@"match_all_normal"];
    if(!allButton)
    {
        allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [allButton setImage:btImg forState:UIControlStateNormal];
        [allButton setImage:IMG(@"match_all_selected") forState:UIControlStateSelected];
        allButton.frame = CGRectMake(kMainScreenWidth/2.0-55-btImg.size.width, self.view.bottom-270, btImg.size.width, btImg.size.height+25);
        [allButton setTitle:@"全部" forState:UIControlStateNormal];
        [allButton setTitleEdgeInsets:UIEdgeInsetsMake(btImg.size.height+25, -allButton.width, 0, 0)];
        allButton.titleLabel.font = kFont12;
        [allButton addTarget:self action:@selector(pushMatchViewController:) forControlEvents:UIControlEventTouchUpInside];
        allButton.selected = [[self readSelectGender] isEqualToString:@"A"];
        
        //[self customTabbarButton:btImg rect:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.view.bottom-170-btImg.size.height, btImg.size.width, btImg.size.height) tcolor:RGBCOLOR(33,235,190) title:@"全部" hightImg:[UIImage imageNamed:@"match_all_selected"] target:self sel:@selector(pushMatchViewController)];
        //        allButton = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
        [self.view addSubview:allButton];
    }
//    allButton.frame = CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.view.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height);
    //    [allButton addTarget:self action:@selector(pushMatchViewController) forControlEvents:UIControlEventTouchUpInside];
    //    [allButton setImage:btImg forState:UIControlStateNormal];
    //    [allButton addTarget:self action:@selector(pushMatchViewController)];
    
    if(!femaleButton)
    {
        femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [femaleButton setImage:IMG(@"match_female_normal") forState:UIControlStateNormal];
        [femaleButton setImage:IMG(@"match_female_selected") forState:UIControlStateSelected];
        femaleButton.frame = CGRectMake(kMainScreenWidth/2.0, self.view.bottom-270, btImg.size.width, btImg.size.height+25);
        [femaleButton setTitle:@"女" forState:UIControlStateNormal];
        [femaleButton setTitleEdgeInsets:UIEdgeInsetsMake(btImg.size.height+25, -femaleButton.width, 0, 0)];
        femaleButton.titleLabel.font = kFont12;
        [self.view addSubview:femaleButton];
        [femaleButton addTarget:self action:@selector(pushMatchViewController:) forControlEvents:UIControlEventTouchUpInside];
        femaleButton.selected = [[self readSelectGender] isEqualToString:@"F"];
    }
    
    if(!manButton)
    {
        manButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [manButton setImage:IMG(@"match_man_normal") forState:UIControlStateNormal];
        [manButton setImage:IMG(@"match_man_selected") forState:UIControlStateSelected];
        manButton.frame = CGRectMake(kMainScreenWidth/2.0, self.view.bottom-270, btImg.size.width, btImg.size.height+25);
        [manButton setTitle:@"男" forState:UIControlStateNormal];
        [manButton setTitleEdgeInsets:UIEdgeInsetsMake(btImg.size.height+25, -manButton.width, 0, 0)];
        manButton.titleLabel.font = kFont12;
        [self.view addSubview:manButton];
        [manButton addTarget:self action:@selector(pushMatchViewController:) forControlEvents:UIControlEventTouchUpInside];
        manButton.selected = [[self readSelectGender] isEqualToString:@"M"];
    }
    
//    if(!manButton)
//    {
//        manButton = [self customTabbarButton:[UIImage imageNamed:@"match_man_normal"] rect:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.view.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height) tcolor:RGBCOLOR(255,205,0) title:@"男" hightImg:[UIImage imageNamed:@"match_man_selected"] target:self sel:@selector(pushSmallVideoViewController)];
//        //[[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
//        [self.view addSubview:manButton];
//    }
//    manButton.frame = CGRectMake((kMainScreenWidth-btImg.size.width)/2, kMainScreenHeight-kTabBarMiddleBtSpace-70, btImg.size.width, btImg.size.height);
//    //    [manButton addTarget:self action:@selector(pushSmallVideoViewController)];
//    //    [manButton addTarget:self action:@selector(pushSmallVideoViewController) forControlEvents:UIControlEventTouchUpInside];
//    //    [manButton setImage:[UIImage imageNamed:@"tabbar_record_video"] forState:UIControlStateNormal];
    
    if(!tempMiddleBt)
    {
        tempMiddleBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.view.bottom-kTabBarMiddleBtSpace-70, 70, 70)];
        [tempMiddleBt addTarget:self action:@selector(hiddenMatchBtns) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tempMiddleBt];
        [self.view bringSubviewToFront:tempMiddleBt];
    }

    
    [tempMiddleBt addSubview:[self getanimationBt:tempMiddleBt.bounds]];
    
    UIImage *btImg11 = [UIImage imageNamed:@"tabbar_middle_button_nor"];
    tempMiddleBt.frame = CGRectMake(middleSelButton.left, kMainScreenHeight-kTabBarMiddleBtSpace-70, btImg11.size.width, btImg11.size.height);
    [tempMiddleBt setImage:btImg11 forState:UIControlStateNormal];
    
    
    allButton.center = tempMiddleBt.center;
    femaleButton.center = tempMiddleBt.center;
    manButton.center = tempMiddleBt.center;
    
    CGPoint acenter = allButton.center;
    CGPoint fcenter = allButton.center;
    CGPoint mcenter = manButton.center;
    if(isMiddleEx == NO)
    {
        tempMiddleBt.hidden = NO;
        allButton.hidden = NO;
        femaleButton.hidden = NO;
        manButton.hidden = NO;
        CGAffineTransform at =CGAffineTransformMakeRotation(-M_PI/2);
        [UIView animateWithDuration:0.2 animations:^{
            allButton.center = CGPointMake(acenter.x-btImg.size.width-55, self.view.bottom-230+allButton.height/2.0);
            femaleButton.center = CGPointMake(fcenter.x, self.view.bottom-230+femaleButton.height/2.0);
            manButton.center = CGPointMake(mcenter.x+btImg.size.width+55, self.view.bottom-230+manButton.height/2.0);
//            maskview.alpha = 1.0;
            [animationBt setTransform:at];
            animationBt.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
        isMiddleEx = YES;
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            allButton.center = middleSelButton.center;
            femaleButton.center = middleSelButton.center;
            manButton.center = middleSelButton.center;
//            maskview.alpha = 0.0;
        } completion:^(BOOL finished) {
//            maskview.hidden = YES;
        }];
        isMiddleEx = NO;
    }
}

- (UIButton *)getanimationBt:(CGRect)aRect
{
    if(!animationBt)
    {
        animationBt = [[UIButton alloc] init];
    }
    animationBt.userInteractionEnabled = NO;
    [animationBt setImage:[UIImage imageNamed:@"tabbarMiddleRecor"] forState:UIControlStateNormal];
    animationBt.frame = aRect;
    return animationBt;
}

- (void)hiddenMatchBtns
{
//    CGAffineTransform at =CGAffineTransformMakeRotation(M_PI/2);
    [UIView animateWithDuration:0.2 animations:^{
        allButton.center = tempMiddleBt.center;
        femaleButton.center = tempMiddleBt.center;
        manButton.center = tempMiddleBt.center;
        animationBt.alpha = 1.0;
        [animationBt setTransform:CGAffineTransformIdentity];
//        maskview.alpha = 0.0;
    } completion:^(BOOL finished) {
//        maskview.hidden = YES;
        tempMiddleBt.hidden = YES;
        allButton.hidden = YES;
        femaleButton.hidden = YES;
        manButton.hidden = YES;
        [middleSelButton addSubview:[self getanimationBt:middleSelButton.bounds]];
    }];
    isMiddleEx = NO;
}

- (UINavigationController *)getCurrentNavController
{
    if(currentIndex < navArry.count)
    {
        UINavigationController *nav = [navArry objectAtIndex:currentIndex];
        return nav;
    }
    return nil;
}

- (void)setSelectTabBarViewController:(int)aIndex
{
    if(aIndex<navArry.count)
    {
        [contentScrollview setContentOffset:CGPointMake(kMainScreenWidth*aIndex, 0) animated:YES];
        currentIndex = oldSelctIndex = aIndex;
        UINavigationController *nav = [navArry objectAtIndex:aIndex];
        [nav popToRootViewControllerAnimated:YES];
    }
}
- (void)refreshNewRootUserHead
{
    [[FactoryModel shareFactoryModel] refreshNewRootUserHead];
}
#pragma mark 进入视频匹配页面
- (void)pushMatchViewController:(UIButton *)btn
{
    if(btn != allButton && ![UserInfoData shareUserInfoData].isVip)
    {
        DDAlertView *alert = [[DDAlertView alloc] initWithTitleText:nil headUrlStr:nil valueArray:nil detailsText:@"开通VIP才能选择匹配性别哦~" closeText:@"取消" nextText:@"开通VIP" translucencyBackground:YES type:BlackAlertViewTypeNormal];
        alert.delegate = self;
        [alert show];
        return;
    }
    
    if(!btn.selected)
    {
        allButton.selected = NO;
        femaleButton.selected = NO;
        manButton.selected = NO;
        btn.selected = YES;
        
        [self saveSelectGender];
    }
    
    
    if([GPUImageManager sharedInstance].isOpenCameraService)
    {
        [MobClick event:MsgClickStart];
        MatchingViewController *vc = [[MatchingViewController alloc] init];
        vc.currentGender = [self readSelectGender];
        if([DDSystemInfoManager sharedInstance].isOn)
        {
            vc.isOkTime = [[DDSystemInfoManager sharedInstance] isOKTime];
        }
        else
        {
            vc.isOkTime = YES;
        }
        [[DLAPPDELEGATE.newtabr getCurrentNavController] pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"视频前需要打开相机权限"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveSelectGender
{
    NSString *currentGender = @"A";
    if(femaleButton.selected)
        currentGender = @"F";
    else if(manButton.selected)
        currentGender = @"M";
    
    [[NSUserDefaults standardUserDefaults] setObject:currentGender forKey:kSelectGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)readSelectGender
{
    NSString *selectGender = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(!selectGender)
        selectGender = @"A";
    return selectGender;
}

#pragma mark 自定义按钮
- (UIView *)customTabbarButton:(UIImage *)aImg rect:(CGRect)aRect tcolor:(UIColor *)aColor title:(NSString *)aTitle hightImg:(UIImage *)aHightImg target:(id)aTarget sel:(SEL)aAction
{
    UIView *view = [[UIView alloc] initWithFrame:aRect];
    view.backgroundColor = kClearColor;
    UIButton *imgview = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aImg.size.height)];
    [imgview setImage:aImg forState:UIControlStateNormal];
    [imgview setImage:aHightImg forState:UIControlStateHighlighted];
    [imgview addTarget:self action:aAction forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:imgview];
    
    UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgview.bottom+10, aRect.size.width, 13)];
    tLabel.backgroundColor = kClearColor;
    tLabel.textColor = aColor;
    tLabel.text = aTitle;
    tLabel.font = kFont12;
    tLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tLabel];
    
    return view;
}

#pragma mark 隐藏bottomview
- (void)hiddenBottomView
{
    if(bottomview.left == 0)
    {
        CGRect rect = bottomview.frame;
        [UIView animateWithDuration:0.2 animations:^{
            bottomview.frame = CGRectMake(-kMainScreenWidth, rect.origin.y, rect.size.width, rect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)showBottomView
{
    if(bottomview.left != 0)
    {
        CGRect rect = bottomview.frame;
        [UIView animateWithDuration:0.2 animations:^{
            bottomview.frame = CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DDAlertViewDelegate
- (void)alerViewDidBtnClicked:(UIButton *)btn
{
    
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
