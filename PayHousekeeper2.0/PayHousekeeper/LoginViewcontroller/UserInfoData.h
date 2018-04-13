//
//  UserInfoData.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/31.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kStoreUserDataKey @"default_userinfodata"
#define kStoreUserData_QQkey @"kStoreUserData_QQkey"
#define kStoreUserData_WBkey @"kStoreUserData_WBkey"
#define kStoreUserData_WXKey @"kStoreUserData_WXKey"
@interface UserInfoData : NSObject
/** 用户唯一表示，也是云信账号***/
@property (atomic, strong) NSString *strUserId;
/** 云信token***/
@property (atomic, readonly) NSString *strUserToken;
@property (atomic, readonly) NSString *strUserTempName;
@property (atomic, readonly) NSString *strHeadUrl;
@property (atomic, readonly) NSString *strUserMsg;
@property (atomic, readonly) NSString *strUserNick;
@property (atomic, readonly) NSString *strGender;
@property (atomic, readonly) NSString *strBirthday;
@property (atomic, readonly) int sexType; //0 M男 1 F女
@property (atomic, readonly) int isVip;
@property (atomic, readonly) int isLike; //是否喜欢
@property (atomic, readonly) int userLeval;
@property (atomic, readonly) long long shellCount; //咚果
@property (atomic, readonly) long long moneyCount; //咚币
@property (atomic, readonly) NSString *secretKey;
@property (atomic, readonly) NSString *vipLosetime; //vip到期时间
@property (atomic, readonly) NSString *strUserCode;
@property (atomic, readonly) NSString *strConstellation;//星座
@property (atomic, readonly) NSString *strAge;
@property (atomic, readonly) NSString *strInviteCode;
@property (atomic, readonly) NSString *strSex;
@property (atomic, readonly) NSString *strUserSign;//用户签名
@property (atomic, readonly) NSString *strPlace;//地点
@property (atomic, readonly) int wealthlevel;//财富等级
@property (atomic, readonly) int charmlevel; //魅力等级
@property (atomic, readonly) int activeLevel; //活跃等级
@property (atomic, readonly) int activeval;//活跃值
@property (atomic, readonly) int wealthval; //财富值
@property (atomic, readonly) int charmval;//魅力值

+ (UserInfoData *)shareUserInfoData;
+ (void)setUserData:(UserInfoData *)aData;
- (void)unPackeRegisterDict:(NSDictionary *)aDict;
- (void)unPakceComInfoDict:(NSDictionary *)aDict;
//- (void)unPakceUserInfoDict:(NSDictionary *)aDict;
- (void)setCurrentShellCount:(long long)aShellCount;
- (void)setCurrentMoneyCount:(long long)aMoneyCount;
- (void)setUserMsg:(NSString *)aUserMsg;
- (void)setUserSign:(NSString *)aUserSig;
- (void)setUserVip:(int)aIsVip;
- (void)setUserLeval:(int)leval;
+ (BOOL)getUserDataFromFile;
- (void)clearMemoryData;
@end
