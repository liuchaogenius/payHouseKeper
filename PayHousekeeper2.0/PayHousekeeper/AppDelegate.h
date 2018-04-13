//
//  AppDelegate.h
//  PayHousekeeper
//
//  Created by striveliu on 16/8/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "NewRootTabBar.h"

typedef enum {
    login_wx=1,
    login_wb,
    login_QQ,
    login_default,
    payOrderType_WX,
    payOrderType_alipay,
    bind_QQAccount,
    bind_WXAccount
}LoginType;

typedef void (^BecomeActive)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) UIWindow *rootwindow;
@property (nonatomic) LoginType loginType;
@property (nonatomic) BOOL isIphoneLogin;
@property (nonatomic, strong)TencentOAuth * tOAuth;
@property (nonatomic) BOOL isLogin;
@property (nonatomic, strong) NewRootTabBar *newtabr;
@property (nonatomic) LoginType currentLoginType;
@property (nonatomic, strong) UIImage *headUserImg;
@property (nonatomic, strong) UIImage *headBluryImg;
@property (copy)      BecomeActive becomeActiveBlock;
- (void)showLoginWindow;
- (void)showToastView:(NSString *)aMsg;
- (void)showToastView:(NSString *)aMsg duration:(NSTimeInterval)duration position:(id)position;
- (void)showRootviewController;
- (void)showAdditionaPersonInfovc;
- (void)showMakeToastCenter;
- (void)hiddenWindowToast;
@end

