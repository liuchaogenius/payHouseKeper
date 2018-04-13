//
//  OtherUserInfoData.h
//  PayHousekeeper
//
//  Created by 1 on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUserInfoData : NSObject
/** 用户唯一表示，也是云信账号***/
@property (nonatomic, strong) NSString *strUserId;

@property (nonatomic, readonly) NSString *strHeadUrl;
@property (nonatomic, readonly) NSString *strUserMsg; //mood
@property (nonatomic, readonly) NSString *strUserNick;
@property (nonatomic, readonly) NSString *strGender;
@property (nonatomic, readonly) NSString *strBirthday;
@property (nonatomic, readonly) int sexType; //0 M男 1 F女
@property (nonatomic, readonly) int isVip;
@property (nonatomic, readonly) int isLike; //是否喜欢
@property (nonatomic, readonly) int userLeval;
//@property (nonatomic, readonly) long long shellCount; //咚果
//@property (nonatomic, readonly) long long moneyCount; //咚币
@property (nonatomic, readonly) NSString *strUserCode;
@property (nonatomic, readonly) NSString *strConstellation;//星座
@property (nonatomic, readonly) NSString *strAge;
@property (nonatomic, readonly) NSString *strInviteCode;
@property (nonatomic, readonly) NSString *strSex;
@property (nonatomic, readonly) NSString *strUserSign;//用户签名
@property (nonatomic, readonly) int wealthlevel;//财富等级
@property (nonatomic, readonly) int charmlevel; //魅力等级
@property (nonatomic, readonly) int activeval;//活跃值
@property (nonatomic, readonly) int wealthval; //财富值
@property (nonatomic, readonly) int charmval;//魅力值

- (void)unPakceUserInfoDict:(NSDictionary *)aDict;
- (void)unPakceUserInfo:(UserInfoData *)user;
@end
