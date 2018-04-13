//
//  MQLoginViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MQLoginViewController.h"
#import "LBBanner.h"
#import "TPResetSubFrameButton.h"
#import "IphoneLoginVC.h"
#import "SCach.h"
#import "UserInfoData.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "QQLoginService.h"
#import "WXLoginService.h"
#import "AdditionalPersonInfoVC.h"
#import "UserProtocalViewcontroller.h"
#define kRedirectURI    @"http://www.sina.com"
#define LAST_RUN_VERSION_KEY @"lastVersion"

@interface MQLoginViewController()<LBBannerDelegate>
{
    LBBanner *topBanner;
    UIView *loginTypeview;
    TPResetSubFrameButton *bottomView;
    BOOL isWXLogin,isQQLogin,isWBLogin;
    UILabel *titleLabel;
    UILabel *titleDescLabel;
}
@end
@implementation MQLoginViewController

- (instancetype)init
{
    if(self = [super init])
    {
        isWXLogin = YES;
        isWBLogin = YES;
        isQQLogin = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self settitleLabel:@" "];
    self.navigationController.navigationBar.clipsToBounds=YES;
    if([self isShowUserGuideLoad])
        [self createTopBanner];
    else
        [self createBG];
    [self createLoginTypeView];
    [self createBottomView];
    
}

- (BOOL)isShowUserGuideLoad
{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];
    if (!lastRunVersion)
    {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;
    }
    else if (![lastRunVersion isEqualToString:currentVersion])
    {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;
    }
    
    return NO;
    
}

- (void)createBG
{
    UIImageView *imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 61, kMainScreenWidth, self.view.height-(150+28+(20+18+5+18)-10))];
    [self.view addSubview:imgBG];
    imgBG.contentMode = UIViewContentModeScaleAspectFill;
    imgBG.image = IMG(@"LaunchImage");
}

- (void)createTopBanner
{
    UIView *tbview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 20+18+5+18)];
    tbview.backgroundColor = kcolorWhite;
    [self.view addSubview:tbview];
    titleLabel = [self.view labelWithFrame:CGRectMake(0, 0, kMainScreenWidth, 18) text:@"视频速配" textFont:kFont18 textColor:kShortColor(0x44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    titleDescLabel = [self.view labelWithFrame:CGRectMake(0, titleLabel.bottom+5, kMainScreenWidth, 18) text:@"你永远不知道下一秒是谁" textFont:kFont15 textColor:kShortColor(0x88)];
    titleDescLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleDescLabel];
    tbview.frame = CGRectMake(0, 0, kMainScreenWidth, titleDescLabel.bottom+30);
    tbview.backgroundColor = kcolorWhite;
    
    NSArray * imageURLArray = @[@"lgoin_suijipipei",@"login_time",@"login_shouli",@"login_showhao"];
    topBanner = [[LBBanner alloc] initWithImageNames:imageURLArray andFrame:CGRectMake(0, titleDescLabel.bottom, [UIScreen mainScreen].bounds.size.width, self.view.height-(150+28+tbview.height-10))];
//    topBanner = [[LBBanner alloc] initWithImageURLArray:imageURLArray andFrame:CGRectMake(0, titleDescLabel.bottom+30, [UIScreen mainScreen].bounds.size.width, self.view.height-(150+28))];
    topBanner.delegate = self;
    topBanner.pageTurnTime = 2.0f;
    [self.view addSubview:topBanner];
    
}

- (void)banner:(LBBanner *)banner didChangeViewWithIndex:(NSInteger)index
{
    if(index == 0)
    {
        titleLabel.text = @"视频匹配";
        titleDescLabel.text = @"你永远不知道下一秒是谁";
    }
    else if(index == 1)
    {
        titleLabel.text = @"给你60秒";
        titleDescLabel.text = @"不喜欢就划掉";
    }
    else if(index == 2)
    {
        titleLabel.text = @"不拼颜值 不靠才艺";
        titleDescLabel.text = @"照样收礼到手软";
    }
    else if(index == 3)
    {
        titleLabel.text = @"开通VIP";
        titleDescLabel.text = @"彰显壕身份 尊享优先匹配特权";
    }
}

- (void)createLoginTypeView
{
//    loginTypeview  = [[UIView alloc] initWithFrame:CGRectMake(0, topBanner.bottom, kMainScreenWidth, 150)];
    loginTypeview  = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-(150+28+(20+18+5+18)-10)+61, kMainScreenWidth, 150)];
    loginTypeview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:loginTypeview];
    
    UILabel *tLabel = [self.view labelWithFrame:CGRectMake(0, 8, kMainScreenWidth, 28) text:@"选择登录方式" textFont:[UIFont systemFontOfSize:16] textColor:RGBCOLOR(153, 153, 153)];
    
    tLabel.textAlignment = NSTextAlignmentCenter;
    [loginTypeview addSubview:tLabel];
    
    CGFloat lineX = 30;
    if (kMainScreenWidth == 320) { // 适配5S屏幕
        lineX = 20;
    }
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(lineX, 23, kMainScreenWidth / 4, 1)];
    line1.backgroundColor = RGBCOLOR(224, 224, 224);
    [loginTypeview addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth - lineX - kMainScreenWidth / 4, 23, kMainScreenWidth / 4, 1)];
    line2.backgroundColor = RGBCOLOR(224, 224, 224);
    [loginTypeview addSubview:line2];
    
    
    CGFloat imgwidth = 52.0f;
    int loginCount = [self getLoginTypeCount];
    int space = (kMainScreenWidth-imgwidth*loginCount)/(loginCount+1);
    int lastx = 0;
    
    if(isWXLogin)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(lastx+space, tLabel.bottom+31, 52, 52)];
        button.layer.cornerRadius = imgwidth/2;
        button.layer.masksToBounds = YES;
        [button setImage:[self getImg:0] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginTypeBtItem:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = login_wx;
        [loginTypeview addSubview:button];
        lastx = button.right;
    }
    if(isWBLogin)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(lastx+space, tLabel.bottom+31, 52, 52)];
        button.layer.cornerRadius = imgwidth/2;
        button.layer.masksToBounds = YES;
        [button setImage:[self getImg:1] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginTypeBtItem:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = login_wb;
        [loginTypeview addSubview:button];
        lastx = button.right;
    }
    if(isQQLogin)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(lastx+space, tLabel.bottom+31, 52, 52)];
        button.layer.cornerRadius = imgwidth/2;
        button.layer.masksToBounds = YES;
        [button setImage:[self getImg:2] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginTypeBtItem:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = login_QQ;
        [loginTypeview addSubview:button];
        lastx = button.right;
    }

    UIButton *defaultButton = [[UIButton alloc] initWithFrame:CGRectMake(lastx+space, tLabel.bottom+31, 52, 52)];
    defaultButton.layer.cornerRadius = imgwidth/2;
    defaultButton.layer.masksToBounds = YES;
    [defaultButton setImage:[self getImg:3] forState:UIControlStateNormal];
    [defaultButton addTarget:self action:@selector(loginTypeBtItem:) forControlEvents:UIControlEventTouchUpInside];
    defaultButton.tag = login_default;
    [loginTypeview addSubview:defaultButton];
    
}


- (int)getLoginTypeCount
{
    int count = 4;
    if(![WXApi isWXAppInstalled])
    {
        isWXLogin = NO;
        count--;
    }
    if(![TencentOAuth iphoneQQInstalled])
    {
        isQQLogin = NO;
        count--;
    }
    if(YES)//if(![WeiboSDK isWeiboAppInstalled])
    {
        isWBLogin = NO;
        count--;
    }
    return count;
}

- (UIImage *)getImg:(int)aIndex
{
    UIImage *img = nil;
    if(aIndex == 0)
    {
        img = [UIImage imageNamed:@"login_weixin"];
    }
    else if(aIndex == 1)
    {
        img = [UIImage imageNamed:@"login_weibo"];
    }
    else if(aIndex == 2)
    {
        img = [UIImage imageNamed:@"login_QQ"];
    }
    else
    {
        img = [UIImage imageNamed:@"login_ipone"];
    }
    return img;
}



- (void)loginTypeBtItem:(UIButton *)aBt
{
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[UserInfoData shareUserInfoData] clearMemoryData];
    if(aBt.tag == login_default)
    {
//        UserInfoData *userData = nil;
//        [[SCach shareInstance]valueSynForKey:kStoreUserDataKey isMemory:NO filePath:nil className:@"UserInfoData" outObject:&userData];
//        if(userData)
//        {
//            [UserInfoData setUserData:userData];
//        }
        appDel.loginType = login_default;
        appDel.isIphoneLogin = YES;
//        if(userData && userData.strUserId && userData.strUserId.length > 0)
//        {
//#if DEBUG
//            self.closeWindowItemBlock(YES);
//#endif
//            [[YXManager sharedInstance] yxLogin:userData];
//        }
//        else
//        {
            IphoneLoginVC *vc = [[IphoneLoginVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
    else if(aBt.tag == login_wx)
    {
        [appDel showMakeToastCenter];
        appDel.loginType = login_wx;
        appDel.isIphoneLogin = NO;
        [self weixinLogin];
    }
    else if(aBt.tag == login_QQ)
    {
        [appDel showMakeToastCenter];
        appDel.loginType = login_QQ;
        appDel.isIphoneLogin = NO;
        [self QQLogin];
    }
    else if(aBt.tag == login_wb)
    {
        [appDel showMakeToastCenter];
        appDel.loginType = login_wb;
        appDel.isIphoneLogin = NO;
        [self weiboLogin];
    }
    else
    {
        if(self.closeWindowItemBlock)
        {
            self.closeWindowItemBlock(YES);
        }
    }
}

- (void)weixinLogin
{
    if([WXApi isWXAppInstalled])
    {
        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
//        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kWXAutoLoginOpenid];
//        if(dict)
//        {
//            [[WXLoginService shareWXLoginData] autoLoginWXRequest:dict loginResult:^(int errorCode) {
//                if(errorCode == 0)
//                {
//                   [del showRootviewController];
//                }
//                else{
//                   del.isLogin = YES;
//                   SendAuthReq *req = [[SendAuthReq alloc] init];
//                   req.scope = @"snsapi_userinfo";
//                   req.state = @"com.intalk.moqu";
//                   [WXApi sendReq:req];
//                }
//            }];
//        }
//        else
//        {
            del.isLogin = YES;
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = @"snsapi_userinfo";
            req.state = @"com.intalk.moqu";
            [WXApi sendReq:req];
//        }
    }
}

- (void)QQLogin
{
    if([TencentOAuth iphoneQQInstalled])
    {
        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kQQAutoLoginOpenid];
//        if(dict)
//        {
//            [[QQLoginService shareQQLoginService] autoLoginQQRequest:dict loginResult:^(int errorCode) {
//                if(errorCode == 0)
//                {
//                    [del showRootviewController];
//                }
//                else
//                {
//                    del.isLogin = YES;
//                    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
//                    [del.tOAuth authorize:permissions];
//                }
//            }];
//        }
//        else
//        {
            del.isLogin = YES;
            NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
            [del.tOAuth authorize:permissions];
//        }
    }
}

- (void)weiboLogin
{
    if([WeiboSDK isWeiboAppInstalled])
    {
        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
        del.isLogin = YES;
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kRedirectURI;
        request.scope = @"all";
        request.userInfo = @{@"SSO_From": @"MQLoginViewController",
                             @"Other_Info_1": [NSNumber numberWithInt:123],
                             @"Other_Info_2": @[@"obj1", @"obj2"],
                             @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        [WeiboSDK sendRequest:request];
    }
}
#pragma mark 构造底部view
- (void)createBottomView
{
    bottomView  = [[TPResetSubFrameButton alloc] initWithFrame:CGRectMake(0, loginTypeview.bottom-20, kMainScreenWidth, 28)];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    bottomView.titleLabel.font = [UIFont systemFontOfSize:10];
    [bottomView setTitleColor:[UIColor colorWithHexValue:0xbbbbbb] forState:UIControlStateNormal];
    
    [bottomView setImage:[UIImage imageNamed:@"login_bt_sel"] forState:UIControlStateNormal];
    [bottomView setTitle:@"同意咚咚协议与隐私条款" forState:UIControlStateNormal];
    [bottomView addTarget:self action:@selector(pushUserProtocalVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomView];
}

- (void)pushUserProtocalVC
{
    UserProtocalViewcontroller *upv = [[UserProtocalViewcontroller alloc] init];
    [self.navigationController pushViewController:upv animated:YES];
}

#pragma mark 关闭登陆的window
- (void)setCloseWindowItemBlock:(void (^)(BOOL))closeWindowItemBlock
{
    _closeWindowItemBlock = closeWindowItemBlock;
}
- (void)closeLoginWindow
{
    self.closeWindowItemBlock(YES);
    self.closeWindowItemBlock = nil;
}

@end
