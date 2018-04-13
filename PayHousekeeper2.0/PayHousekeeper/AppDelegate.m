//
//  AppDelegate.m
//  PayHousekeeper
//
//  Created by striveliu on 16/8/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginWindow.h"
#import "NewRootViewController.h"
#import <Toast/UIView+Toast.h>
#import "IQKeyboardManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "WXLoginService.h"
#import "WBLoginService.h"
#import "QQLoginService.h"
#import "WXPayService.h"
#import "ZFBPayService.h"
#import <AlipaySDK/AlipaySDK.h>
#import "NTESVideoChatViewController.h"
#import <Bugly/Bugly.h>
#import "HDeviceIdentifier.h"

@interface AppDelegate ()<WXApiDelegate, TencentSessionDelegate,WeiboSDKDelegate>
{
//    LoginWindow *loginw;
    UINavigationController *rootnav;
    BOOL isHandUrl;
}
@property (nonatomic,strong) NewRootViewController *rootvc;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:kWEIXINLoginAppid];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyWindow];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = kcolorWhite;
    self.newtabr = [[NewRootTabBar alloc] init];

    self.tOAuth = [[TencentOAuth alloc] initWithAppId:kQQLoginAPPID andDelegate:self];
//    [WeiboSDK registerApp:kWEIBOAppKey];
    [self hookCrash];
    if([UserInfoData getUserDataFromFile])
    {
        [[YXManager sharedInstance] yxAutoLogin];
        [self showRootviewController];
    }
    else
    {
        [self showLoginWindow];
    }
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    //初始化友盟
    [self initUMeng];
    
    [self registerAPNs];
    
    [self reportStart];
    
//    [[DDSystemInfoManager sharedInstance] getMacthTimeInfo];
    [[DDSystemInfoManager sharedInstance] getSwitchInfo];
    [[DDSystemInfoManager sharedInstance] setShowTipValue:NO key:Tip4Gradient];
    [[DDSystemInfoManager sharedInstance] setShowTipValue:NO key:Tip4Report];
    
    [Bugly startWithAppId:@"a937c2de52"];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    return YES;
}

- (void)reportStart
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:@"start" forKey:@"act"];
    [dict setObject:[HDeviceIdentifier deviceIdentifier] forKey:@"deviceid"];
    [dict setObject:kSofterViewsion forKey:@"ver"];
    [dict setObject:@"iOS" forKey:@"os"];
    
    [NetManager requestWith:dict apiName:kRepertAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)initUMeng
{
    if(IOS_RELEASE)
    {
//        [MobClick setLogEnabled:YES];
        UMConfigInstance.appKey = UMAppKey;
        UMConfigInstance.channelId = @"";
        UMConfigInstance.ePolicy = BATCH;
//        UMConfigInstance.eSType = E_UM_GAME; //仅适用于游戏场景，应用统计不用设置
        [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [MobClick setAppVersion:version];
    }
}

- (void)hookCrash
{
    [NSDictionary NSDictoryCrashHook];
    [NSMutableDictionary NSMutableDictoryCrashHook];
    [NSArray NSArrayCrashHook];
}

- (void)registerAPNs
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
//    else
//    {
//        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
//    }
}

- (void)showLoginWindow
{
    [[DDSystemInfoManager sharedInstance] cancelDownloadPic];
    
    LoginWindow *loginw = [LoginWindow showLoginview];
//    [loginw makeKeyAndVisible];
    [loginw showtopVc];
//    loginw.hidden = NO;
    self.window.rootViewController = [loginw loginRootNav];
//    self.rootwindow.hidden = YES;
//    WeakSelf(self);
//    [loginw setCloseWindowItemBlock:^(BOOL isClose) {
//       //登陆关闭的回调
//        [weakself showRootviewController];
//    }];
}

- (void)showAdditionaPersonInfovc
{
    LoginWindow *loginw = [LoginWindow showLoginview];
    [self.window hideToastActivity];
    [loginw showAdditionaPersonInfovc];
}

- (void)showRootviewController
{
    [self.window hideToastActivity];

    [self.window hideToastActivity];
    
    if(!self.newtabr)
    {
        self.newtabr = [[NewRootTabBar alloc] init];
        
        self.newtabr.view.frame = self.window.bounds;
        self.window.rootViewController = self.newtabr;
        
    }
    self.window.rootViewController = self.newtabr;
    [self.newtabr setSelectTabBarViewController:0];
    [self.newtabr refreshNewRootUserHead];
    self.window.backgroundColor = kcolorWhite;
    [self.window makeKeyAndVisible];
    
/*    if(!rootnav)
    {
//        self.rootwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Override point for customization after application launch.
//        self.rootwindow.backgroundColor = [UIColor whiteColor];
        self.rootvc = [[NewRootViewController alloc] init];
        rootnav = [[UINavigationController alloc] initWithRootViewController:self.rootvc];
        self.rootvc.view.frame = self.window.bounds;
        self.window.rootViewController = rootnav;

    }
    self.window.rootViewController = rootnav;
    [rootnav popToRootViewControllerAnimated:NO];
    [self.rootvc refreshHeadView];
//    self.rootwindow.hidden = NO;
//    [self.rootwindow makeKeyAndVisible];
//    [self.rootwindow makeKeyWindow];
//    self.window = _rootwindow;
    self.window.backgroundColor = kcolorWhite;
    [self.window makeKeyAndVisible];
//    loginw.hidden = YES;*/
}

- (void)showToastView:(NSString *)aMsg
{
    [self.window hideToastActivity];
    [self.window makeToast:aMsg duration:0.5 position:CSToastPositionCenter];
}

- (void)showToastView:(NSString *)aMsg duration:(NSTimeInterval)duration position:(id)position
{
    [self.window hideToastActivity];
    [self.window makeToast:aMsg duration:duration position:position];
}

- (void)hiddenWindowToast
{
    [self.window hideToastActivity];
}
- (void)showMakeToastCenter
{
    [self.window hideToastActivity];
    [self.window makeCenterToastActivity];
}

- (void)setLoginType:(LoginType)loginType
{
    _loginType = loginType;
    if(_loginType == login_default || _loginType == login_QQ || loginType == login_wx || loginType == login_wb)
    {
        _currentLoginType = _loginType;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",_currentLoginType] forKey:kDDLoginType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
#pragma mark 微博登录回调
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    MLOG(@"%@",request);
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    MLOG(@"%@",response);
    WBLoginService *service = [WBLoginService shareWBLoginService];
    [service requestLogin:response complete:^(int ret) {
        MLOG(@"%d",ret);
    }];
}
#pragma mark QQ登录回调
- (void)tencentDidLogin
{
    MLOG(@"qqacctoken = %@", self.tOAuth.accessToken);
    [self.tOAuth getUserInfo];
//    [[QQLoginService shareQQLoginService] requestLogin:<#(APIResponse *)#>]
}
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [self.window hideToastActivity];
}
- (void)tencentDidNotNetWork
{
    [self.window hideToastActivity];
}
- (void)getUserInfoResponse:(APIResponse *)response {
    
    if (response && response.retCode == URLREQUEST_SUCCEED) {
        
        NSDictionary *userInfo = [response jsonResponse];
        [[QQLoginService shareQQLoginService] requestLogin:userInfo isLogin:self.isLogin loginResult:^(int result) {
            if(result == 0 && self.loginType != bind_QQAccount)
            {
                [[YXManager sharedInstance] yxLogin:[UserInfoData shareUserInfoData]];
//                [self showRootviewController];
            }
            else if(self.loginType == bind_QQAccount)
            {
            }
            else if(result != 0)
            {
                [self.window makeToast:@"登录失败，请检测网络"];
            }
        }];
    } else {
        MLOG(@"QQ auth fail ,getUserInfoResponse:%d", response.detailRetCode);
    }
}
#pragma mark 微信操作的回调
- (void)onResp:(BaseResp *)resp
{
    NSString *payResoult = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if([resp isKindOfClass:[PayResp class]]){
        
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case 0:
            {
//                payResoult = @"支付成功";
                [[WXPayService shareWXPayService] requestWXPayVerify:^(NSString *tradeState, NSString *out_trade_no, int ret) {
//                    [self.window makeToast:payResoult duration:1.f position:CSToastPositionCenter];
                }];
            }
                break;
            case -1:
            {
                payResoult = @"支付失败";
                [[WXPayService shareWXPayService] requestWXPayVerify:^(NSString *tradeState, NSString *out_trade_no, int ret) {
                    [self.window makeToast:payResoult duration:1.f position:CSToastPositionCenter];
                }];
            }
                break;
            case -2:
            {
                payResoult = @"用户已经退出支付";
                [[WXPayService shareWXPayService] requestWXPayVerify:^(NSString *tradeState, NSString *out_trade_no, int ret) {
                    [self.window makeToast:payResoult duration:1.f position:CSToastPositionCenter];
                }];
            }
                break;
            default:
            {
//                payResoult = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                payResoult = @"支付失败";
                [[WXPayService shareWXPayService] requestWXPayVerify:^(NSString *tradeState, NSString *out_trade_no, int ret) {
                    [self.window makeToast:payResoult duration:1.f position:CSToastPositionCenter];
                }];
            }
                break;
        }
    }
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        MLOG(@"weixintoken = %@",temp.code);
        if(temp.code)
        {
//            [self.window makeToast:@"登陆中..."];
            [[WXLoginService shareWXLoginData] requestWXLoginInfo:temp.code isLogin:self.isLogin loginResult:^(int errorCode) {
                [self.window hideToastActivity];
                if(errorCode == 0 && self.loginType != bind_WXAccount)
                {
                    [[YXManager sharedInstance] yxLogin:[UserInfoData shareUserInfoData]];
//                    [self showRootviewController];
                }
                else if(self.loginType == bind_WXAccount)
                {
                }
                else if(errorCode != 0)
                {
                    [self.window makeToast:@"登录失败，请检测网络"];
                }
            }];
        }
        else
        {
            if(temp.errCode == -2)//用户取消
            {
                [self.window hideToastActivity];
            }
            else if(temp.errCode == -4) //用户拒绝
            {
                [self.window hideToastActivity];
            }
        }
    }
}

#pragma mark application  Delegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    isHandUrl = YES;
    if(self.loginType == login_wx || self.loginType == payOrderType_WX || self.loginType == bind_WXAccount)
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if(self.loginType == login_wb)
    {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if(self.loginType == login_QQ || self.loginType == bind_QQAccount)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if(self.loginType == payOrderType_alipay)
    {
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic){
                MLOG(@"result = %@",resultDic);
                NSString *strReuslt = [resultDic objectForKey:@"result"];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[strReuslt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *alipayRespDict = [dict objectForKey:@"alipay_trade_app_pay_response"];
                NSString *strTradeNo = [alipayRespDict objectForKey:@"out_trade_no"];
                [[ZFBPayService shareZFBPayService] requestAlipayVerifyTradeNum:strTradeNo];
            }];
        }
    }
    return YES;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    if(self.loginType == login_wx || self.loginType == payOrderType_WX)
//    {
//        return [WXApi handleOpenURL:url delegate:self];
//    }
//    else if(self.loginType == login_wb)
//    {
//        return [WeiboSDK handleOpenURL:url delegate:self];
//    }
//    else if(self.loginType == login_QQ)
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
//    else if(self.loginType == payOrderType_alipay)
//    {
//        if ([url.host isEqualToString:@"safepay"])
//        {
//            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic){
//                MLOG(@"result = %@",resultDic);
//                NSString *strReuslt = [resultDic objectForKey:@"result"];
//                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[strReuslt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//                NSDictionary *alipayRespDict = [dict objectForKey:@"alipay_trade_app_pay_response"];
//                NSString *strTradeNo = [alipayRespDict objectForKey:@"trade_no"];
//                [[ZFBPayService shareZFBPayService] requestAlipayVerifyTradeNum:strTradeNo];
//            }];
//        }
//    }
//    return YES;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    [[GPUImageManager sharedInstance] stop];
    
//    runSynchronouslyOnVideoProcessingQueue(^{
//        
//        glFinish();
//        
//    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSInteger count = [[YXManager sharedInstance] getAllUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    [[YXManager sharedInstance] disableCammera:YES];
    [[GPUImageManager sharedInstance] stop];

    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UINavigationController *nav = [_newtabr getCurrentNavController];
//    NSArray *arry = nav.viewControllers;
//    if(arry && arry.count > 0)
//    {
//        bool isNETSVideo = NO;
//        for(UIViewController *vc in arry)
//        {
//            if([vc isKindOfClass:[NTESVideoChatViewController class]])
//            {
//                isNETSVideo = YES;
//            }
//        }
//        if(!isNETSVideo)
//        {
//            //        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
//            //        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//            [GPUImageManager sharedInstance].flag = YES;
//            [[GPUImageManager sharedInstance] start:YES];
//            //        });
//        }
//    }
    if([nav.topViewController isKindOfClass:[NewRootViewController class]])
    {
        [GPUImageManager sharedInstance].flag = YES;
        [[GPUImageManager sharedInstance] start:YES];
    }

//
    if(isHandUrl == NO)
    {
        [self.window hideToastActivity];
    }
    isHandUrl = NO;
    
    [[YXManager sharedInstance] disableCammera:NO];

    if(_becomeActiveBlock)
    {
        _becomeActiveBlock();
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[YXManager sharedInstance] updateApnsToken:deviceToken];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:  %@", deviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"receive remote notification:  %@", userInfo);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"fail to get apns token :%@",error);
}

@end
