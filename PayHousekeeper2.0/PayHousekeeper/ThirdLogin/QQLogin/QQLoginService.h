//
//  QQLoginService.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQLoginService : NSObject
@property (nonatomic, strong) NSString *strNickname;
@property (nonatomic, strong) NSString *strCity;
@property (nonatomic, strong) NSString *strProvince;
@property (nonatomic, strong) NSString *strSex;
@property (nonatomic, strong) NSString *strHeadUrl;
@property (nonatomic, strong) NSString *openId;
+ (QQLoginService *)shareQQLoginService;

- (void)requestLogin:(NSDictionary *)aUserInfoDict
             isLogin:(BOOL)aIsLogin
         loginResult:(void(^)(int result))aBlock;

- (void)autoLoginQQRequest:(NSDictionary *)aDict loginResult:(void(^)(int errorCode))aBlock;
@end
