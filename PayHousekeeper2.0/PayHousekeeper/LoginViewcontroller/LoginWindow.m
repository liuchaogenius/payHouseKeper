//
//  LoginWindow.m
//  YHB_Prj
//
//  Created by  striveliu on 16/1/21.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "LoginWindow.h"
#import "MQLoginViewController.h"
#import "AdditionalPersonInfoVC.h"

@interface LoginWindow()
{
    UINavigationController *loginRootNVC;
    MQLoginViewController *loginVC;
}
@end

@implementation LoginWindow

+ (LoginWindow *)showLoginview
{
    static LoginWindow *logw = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logw = [[LoginWindow alloc] init];//WithFrame:CGRectMake(0, kMainScreenHeight, kMainScreenWidth, kMainScreenHeight)];
//        [logw makeKeyAndVisible];
//        logw.backgroundColor = [UIColor whiteColor];
//        logw.windowLevel = UIWindowLevelAlert;
//        [UIView animateWithDuration:0.2 animations:^{
//            logw.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
//        }];
    });

    return logw;
}

- (UINavigationController *)loginRootNav
{
    if(loginRootNVC)
    {
        return loginRootNVC;
    }
    return nil;
}

- (id)init//WithFrame:(CGRect)frame
{
    if(self = [super init])//]WithFrame:frame])
    {
        loginVC = [[MQLoginViewController alloc] init];
        loginRootNVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        self.rootViewController = loginRootNVC;
//        loginRootNVC.
        [loginRootNVC.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        loginVC.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        __weak LoginWindow *weakself = self;
        [loginVC setCloseWindowItemBlock:^(BOOL result) {
            [UIView animateWithDuration:0.2 animations:^{
//                weakself.frame = CGRectMake(0, kMainScreenHeight, kMainScreenWidth, kMainScreenHeight);
                if(weakself.closeWindowItemBlock)
                {
                    weakself.closeWindowItemBlock(result);
                    weakself.closeWindowItemBlock = nil;
                }
            }];
        }];
    }
    return self;
}

- (void)showtopVc
{
    [loginRootNVC popToRootViewControllerAnimated:NO];
}


- (void)showAdditionaPersonInfovc
{
    AdditionalPersonInfoVC *vc = [[AdditionalPersonInfoVC alloc] init];
    [loginVC.navigationController pushViewController:vc animated:YES];
}

- (void)setCloseWindowItemBlock:(void (^)(BOOL))closeWindowItemBlock
{
    _closeWindowItemBlock = closeWindowItemBlock;
}
@end
