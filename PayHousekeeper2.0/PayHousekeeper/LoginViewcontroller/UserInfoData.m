//
//  UserInfoData.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/31.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "UserInfoData.h"
#import "SCach.h"
#import "AppDelegate.h"

static UserInfoData *userdata = nil;
@interface UserInfoData()

@end

@implementation UserInfoData

+ (UserInfoData *)shareUserInfoData
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!userdata)
        {
            userdata = [[UserInfoData alloc] init];
        }
    });
    return userdata;
}

+ (void)setUserData:(UserInfoData *)aData
{
    userdata = aData;
}
- (void)unPackeRegisterDict:(NSDictionary *)aDict
{
    if([aDict objectForKey:@"accid"])
    {
        AssignMentID(_strUserId, [aDict objectForKey:@"accid"]);
    }
    if([aDict objectForKey:@"name"])
    {
        AssignMentID(_strUserTempName, [aDict objectForKey:@"name"]);
    }
    if([aDict objectForKey:@"token"])
    {
        AssignMentID(_strUserToken, [aDict objectForKey:@"token"]);
    }
    if([aDict objectForKey:@"inviteCode"])
    {
        AssignMentID(_strInviteCode, [aDict objectForKey:@"inviteCode"]);
        _strUserCode = _strInviteCode;
    }
//    if(_strGender && [_strGender compare:@"M"] == 0)
//    {
//        _sexType = 0;
//    }
//    else
//    {
//        _sexType = 1;
//    }
//    AssignMentID(_strBirthday, [aDict objectForKey:@"birthday"]);
//    AssignMentID(_strHeadUrl, [aDict objectForKey:@"avatar"]);
//    AssignMentID(_strUserMsg, [aDict objectForKey:@"mood"]);
//    _strConstellation = [aDict objectForKey:@"constellation"];
//    _strAge = [aDict objectForKey:@"age"];
    [self saveUserDataToFile];
}

- (void)unPakceComInfoDict:(NSDictionary *)aDict
{
    [self unPakceUserInfoDict:aDict];
    [self saveUserDataToFile];
}

- (void)unPakceUserInfoDict:(NSDictionary *)aDict
{
    if(aDict && !isNull(aDict))
    {
        NSString *tempStr = [aDict objectForKey:@"accid"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strUserId, [aDict objectForKey:@"accid"]);
        }
        tempStr = [aDict objectForKey:@"token"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strUserToken, [aDict objectForKey:@"token"]);
        }
        tempStr = [aDict objectForKey:@"nickName"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strUserNick, [aDict objectForKey:@"nickName"]);
        }
        tempStr = [aDict objectForKey:@"gender"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strGender, [aDict objectForKey:@"gender"]);
        }
        if(_strGender && [_strGender compare:@"M"] == 0)
        {
            _sexType = 0;
            _strSex = @"男";
        }
        else
        {
            _sexType = 1;
            _strSex = @"女";
        }
        tempStr = [aDict objectForKey:@"birthday"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strBirthday, [aDict objectForKey:@"birthday"]);
        }
        tempStr = [aDict objectForKey:@"avatar"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strHeadUrl, [aDict objectForKey:@"avatar"]);
        }
        tempStr = [aDict objectForKey:@"mood"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_strUserMsg, [aDict objectForKey:@"mood"]);
        }
        if([aDict objectForKey:@"level"])
        {
            NSLog(@"第一次赋值等级=== %@", [aDict objectForKey:@"level"]);
            AssignMentNSNumber(_userLeval, [aDict objectForKey:@"level"]);
        }
        if([aDict objectForKey:@"shellCount"])
        {
            _shellCount = [[aDict objectForKey:@"shellCount"] longLongValue];
        }
        if([aDict objectForKey:@"moneyCount"])
        {
            _moneyCount = [[aDict objectForKey:@"moneyCount"] longLongValue];
        }
        
        tempStr = [aDict objectForKey:@"secretKey"];
        if(tempStr && tempStr.length > 0)
        {
            AssignMentID(_secretKey, [aDict objectForKey:@"secretKey"]);
        }
        tempStr = [aDict objectForKey:@"vip"];
        if(tempStr)
        {
            BOOL tmpVip = [[aDict objectForKey:@"vip"] boolValue];
            _isVip = tmpVip?1:0;
        }
        
        tempStr = [aDict objectForKey:@"vip_losetime"];
        if(tempStr && tempStr.length > 0)
        {
            _vipLosetime = [aDict objectForKey:@"vip_losetime"];
        }
        
        tempStr = [aDict objectForKey:@"userCode"];
        if(tempStr && tempStr.length > 0)
        {
            _strUserCode = [aDict objectForKey:@"userCode"];
        }
        
        tempStr = [aDict objectForKey:@"constellation"];
        if(tempStr && tempStr.length > 0)
        {
            _strConstellation = [aDict objectForKey:@"constellation"];
        }
        tempStr = [aDict objectForKey:@"age"];
        if(tempStr)
        {
            _strAge = [NSString stringWithFormat:@"%d",[[aDict objectForKey:@"age"] intValue]];
        }
        tempStr = [aDict objectForKey:@"userSign"];
        if(tempStr && tempStr.length > 0)
        {
            _strUserSign = [aDict objectForKey:@"userSign"];
        }
        if([aDict objectForKey:@"wealthLevel"])
        {
            _wealthlevel = [[aDict objectForKey:@"wealthLevel"] intValue];
        }
        if([aDict objectForKey:@"charmLevel"]){
            _charmlevel = [[aDict objectForKey:@"charmLevel"] intValue];
        }
        if([aDict objectForKey:@"activeLevel"]){
            _activeLevel = [[aDict objectForKey:@"activeLevel"] intValue];
        }
        if([aDict objectForKey:@"activeVal"]){
            _activeval = [[aDict objectForKey:@"activeVal"] intValue];
        }
        if([aDict objectForKey:@"wealthVal"]){
            _wealthval = [[aDict objectForKey:@"wealthVal"] intValue];
        }
        if([aDict objectForKey:@"charmVal"]){
            _charmval = [[aDict objectForKey:@"charmVal"] intValue];
        }
        
        tempStr = [aDict objectForKey:@"place"];
        if(tempStr && tempStr.length > 0)
        {
            _strPlace = [aDict objectForKey:@"place"];
        }
    }
}

- (void)setStrHeadUrl:(NSString *)strHeadUrl
{
    _strHeadUrl = strHeadUrl;
    MLOG(@"用户头像url=%@",_strHeadUrl);
    [self saveUserDataToFile];
}

- (void)setCurrentShellCount:(long long)aShellCount
{
    _shellCount = aShellCount;
    [self saveUserDataToFile];
}
- (void)setCurrentMoneyCount:(long long)aMoneyCount
{
    _moneyCount = aMoneyCount;
    [self saveUserDataToFile];
}
- (void)setUserMsg:(NSString *)aUserMsg
{
//    if(aUserMsg && aUserMsg.length > 0)
    {
        _strUserMsg = aUserMsg?aUserMsg:@" ";
        [self saveUserDataToFile];
    }
}
- (void)setUserSign:(NSString *)aUserSig
{
//    if(aUserSig && aUserSig.length > 0)
    {
        _strUserSign = aUserSig?aUserSig:@" ";
        [self saveUserDataToFile];
    }
}

- (void)setUserVip:(int)aIsVip
{
    _isVip = aIsVip;
    [self saveUserDataToFile];
}

- (void)setUserLeval:(int)leval
{
    _userLeval = leval;
    [self saveUserDataToFile];
}

- (void)saveUserDataToFile
{
    if(DLAPPDELEGATE.currentLoginType == login_default)
    {
        [[SCach shareInstance] setAsynValue:self key:kStoreUserDataKey isMemeory:NO filePath:nil block:^(bool isResult) {
            
        }];
    }
    else if(DLAPPDELEGATE.currentLoginType == login_wx)
    {
        [[SCach shareInstance] setAsynValue:self key:kStoreUserData_WXKey isMemeory:NO filePath:nil block:^(bool isResult) {
            
        }];
    }
    else if(DLAPPDELEGATE.currentLoginType == login_QQ)
    {
        [[SCach shareInstance] setAsynValue:self key:kStoreUserData_QQkey isMemeory:NO filePath:nil block:^(bool isResult) {
            
        }];
    }
    else if(DLAPPDELEGATE.currentLoginType == login_wb)
    {
        [[SCach shareInstance] setAsynValue:self key:kStoreUserData_WBkey isMemeory:NO filePath:nil block:^(bool isResult) {
            
        }];
    }
}

+ (BOOL)getUserDataFromFile
{
    NSString *strLoginType = [[NSUserDefaults standardUserDefaults] objectForKey:kDDLoginType];
    if(strLoginType &&strLoginType.length > 0)
    {
        DLAPPDELEGATE.loginType = [strLoginType intValue];
        UserInfoData *userData = nil;
        if(DLAPPDELEGATE.currentLoginType == login_default)
        {
            DLAPPDELEGATE.isIphoneLogin = YES;
            [[SCach shareInstance]valueSynForKey:kStoreUserDataKey isMemory:NO filePath:nil className:@"UserInfoData" outObject:&userData];
            if(userData)
            {
                [UserInfoData setUserData:userData];
            }
        }
        else if(DLAPPDELEGATE.currentLoginType == login_wx)
        {
            DLAPPDELEGATE.isIphoneLogin = NO;
            [[SCach shareInstance]valueSynForKey:kStoreUserData_WXKey isMemory:NO filePath:nil className:@"UserInfoData" outObject:&userData];
            if(userData)
            {
                [UserInfoData setUserData:userData];
            }
        }
        else if(DLAPPDELEGATE.currentLoginType == login_QQ)
        {
            DLAPPDELEGATE.isIphoneLogin = NO;
            [[SCach shareInstance]valueSynForKey:kStoreUserData_QQkey isMemory:NO filePath:nil className:@"UserInfoData" outObject:&userData];
            if(userData)
            {
                [UserInfoData setUserData:userData];
            }
        }
        else if(DLAPPDELEGATE.currentLoginType == login_wb)
        {
            DLAPPDELEGATE.isIphoneLogin = NO;
            [[SCach shareInstance]valueSynForKey:kStoreUserData_WBkey isMemory:NO filePath:nil className:@"UserInfoData" outObject:&userData];
            if(userData)
            {
                [UserInfoData setUserData:userData];
            }
        }
        if(userData.strGender && userData.strUserId && userData.strBirthday && userData.strUserToken)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)clearMemoryData
{
    _strUserId = nil;
    /** 云信token***/
    _strUserToken = nil;
    _strUserTempName = nil;
    _strHeadUrl = nil;
    _strUserMsg = nil;
    _strUserNick = nil;
    _strGender = nil;
    _strBirthday = nil;
    _sexType = -1; //0 M男 1 F女
    _isVip = 0;
    _isLike = 0; //是否喜欢
    _userLeval = 0;
    _shellCount = 0; //咚果
    _moneyCount = 0; //咚币
    _secretKey = nil;
    _vipLosetime = nil; //vip到期时间
    _strUserCode = nil;
    _strConstellation = nil;//星座
    _strAge = nil;
    _strInviteCode = nil;
    _strSex = nil;
    _strUserSign = nil;//用户签名
    _strPlace = nil;//地点
    _wealthlevel = 0;//财富等级
    _charmlevel = 0; //魅力等级
    _activeval = 0;//活跃值
    _wealthval = 0; //财富值
    _charmval = 0;//魅力值
}

@end
