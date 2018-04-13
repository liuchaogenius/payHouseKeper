//
//  OtherUserInfoData.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "OtherUserInfoData.h"

@implementation OtherUserInfoData
- (void)unPakceUserInfoDict:(NSDictionary *)aDict
{
    AssignMentID(_strUserId, [aDict objectForKey:@"accid"]);
//    AssignMentID(_strUserToken, [aDict objectForKey:@"token"]);
    AssignMentID(_strUserNick, [aDict objectForKey:@"nickName"]);
    AssignMentID(_strGender, [aDict objectForKey:@"gender"]);
    
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
    AssignMentID(_strBirthday, [aDict objectForKey:@"birthday"]);
    AssignMentID(_strHeadUrl, [aDict objectForKey:@"avatar"]);
    AssignMentID(_strUserMsg, [aDict objectForKey:@"mood"]);
    if([aDict objectForKey:@"level"])
    {
        AssignMentNSNumber(_userLeval, [aDict objectForKey:@"level"]);
    }
//    if([aDict objectForKey:@"shellCount"])
//    {
//        _shellCount = [[aDict objectForKey:@"shellCount"] longLongValue];
//    }
//    if([aDict objectForKey:@"moneyCount"])
//    {
//        _moneyCount = [[aDict objectForKey:@"moneyCount"] longLongValue];
//    }
//    AssignMentID(_secretKey, [aDict objectForKey:@"secretKey"]);
    _isVip = [[aDict objectForKey:@"vip"] boolValue];
//    _vipLosetime = [aDict objectForKey:@"vip_losetime"];
    _strUserCode = [aDict objectForKey:@"userCode"];
    _strConstellation = [aDict objectForKey:@"constellation"];
    _strAge = [aDict objectForKey:@"age"];
    _strUserSign = [aDict objectForKey:@"userSign"];
    
    _wealthlevel = [[aDict objectForKey:@"wealthLevel"] intValue];
    _charmlevel = [[aDict objectForKey:@"charmLevel"] intValue];
    _activeval = [[aDict objectForKey:@"activeVal"] intValue];
    _wealthval = [[aDict objectForKey:@"wealthVal"] intValue];
    _charmval = [[aDict objectForKey:@"charmVal"] intValue];
}

- (void)unPakceUserInfo:(UserInfoData *)user
{
    _strUserId = user.strUserId;
    _strUserNick = user.strUserNick;
    _strGender = user.strGender;
    _sexType = user.sexType;
    _strSex = user.strSex;
    _strBirthday = user.strBirthday;
    _strHeadUrl = user.strHeadUrl;
    _strUserMsg = user.strUserMsg;
    _userLeval = user.userLeval;
    _isVip = user.isVip;
    _strUserCode = user.strUserCode;
    _strConstellation = user.strConstellation;
    _strAge = user.strAge;
    _strUserSign = user.strUserSign;
    
    _wealthlevel = user.wealthlevel;
    _charmlevel = user.charmlevel;
    _activeval = user.activeval;
    _wealthval = user.wealthval;
    _charmval = user.charmval;
}

@end
