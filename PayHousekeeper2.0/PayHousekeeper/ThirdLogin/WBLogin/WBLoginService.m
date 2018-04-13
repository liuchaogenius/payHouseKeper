//
//  WBLoginService.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/4.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "WBLoginService.h"
#import "AppDelegate.h"

@interface WBLoginService ()
@property (nonatomic,copy)void(^loginRequest)(int ret);
@end

@implementation WBLoginService

+ (WBLoginService *)shareWBLoginService
{
    static WBLoginService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[WBLoginService alloc] init];
    });
    return service;
}

- (void)requestLogin:(WBBaseResponse*)response complete:(void(^)(int ret))aBlock
{
    self.loginRequest = aBlock;
    NSDictionary* userInfo = response.userInfo;
    
    NSString* token = [userInfo objectForKey:@"access_token"];
    
    NSString* uid = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"uid"]];
    
    //授权成功后通过收到的token和uid获取用户信息
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:token forKey:@"access_token"];
    
    [params setObject:uid forKey:@"uid"];
    
    MLOG(@"params:%@", params);
    
//    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *requrl = @"https://api.weibo.com/2/users/show.json";
//    NSString *requrl = @"https://api.weibo.com/2/users/show.json";
    [WBHttpRequest requestWithURL:requrl httpMethod:@"GET"params:params delegate:self withTag:@"getUserInfo"];
}

//获取用户信息方法

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result

{
    
    NSError *error;
    
    NSData  *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (json ==nil)
        
    {
        
        MLOG(@"json parse failed \r\n");
        
        return;
        
    }
    
    MLOG(@"json = %@",json);
    
    
    
    //获取用户头像和昵称
    
    NSString *screenname = [json objectForKey:@"screen_name"];
    
    NSString *picture    = [json objectForKey:@"profile_image_url"];
    
    
    
    
    
    MLOG(@"usrName = %@",screenname);
    
    MLOG(@"picture = %@",picture);
    
#warning 继续后续请求我们自己的接口 即可
    
}
@end
