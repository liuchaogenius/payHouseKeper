//
//  QQLoginService.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "QQLoginService.h"
#import "DDLoginManager.h"
#import "AppDelegate.h"

@interface QQLoginService()

@end

@implementation QQLoginService
+ (QQLoginService *)shareQQLoginService
{
    static QQLoginService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[QQLoginService alloc] init];
    });
    return service;
}

- (void)autoLoginQQRequest:(NSDictionary *)aDict loginResult:(void(^)(int errorCode))aBlock
{
    [self requestLogin:aDict isLogin:YES loginResult:aBlock];
}

- (void)requestLogin:(NSDictionary *)aUserInfoDict
             isLogin:(BOOL)aIsLogin
         loginResult:(void(^)(int result))aBlock
{
    AssignMentID(self.strNickname, [aUserInfoDict objectForKey:@"nickname"]);
    AssignMentID(self.strCity, [aUserInfoDict objectForKey:@"city"]);
    AssignMentID(self.strProvince, [aUserInfoDict objectForKey:@"province"]);
    NSString *tempSex = nil;
    AssignMentID(tempSex, [aUserInfoDict objectForKey:@"gender"]);
    if([tempSex compare:@"男"] == 0)
    {
        self.strSex = @"M";
    }
    else
    {
        self.strSex = @"F";
    }
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.openId = del.tOAuth.openId;
    AssignMentID(self.strHeadUrl, [aUserInfoDict objectForKey:@"figureurl_qq_2"]);
    
    if(aIsLogin)
    {
        [[DDLoginManager shareLoginManager] requestThirdLogin:del.tOAuth.openId loginType:@"0" hearUrl:self.strHeadUrl nick:self.strNickname gender:self.strSex birthday:nil loginResult:^(int result) {
            aBlock(result);
        }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kQQLoginSuccessNotifyName object:nil];
        aBlock(0);
    }
    if(aUserInfoDict)
    {
        NSMutableDictionary *qqdict = [NSMutableDictionary dictionaryWithDictionary:aUserInfoDict];
        [qqdict setObject:del.tOAuth.openId forKey:kQQAutoLoginOpenid];
        [[NSUserDefaults standardUserDefaults] setObject:qqdict forKey:kQQAutoLoginOpenid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
