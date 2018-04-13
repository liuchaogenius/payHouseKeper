//
//  RootTabBarController.m
//  Hubanghu
//
//  Created by  striveliu on 14-10-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "RootTabBarController.h"
#import "FBKVOController.h"
#import "ViewInteraction.h"
#import "FactoryModel.h"
#import "MQNavigationController.h"

#define kTabBarMiddleBtSpace 6
@interface RootTabBarController ()
{
    
    NSInteger newSelectIndex;
    NSInteger oldSelectIndex;
    NSMutableArray *navArry;
    UIButton *middleSelButton;
//    FBKVOController *loginObserver;
//    FBKVOController *leftViewObserver;
    BOOL isMiddleEx;
    BOOL isGoBack;
    
    UIView *maskview;
//    UIButton *matchButton;
//    UIButton *recordVedioBt;
    UIView *matchButton;
    UIView *recordVedioBt;
    UIButton *tempMiddleBt;
}
@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    self.delegate = self;
    isGoBack = NO;
    [self initTabViewController];
    [self initTabBarItem];
    [self initNotifyRegister];
}

- (void)initNotifyRegister
{
//    [NotifyFactoryObject registerLoginMsgNotify:self action:@selector(showLoginViewController:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)initTabViewController
{
    NSArray *arry = [[FactoryModel shareFactoryModel] getTabbarArrys];
    navArry = [NSMutableArray arrayWithCapacity:0];
    if(arry && arry.count>0)
    {
        for(UIViewController *vc in arry)
        {
            MQNavigationController *nav = [[MQNavigationController alloc] initWithRootViewController:vc];
            [navArry addObject:nav];
            //去导航底部黑线
            [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            [nav.navigationBar setShadowImage:[[UIImage alloc] init]];
        }
    }

    self.viewControllers = navArry;
}

- (void)initTabBarItem
{
    //[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:[NSString stringWithFormat:@"TabBarItem_sel"]]];
    //if(kSystemVersion<7.0)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, self.tabBar.height + 5)];
        [imageView setImage:[self createImageWithColor:[UIColor clearColor]]];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [self.tabBar insertSubview:imageView atIndex:0];
        [[UITabBar appearance] setShadowImage:[self createImageWithColor:[UIColor clearColor]]];
        [[UITabBar appearance] setBackgroundImage:[self createImageWithColor:[UIColor clearColor]]];
        self.tabBar.backgroundColor = [UIColor clearColor];
//        UIImage *img = [[self createImageWithColor:[UIColor clearColor]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//        [[UITabBar appearance] setBackgroundImage:img];
//        self.tabBar.backgroundColor = [UIColor clearColor];
//        self.tabBar.translucent = YES;
//        [[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
//        self.tabBar.shadowImage = [[UIImage alloc] init];
    }
    for(int i=0; i<navArry.count;i++)
    {
        if(i != 1)
        {
            UITabBarItem *tabBarItem = self.tabBar.items[i];
            UIImage *norimg = [UIImage imageNamed:[NSString stringWithFormat:@"TabBarItem_nor_%d",i+1]];
            UIImage *selimg = [UIImage imageNamed:[NSString stringWithFormat:@"TabBarItem_sel_%d",i+1]];

            tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            tabBarItem.title = [self getTabbarTitle:i];
            if(kSystemVersion>=7.0)
            {
                norimg = [norimg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                selimg = [selimg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                tabBarItem.image = norimg;
                tabBarItem.selectedImage = selimg;
                tabBarItem.tag = i;
            }
        }
        else
        {
            UIImage *btImg = [UIImage imageNamed:@"tabbar_middle_button_nor"];
            middleSelButton = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.height-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
            [middleSelButton setImage:btImg forState:UIControlStateNormal];
            [middleSelButton addTarget:self action:@selector(vedioButtonItem) forControlEvents:UIControlEventTouchUpInside];
            [self.tabBar addSubview:middleSelButton];
            [self.tabBar bringSubviewToFront:middleSelButton];
        }
    }
    MLOG(@"tabbarHeight=%f",self.tabBar.frame.size.height);
}

- (NSString *)getTabbarTitle:(int)aIndex
{
    NSString *tempTitle = @"";
    if(aIndex == 0)
    {
        tempTitle = @"探索";
    }
    else if(aIndex == 1)
    {
        tempTitle = @" ";
    }
    else if(aIndex == 2)
    {
        tempTitle = @"朋友";
    }
    else if(aIndex == 3)
    {
        tempTitle = @"我";
    }
    return tempTitle;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    MLOG(@"shouldtabsel = %lu", (unsigned long)tabBarController.selectedIndex);
    oldSelectIndex = tabBarController.selectedIndex;
    if(viewController == [navArry objectAtIndex:1])
    {
        return YES;
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    MLOG(@"tabsel = %ld", (unsigned long)tabBarController.selectedIndex);
    newSelectIndex = tabBarController.selectedIndex;
}

- (void)setSelectTabBarViewController:(int)aIndex
{
    self.selectedIndex = aIndex;
    if(aIndex<navArry.count)
    {
        UINavigationController *tvc = [navArry objectAtIndex:aIndex];
        [tvc popToRootViewControllerAnimated:YES];
    }
}

#pragma mark  中间按钮点击事件
- (void)vedioButtonItem
{
    if(!maskview)
    {
        maskview = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:maskview];
        [maskview addTarget:self action:@selector(hiddenMaskview)];
    }
    maskview.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    maskview.alpha = 0.0;
    maskview.hidden = NO;
    
    
    UIImage *btImg = [UIImage imageNamed:@"tabbar_match_video"];
    if(!matchButton)
    {
        matchButton = [self customTabbarButton:btImg rect:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height) tcolor:RGBCOLOR(33,235,190) title:@"视频匹配" hightImg:[UIImage imageNamed:@"tabbar_match_video_sel"] target:self sel:@selector(pushMatchViewController)];
//        matchButton = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
        [self.view addSubview:matchButton];
    }
    matchButton.frame = CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height);
//    [matchButton addTarget:self action:@selector(pushMatchViewController) forControlEvents:UIControlEventTouchUpInside];
//    [matchButton setImage:btImg forState:UIControlStateNormal];
//    [matchButton addTarget:self action:@selector(pushMatchViewController)];
    
    if(!recordVedioBt)
    {
        recordVedioBt = [self customTabbarButton:[UIImage imageNamed:@"tabbar_record_video"] rect:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height) tcolor:RGBCOLOR(255,205,0) title:@"小视频" hightImg:[UIImage imageNamed:@"tabbar_record_video_sel"] target:self sel:@selector(pushSmallVideoViewController)];
        //[[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
        [self.view addSubview:recordVedioBt];
    }
    recordVedioBt.frame = CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height);
//    [recordVedioBt addTarget:self action:@selector(pushSmallVideoViewController)];
//    [recordVedioBt addTarget:self action:@selector(pushSmallVideoViewController) forControlEvents:UIControlEventTouchUpInside];
//    [recordVedioBt setImage:[UIImage imageNamed:@"tabbar_record_video"] forState:UIControlStateNormal];
    
    if(!tempMiddleBt)
    {
        tempMiddleBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-btImg.size.width)/2, self.tabBar.bottom-kTabBarMiddleBtSpace-btImg.size.height, btImg.size.width, btImg.size.height)];
        [tempMiddleBt addTarget:self action:@selector(hiddenMaskview) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tempMiddleBt];
        [self.view bringSubviewToFront:tempMiddleBt];
    }
    [tempMiddleBt setImage:[UIImage imageNamed:@"tabbar_match_video"] forState:UIControlStateNormal];
    
    CGPoint mcenter = matchButton.center;
    CGPoint rcenter = recordVedioBt.center;
    if(isMiddleEx == NO)
    {
        tempMiddleBt.hidden = NO;
        matchButton.hidden = NO;
        recordVedioBt.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            matchButton.center = CGPointMake(mcenter.x-btImg.size.width-10, mcenter.y-btImg.size.height-10);
            recordVedioBt.center = CGPointMake(rcenter.x+btImg.size.width+10, rcenter.y-btImg.size.height-10);
            maskview.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
        isMiddleEx = YES;
        self.selectedIndex = 1;
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            matchButton.center = middleSelButton.center;
            recordVedioBt.center = middleSelButton.center;
            maskview.alpha = 0.0;
        } completion:^(BOOL finished) {
            maskview.hidden = YES;
        }];
        isMiddleEx = NO;
    }
}

- (void)hiddenMaskview
{
    [UIView animateWithDuration:0.2 animations:^{
        matchButton.center = tempMiddleBt.center;
        recordVedioBt.center = tempMiddleBt.center;
        maskview.alpha = 0.0;
    } completion:^(BOOL finished) {
        maskview.hidden = YES;
        tempMiddleBt.hidden = YES;
        matchButton.hidden = YES;
        recordVedioBt.hidden = YES;
    }];
    isMiddleEx = NO;
}

- (UINavigationController *)getNavController
{
    if(self.selectedIndex < navArry.count)
    {
        UINavigationController *nav = [navArry objectAtIndex:self.selectedIndex];
        return nav;
    }
    return nil;
}

- (void)refreshNewRootUserHead
{
    [[FactoryModel shareFactoryModel] refreshNewRootUserHead];
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

#pragma mark 进入视频匹配页面
- (void)pushMatchViewController
{
    [self hiddenMaskview];
}

#pragma mark 进入小视频页面
- (void)pushSmallVideoViewController
{
    [self hiddenMaskview];
    UIViewController *rootvc = [[FactoryModel shareFactoryModel] getSecondViewController];
    //    [rootvc.navigationController pushViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#>]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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
