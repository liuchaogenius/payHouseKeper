//
//  PersonInfoManager.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/13.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWalletData.h"
#import "MyIncomeData.h"
#import "RechargeDataList.h"
#import "PersonLevelData.h"
#import "UserInfoData.h"
#import "OtherUserInfoData.h"
#import "InviateData.h"
#import "BindListData.h"
#import "ExchangeDBDataList.h"
#import "BindCrashAccountData.h"

@interface PersonInfoManager : NSObject

//获取用户等级
- (void)requestUserLevel:(void(^)(PersonLevelData *data))aBlock;

//获取他人信息
- (void)requestOterPersonInfo:(NSString *)aAccid
                completeBlock:(void(^)(OtherUserInfoData *data))aBlock;

//获取充值项目清单 aType 0是vip充值 1是vip充值
- (void)requestRechargeList:(int)aType
               completeBock:(void(^)(RechargeDataList* dataList))aBlock;

//获取VIP充值项目清单
- (void)requestVIPRechargeList:(void(^)(VIPRechargeDataList* dataList))aBlock;

//我的收益
- (void)requestMyIncome:(void(^)(MyIncomeData *data))aBlock;

//我的钱包
- (void)requestMyWallet:(void(^)(MyWalletData *data))aBlock;

//兑换接口 moneyCount:咚币余额   shellCount:咚贝余额
- (void)requestMyConversion:(int)aAmcount completeBlock:(void(^)(int moneyCount,int shellCount))aBlock;

//用户邀请页面的请求
- (void)requestInviateData:(void(^)(InviateData *data))aBlock;

///绑定手机接口
- (void)requestBindPhoneNum:(NSString *)aPhoneNum
                        psw:(NSString *)aPsw
                  checkCode:(NSString *)aCheckCode
              completeBlock:(void(^)(BOOL ret))aBlock;

//获取绑定list
- (void)requestBindList:(void(^)(BindListData *datalist))aBlock;

//绑定第三方登录 atype{0=QQ, 1=微信,2=新浪微博}
- (void)requestThirdLoginInfo:(NSString *)aThirdNickName
                       openid:(NSString *)aOpenId
                         type:(NSString *)aType
                completeBlock:(void(^)(int ret))aBlock;
//解绑 0表示QQ，1标识微信，2表示新浪微博
- (void)requestUnBindThirdLoginInfo:(NSString *)aType completeBlock:(void(^)(int ret))aBlock;

//获取兑换清单列表
- (void)requestExchangeDBList:(void(^)(ExchangeDBDataList *datalist))aBlock;

//提现接口
- (void)requestAlipayCashAccount:(NSString *)aAccount name:(NSString *)aName dgCount:(NSString *)aDgcount completeBlock:(void(^)(int ret))aBlock;
//获取用户vip信息
- (void)getUserExtInfo:(void(^)(BOOL isVip,NSString *vipName))aBlock;
//绑定用户提现账号
- (void)requestBindCrashAlipayAccount:(NSString *)aAccount name:(NSString *)aRealName completeBlock:(void(^)(BOOL isBind))aBlock;

//获取绑定用户信息
- (void)requestGetBindCrashAccountInfo:(void(^)(BindCrashAccountData *aData))aBlock;
@end
