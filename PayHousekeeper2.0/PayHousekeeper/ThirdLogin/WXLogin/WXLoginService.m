//
//  WXLoginData.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/4.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "WXLoginService.h"
#import "AFNetworking.h"
#import "DDLoginManager.h"

@implementation WXLoginService
+ (WXLoginService *)shareWXLoginData
{
    static WXLoginService *wxlData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wxlData = [[WXLoginService alloc] init];
    });
    return wxlData;
}

- (void)requestWXLoginInfo:(NSString *)aCode isLogin:(BOOL)aIslogin
               loginResult:(void(^)(int errorCode))aBlock
{
    self.loginReuslt = aBlock;
    _isLogin = aIslogin;
    NSString *accessUrlStr = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kWXBaseUrl, kWEIXINLoginAppid, kWEXINAppSecret, aCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *dataStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:accessUrlStr] encoding:NSUTF8StringEncoding error:&error];
        if(!error)
        {
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *accessDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                MLOG(@"%@",accessDict);
                
                NSString *accessToken = [accessDict objectForKey:WX_ACCESS_TOKEN];
                NSString *openID = [accessDict objectForKey:WX_OPEN_ID];
                NSString *refreshToken = [accessDict objectForKey:WX_REFRESH_TOKEN];
                // 本地持久化，以便access_token的使用、刷新或者持续
                if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
                    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:WX_ACCESS_TOKEN];
                    [[NSUserDefaults standardUserDefaults] setObject:openID forKey:WX_OPEN_ID];
                    [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:WX_REFRESH_TOKEN];
                    [[NSUserDefaults standardUserDefaults] synchronize]; // 命令直接同步到文件里，来避免数据的丢失
                    [self wechatLoginByRequestForUserInfo];
                }
                else
                {
                    aBlock(-1);
                }
            });
        }
        else
        {
            aBlock(-1);
        }
    });
}
+ (NSString *)getWXUserOpenId
{
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return openID;
    
}
- (void)wechatLoginByRequestForUserInfo {
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    NSString *userUrlStr = [NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@", kWXBaseUrl, accessToken, openID];
    WeakSelf(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSString *dataStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:userUrlStr] encoding:NSUTF8StringEncoding error:&error];
        if(!error)
        {
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *accessDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                MLOG(@"%@",accessDict);
                
                if(accessDict)
                {
                    [weakself unPackeWXUserInfo:accessDict];
                }
                else
                {
                    weakself.loginReuslt(-1);
                }
            });
        }
        else
        {
            weakself.loginReuslt(-1);
        }
    });
}

- (void)autoLoginWXRequest:(NSDictionary *)aDict loginResult:(void(^)(int errorCode))aBlock
{
    self.loginReuslt = aBlock;
    _isLogin = YES;
    [self unPackeWXUserInfo:aDict];
}

- (void)unPackeWXUserInfo:(NSDictionary *)aDict
{
    AssignMentID(self.openid, [aDict objectForKey:@"openid"]);
    AssignMentID(self.nickName, [aDict objectForKey:@"nickname"]);
    int isex = [[aDict objectForKey:@"sex"] intValue];
    if(isex == 1)
    {
        self.sex = @"M";
    }
    else
    {
        self.sex = @"F";
    }
    AssignMentID(self.province, [aDict objectForKey:@"province"]);
    AssignMentID(self.city, [aDict objectForKey:@"city"]);
    AssignMentID(self.country, [aDict objectForKey:@"country"]);
    AssignMentID(self.headUrl, [aDict objectForKey:@"headimgurl"]);
    AssignMentID(self.unionid, [aDict objectForKey:@"unionid"]);
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    WeakSelf(self);
    if(self.isLogin)
    {
        [[DDLoginManager shareLoginManager] requestThirdLogin:openID loginType:@"1" hearUrl:self.headUrl nick:self.nickName gender:self.sex birthday:nil loginResult:^(int result) {
            weakself.loginReuslt(result);
        }];
    }
    else
    {
        self.loginReuslt(0);
        [[NSNotificationCenter defaultCenter] postNotificationName:kWXLoginSuccessNotifyName object:nil];
    }
    if(aDict)
    {
        [[NSUserDefaults standardUserDefaults] setObject:aDict forKey:kWXAutoLoginOpenid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


//返回的Json结果
//{
//    "openid":"OPENID",
//    "nickname":"NICKNAME",
//    "sex":1,
//    "province":"PROVINCE",
//    "city":"CITY",
//    "country":"COUNTRY",
//    "headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
//    "privilege":[
//                 "PRIVILEGE1",
//                 "PRIVILEGE2"
//                 ],
//    "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
//}
//返回错误的Json事例
//{
//    "errcode":40003,"errmsg":"invalid openid"
//}
@end
