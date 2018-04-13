//
//  DDLoginManager.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "DDLoginManager.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "NSData+Base64.h"
#import "UserInfoData.h"
#import "NSDateDeal.h"
#import "NSStringEX.h"
#import "AppDelegate.h"
#import "OtherUserInfoData.h"

@implementation DDLoginManager

// 判断是否是11位手机号码
+ (BOOL)judgePhoneNumber:(NSString *)phoneNum
{

    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    
    // 一个判断是否是手机号码的正则表达式
    NSString *pattern = [NSString stringWithFormat:@"(%@)|(%@)|(%@)",CM_NUM,CU_NUM,CT_NUM];
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *mobile = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11) {
        NO;
    }
    
    // 无符号整型数据接收匹配的数据的数目
    NSUInteger numbersOfMatch = [regularExpression numberOfMatchesInString:mobile options:NSMatchingReportProgress range:NSMakeRange(0, mobile.length)];
    if (numbersOfMatch>0)
    {
        if (!(phoneNum.length == 11)) {
            return NO;
        }
        else
        {
            return YES;
        }
    
    }
    else
    {
        
        return NO;
    }
    
    
}


+ (DDLoginManager *)shareLoginManager
{
    static DDLoginManager *loginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginManager = [[DDLoginManager alloc] init];
    });
    return loginManager;
}
//获取验证码
- (void)requestVerCode:(NSString *)aPhoneNum codeType:(int)aCodeType
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:aPhoneNum forKey:@"phoneNo"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [del showToastView:@"获取中"];
    NSString *apiName = kGetVerCode;
    if(aCodeType == 1)
    {
        [dict setObject:@"reset" forKey:@"type"];
    }
    if(aCodeType == 10)
    {
        [dict setObject:@"bind" forKey:@"type"];
    }
    [NetManager requestWith:dict apiName:apiName method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        MLOG(@"checkCode == %@",successDict);
    } failure:^(NSDictionary *failDict, NSError *error) {
        
    }];
}

//注册
- (void)requestRegisterPhoneNum:(NSString *)aPhoneNum
                            psw:(NSString *)aPsw
                      checkCode:(NSString *)aCheckCode
                  completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:aPhoneNum forKey:@"phoneNo"];
    NSString *pswMD5 = [aPsw stringFromMD5];
    [dict setObject:pswMD5 forKey:@"cryptogram"];
    [dict setObject:aCheckCode forKey:@"checkCode"];
    
    [NetManager requestWith:dict apiName:kRegisterAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        
        NSLog(@"=======%@", successDict);
        if(successDict)
        {
            [[UserInfoData shareUserInfoData] unPackeRegisterDict:successDict];
            aBlock(YES);
        }
        else{
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//完善资料
- (void)reqestComInfoGender:(NSString *)aGender
                   nickName:(NSString *)aNickName
                    imgData:(NSData*)aImgData
                   birthday:(NSString *)aBirthDay
                 inviteCode:(NSString *)aInviteCode
                      place:(NSString *)place
              completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if([UserInfoData shareUserInfoData].strUserId)
    {
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    }
    if(aGender && aGender.length > 0)
    {
        [dict setObject:aGender forKey:@"gender"];
    }
    if(aNickName && aNickName.length > 0)
    {
        [dict setObject:aNickName?aNickName:@"" forKey:@"nickName"];
    }
    if(aBirthDay && aBirthDay.length > 0)
    {
        [dict setObject:aBirthDay?aBirthDay:@"" forKey:@"birthday"];
    }
    if(aImgData)
    {
        [dict setObject:aImgData forKey:@"avatar"];
    }
    if(aInviteCode)
    {
        [dict setObject:aInviteCode forKey:@"inviteCode"];
    }
    if(place)
    {
        [dict setObject:place forKey:@"place"];
    }
    [NetManager requestWith:dict apiName:kComInfo method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [[UserInfoData shareUserInfoData] unPakceComInfoDict:successDict];
            aBlock(YES);
        }
        else
        {
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//登陆
- (void)requestLoginPhoneNum:(NSString *)aPhoneNum
                            psw:(NSString *)aPsw
                  completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    long long time = (long long)[NSDateDeal getCurrentTimeInterval];
    NSMutableString *mutstr = [NSMutableString stringWithCapacity:0];
    
    [mutstr appendString:[aPsw stringFromMD5]];
    [mutstr appendString:[NSString stringWithFormat:@"%lld",time]];
    NSString *pswMD5 = [mutstr stringFromMD5];
    [dict setObject:aPhoneNum?aPhoneNum:@"" forKey:@"phoneNo"];
    [dict setObject:pswMD5 forKey:@"cryptogram"];
    [dict setObject:[NSString stringWithFormat:@"%lld",time] forKey:@"timestamp"];
    [NetManager requestWith:dict apiName:kLoginAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict && [successDict isKindOfClass:[NSDictionary class]])
        {
            [[UserInfoData shareUserInfoData] unPakceComInfoDict:successDict];
            aBlock(YES);
        }
        else
        {
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//编辑心情
- (void)requestMood:(NSString *)aMood
      completeBlock:(void(^)(BOOL ret))aBlock
{
    [MobClick event:MsgClickMood];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if([UserInfoData shareUserInfoData].strUserId)
    {
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    }
    [dict setObject:aMood?aMood:@" " forKey:@"mood"];
    
    [NetManager requestWith:dict apiName:kUpdateStatusAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        [[UserInfoData shareUserInfoData] setUserMsg:aMood];
        aBlock(YES);
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//编辑签名
- (void)requestUserSig:(NSString *)sig
      completeBlock:(void(^)(BOOL ret))aBlock
{
    [MobClick event:MsgClickMood];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if([UserInfoData shareUserInfoData].strUserId)
    {
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    }
    [dict setObject:sig?sig:@" " forKey:@"userSign"];


    [NetManager requestWith:dict apiName:kComInfo method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [[UserInfoData shareUserInfoData]setUserSign:[successDict objectForKey:@"userSign"]];
            aBlock(YES);
        }
        else
        {
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
    
}


//重置密码
- (void)requestRestPasswordPhoneNum:(NSString *)aPhoneNum
                                psw:(NSString *)aPsw
                          checkCode:(NSString *)aCheckCode
                      completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:aPhoneNum forKey:@"phoneNo"];
    NSString *pswBase64 = [aPsw stringFromMD5];
    [dict setObject:pswBase64 forKey:@"cryptogram"];
    [dict setObject:aCheckCode forKey:@"checkCode"];
    [NetManager requestWith:dict apiName:kResetPSW method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        aBlock(YES);
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//查找好友
- (void)requestSearchFriend:(NSString *)keyword
                      accid:(NSString *)accid
              completeBlock:(void(^)(NSMutableArray *userArr))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:accid forKey:@"accid"];
    [dict setObject:keyword forKey:@"keyword"];
    
    [NetManager requestWith:dict apiName:kPueryUserAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            NSMutableArray *tmpArr = [NSMutableArray array];
            OtherUserInfoData *userInfo = [[OtherUserInfoData alloc] init];
            [userInfo unPakceUserInfoDict:successDict];
//            if(![userInfo.strUserId isEqualToString:accid])
//            {
                [tmpArr addObject:userInfo];
//            }
            aBlock(tmpArr);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];

}

#pragma mark 手机号码验证
+ (BOOL)checkPhoneNum:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    // 178 147 176  145  177  170
    NSString *LOST = @"^1(4[57]|7[0678])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestLost = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", LOST];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestLost evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (BOOL)requestThirdLogin:(NSString *)aOpenId  //必须
                loginType:(NSString *)aLoginType //必须
                  hearUrl:(NSString *)aHeadUrl   //否 头像url
                     nick:(NSString *)aNickName  // 否
                   gender:(NSString*)aGender  // 否 M:男 F:女
                 birthday:(NSString *)aBirthday //否
              loginResult:(void(^)(int result))aBlock
{
    if(aOpenId && aLoginType)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:aOpenId forKey:@"openId"];
        [dict setObject:aLoginType forKey:@"type"];
        if(aHeadUrl)
        {
            [dict setObject:aHeadUrl forKey:@"avatar"];
        }
        if(aNickName)
        {
            [dict setObject:aNickName forKey:@"nickname"];
        }
        if(aGender)
        {
            [dict setObject:aGender forKey:@"gender"];
        }
        if(aBirthday)
        {
            [dict setObject:aBirthday forKey:@"birthday"];
        }
        [NetManager requestWith:dict apiName:kThirdLoginAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
            MLOG(@"%@",successDict);
            if(successDict)
            {
                [[UserInfoData shareUserInfoData] unPakceComInfoDict:successDict];
                if((![UserInfoData shareUserInfoData].strGender || [UserInfoData shareUserInfoData].strGender.length==0) ||
                   (![UserInfoData shareUserInfoData].strBirthday || [UserInfoData shareUserInfoData].strBirthday.length == 0) ||
                   (![UserInfoData shareUserInfoData].strHeadUrl || [UserInfoData shareUserInfoData].strHeadUrl.length == 0) ||
                   (![UserInfoData shareUserInfoData].strUserNick || [UserInfoData shareUserInfoData].strUserNick.length == 0))
                {
                    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [del showAdditionaPersonInfovc];
                }
                else
                {
                    aBlock(0);
                }
            }
            else
            {
                aBlock(-1);
            }
        } failure:^(NSDictionary *failDict, NSError *error) {
            aBlock(-1);
        }];
    }
    else{
        aBlock(-1);
        return NO;
    }
    return YES;
}

- (void)requesUpdateUserInfo:(NSString *)aAccid
                completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"userid"];
    [dict setObject:aAccid forKey:@"accid"];
    [NetManager requestWith:dict apiName:kGetOterPersonUserInfoAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict){
        [[UserInfoData shareUserInfoData] unPakceComInfoDict:successDict];
        aBlock(YES);
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}
@end
