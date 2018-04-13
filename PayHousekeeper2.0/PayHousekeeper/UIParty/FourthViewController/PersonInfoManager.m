//
//  PersonInfoManager.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/13.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonInfoManager.h"
#import "NetManager.h"
#import "NSStringEX.h"
#import "AppDelegate.h"

@interface PersonInfoManager()
{
    MyWalletData *wallData;
    MyIncomeData *incomeData;
    RechargeDataList *rechargelist;
    PersonLevelData *levelData;
    OtherUserInfoData *otherUserInfo;
    VIPRechargeDataList *vipRechargeList;
}
@end

@implementation PersonInfoManager

- (instancetype)init
{
    if(self = [super init])
    {
        wallData = [[MyWalletData alloc] init];
        incomeData = [[MyIncomeData alloc] init];
        rechargelist = [[RechargeDataList alloc] init];
        levelData = [[PersonLevelData alloc] init];
        otherUserInfo = [[OtherUserInfoData alloc] init];
        vipRechargeList = [[VIPRechargeDataList alloc] init];
    }
    return self;
}

//请求我的钱包
- (void)requestMyWallet:(void(^)(MyWalletData *data))aBlock
{
    NSMutableDictionary *mutabledict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabledict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:mutabledict apiName:kMyWalletAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [wallData unpacketData:successDict];
            aBlock(wallData);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestMyIncome:(void(^)(MyIncomeData *data))aBlock
{
    NSMutableDictionary *mutabledict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabledict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:mutabledict apiName:kMyIncomeAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [incomeData unpacketData:successDict];
            aBlock(incomeData);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestRechargeList:(int)aType
               completeBock:(void(^)(RechargeDataList* dataList))aBlock
{
    NSMutableDictionary *mutabledict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabledict setObject:[NSNumber numberWithInt:aType] forKey:@"type"];
    
    [NetManager requestWith:mutabledict apiName:kRechargeListAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            if([successDict isKindOfClass:[NSArray class]])
                [rechargelist unpacketDataList:(NSArray *)successDict];
            aBlock(rechargelist);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestUserLevel:(void(^)(PersonLevelData *data))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kGetUserLevelAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [levelData unPacketData:successDict];
            aBlock(levelData);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];

}

- (void)requestOterPersonInfo:(NSString *)aAccid
                completeBlock:(void(^)(OtherUserInfoData *data))aBlock;
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"userid"];
    [dict setObject:aAccid forKey:@"accid"];
    [NetManager requestWith:dict apiName:kGetOterPersonUserInfoAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [otherUserInfo unPakceUserInfoDict:successDict];
            aBlock(otherUserInfo);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestVIPRechargeList:(void(^)(VIPRechargeDataList* dataList))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    
    [NetManager requestWith:dict apiName:kVIPRechargeListAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        MLOG(@"%@",successDict);
        if(successDict)
        {
            [vipRechargeList unpacketDataList:successDict];
            aBlock(vipRechargeList);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestMyConversion:(int)aAmcount completeBlock:(void(^)(int moneyCount,int shellCount))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:[NSString stringWithFormat:@"%d",aAmcount] forKey:@"amount"];
    [NetManager requestWith:dict apiName:kConversionAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
            if(successDict && !isNull(successDict))
            {
                int moneyCount = -1;
                if([successDict objectForKey:@"moneyCount"])
                {
                    moneyCount = [[successDict objectForKey:@"moneyCount"] intValue];
                }
                int shellCount = -1;
                if([successDict objectForKey:@"shellCount"])
                {
                    shellCount = [[successDict objectForKey:@"shellCount"] intValue];
                }
                aBlock(moneyCount,shellCount);
            }
            else
            {
                aBlock(-1,-1);
            }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(-1,-1);
    }];
}


- (void)requestInviateData:(void(^)(InviateData *data))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kInviteInfoAPI method:@"GET" timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            InviateData *data = [[InviateData alloc] init];
            if([successDict objectForKey:@"data"] && !isNull([successDict objectForKey:@"data"]))
            {
                [data unpacketData:[successDict objectForKey:@"data"]];
            }
            aBlock(data);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

//绑定手机
- (void)requestBindPhoneNum:(NSString *)aPhoneNum
                            psw:(NSString *)aPsw
                      checkCode:(NSString *)aCheckCode
                  completeBlock:(void(^)(BOOL ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:aPhoneNum forKey:@"phoneNo"];
    NSString *pswMD5 = [aPsw stringFromMD5];
    long long time = (long long)[[NSDate date] timeIntervalSince1970];
//    NSString *pswAndTime = [NSString stringWithFormat:@"%@%lld",pswMD5,time];
    
//    [dict setObject:SAFE_STR([pswAndTime stringFromMD5]) forKey:@"cryptogram"];
    [dict setObject:SAFE_STR(pswMD5) forKey:@"cryptogram"];
    [dict setObject:SAFE_STR(aCheckCode) forKey:@"checkCode"];
    [dict setObject:[NSString stringWithFormat:@"%lld",time] forKey:@"timestamp"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [NetManager requestWith:dict apiName:kBindPhoneNoAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        int state = [[successDict objectForKey:@"state"] intValue];
//        if(state == 2008)
//        {
//            [del showToastView:@"验证码错误"];
//            MLOG(@"验证码错误");
//            return ;
//        }
        if(state == 999)
        {
            [del showToastView:@"系统正忙"];
            MLOG(@"系统正忙，请稍候重试！");
            return ;
        }
        if(state == 2035)
        {
            [del showToastView:@"手机号已被其他用户绑定"];
            MLOG(@"手机号已被其他用户绑定");
            return ;
        }
        if(state == 2002)
        {
            [del showToastView:@"手机号码已经注册过"];
            return;
        }
        
        if(state == 200)
        {
//            [[UserInfoData shareUserInfoData] unPackeRegisterDict:successDict];
            aBlock(YES);
        }
        else
        {
            
//            [del showToastView:@"绑定失败"];
            
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}


- (void)requestBindList:(void(^)(BindListData *datalist))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kBindListAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            BindListData *listdata = [[BindListData alloc] init];
            if([successDict isKindOfClass:[NSArray class]])
                [listdata unPacketDatalist:(NSArray *)successDict];
            aBlock(listdata);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestThirdLoginInfo:(NSString *)aThirdNickName
                       openid:(NSString *)aOpenId
                         type:(NSString *)aType
                completeBlock:(void(^)(int ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];

    [dict setObject:SAFE_STR(aThirdNickName) forKey:@"nickName"];
    [dict setObject:SAFE_STR(aOpenId) forKey:@"openId"];
    [dict setObject:SAFE_STR(aType) forKey:@"type"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [NetManager requestWith:dict apiName:kThirdBindAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            
            int state = [[successDict objectForKey:@"state"] intValue];
            if(state == 200)
            {
                aBlock(YES);
            }
            else
            {
                aBlock(NO);
            }
            if(state == 2023)
            {
                [del showToastView:@"绑定失败"];
            }
            else if(state == 2024)
            {
                [del showToastView:@"该账号已经绑定"];
            }
            else if(state == 2025)
            {
                [del showToastView:@"该账号已经被其他用户绑定"];
            }
            else if(state == 2026)
            {
                [del showToastView:@"重复绑定"];
            }
            else
            {
                [del showToastView:@"绑定成功"];
            }
        }
        else
        {
            [del showToastView:@"绑定成功"];
            aBlock(YES);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        [del showToastView:@"网络异常"];
        aBlock(NO);
    }];
}

- (void)requestUnBindThirdLoginInfo:(NSString *)aType completeBlock:(void(^)(int ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:SAFE_STR(aType) forKey:@"type"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [NetManager requestWith:dict apiName:kThirdUnBindAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            
            int state = [[successDict objectForKey:@"state"] intValue];
            if(state == 200)
            {
                aBlock(YES);
            }
            else
            {
                aBlock(NO);
            }
            if(state == 2027)
            {
                [del showToastView:@"解绑失败"];
            }
            else if(state == 2028)
            {
                [del showToastView:@"绑定数少于2个不能解绑"];
            }
            else if(state == 2029)
            {
                [del showToastView:@"未绑定该账号"];
            }
        }
        else
        {
            [del showToastView:@"解绑成功"];
            aBlock(YES);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        [del showToastView:@"网络异常"];
        aBlock(NO);
    }];
    
}

- (void)requestExchangeDBList:(void(^)(ExchangeDBDataList *datalist))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kChangeItemAPI method:KGet timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            ExchangeDBDataList *list = [ExchangeDBDataList new];
            [list unPacketDatalist:(NSArray *)[successDict objectForKey:@"data"]];
            aBlock(list);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

- (void)requestAlipayCashAccount:(NSString *)aAccount name:(NSString *)aName dgCount:(NSString *)aDgcount completeBlock:(void(^)(int ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
//    [dict setObject:SAFE_STR(aAccount) forKey:@"account"];
//    [dict setObject:SAFE_STR(aName) forKey:@"accountName"];
    [dict setObject:SAFE_STR(aDgcount) forKey:@"amount"];
    
    [NetManager requestWith:dict apiName:kAlipayCashAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            int shellcount = [[successDict objectForKey:@"shellCount"] intValue];
            [[UserInfoData shareUserInfoData] setCurrentShellCount:shellcount];
            aBlock(0);
        }
        else
        {
            aBlock(-1);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(-1);
    }];
}

- (void)getUserExtInfo:(void(^)(BOOL isVip,NSString *vipName))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    
    [NetManager requestWith:dict apiName:kGetUserExtInfoAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            BOOL isvip = NO;
            NSString *sIsvip = SAFE_STR([successDict objectForKey:@"vip"]);
            if(sIsvip && [sIsvip compare:@"true"]==0)
            {
                isvip = YES;
            }
            NSString *vipname = SAFE_STR([successDict objectForKey:@"vipName"]);
            aBlock(isvip,vipname);
        }
        else
        {
            aBlock(false,nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(false,nil);
    }];
}

- (void)requestBindCrashAlipayAccount:(NSString *)aAccount name:(NSString *)aRealName completeBlock:(void(^)(BOOL isBind))aBlock
{
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:SAFE_STR(aAccount) forKey:@"account"];
    [dict setObject:SAFE_STR(aRealName) forKey:@"accountName"];
    [NetManager requestWith:dict apiName:kBindCrashAlipayAccountAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        int status = [[successDict objectForKey:@"state"] intValue];
        if(status == 200)
        {
//            [del showToastView:@"绑定成功"];
            aBlock(YES);
        }
        else
        {
            [del showToastView:@"绑定失败"];
            aBlock(NO);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        [del showToastView:@"绑定失败"];
        aBlock(NO);
    }];
}

- (void)requestGetBindCrashAccountInfo:(void(^)(BindCrashAccountData *aData))aBlock
{
//    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kGetBindCrashAccountInfoAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            BindCrashAccountData *data = [[BindCrashAccountData alloc] init];
            [data unPackeData:successDict];
            aBlock(data);
        }
        else
        {
            aBlock(nil);
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}
@end
