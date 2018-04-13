//
//  ZFBPayService.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "ZFBPayService.h"
#import "AppDelegate.h"
@interface ZFBPayService()
@property (nonatomic, copy)void(^payReusltBlock)(AlipayResultType result);
@end
@implementation ZFBPayService

+ (ZFBPayService *)shareZFBPayService
{
    static ZFBPayService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ZFBPayService alloc] init];
    });
    return service;
}

- (void)requestAliPayOrderItemId:(NSString *)aItemid //商品id
                         amount:(NSString *)aAmount //购买个数
                           type:(NSString *)aType //类型，1 购买 2赠送
                  completeBlock:(void(^)(AlipayResultType ret))aBlock
{
    self.payReusltBlock = aBlock;
    WeakSelf(self);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:aItemid forKey:@"itemId"];
    [dict setObject:aAmount forKey:@"amount"];
    [dict setObject:aType forKey:@"type"];
    [NetManager requestWith:dict apiName:kAlipaySignAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            NSString *order = [successDict objectForKey:@"orderInfo"];
            AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
            del.loginType = payOrderType_alipay;
            [weakself requestZFBPayOrder:order fromScheme:@"alisdk2016120103668638"];
        }
        else
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(alipay_fail);
                weakself.payReusltBlock = nil;
            }
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        if(weakself.payReusltBlock)
        {
            weakself.payReusltBlock(alipay_fail);
            weakself.payReusltBlock = nil;
        }
    }];
}


- (void)requestZFBPayOrder:(NSString *)orderStr
                fromScheme:(NSString *)schemeStr
{
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:schemeStr callback:^(NSDictionary *resultDic) {
        NSString *strReuslt = [resultDic objectForKey:@"result"];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[strReuslt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *alipayRespDict = [dict objectForKey:@"alipay_trade_app_pay_response"];
        NSString *strTradeNo = [alipayRespDict objectForKey:@"out_trade_no"];
        [[ZFBPayService shareZFBPayService] requestAlipayVerifyTradeNum:strTradeNo];
    }];
}

- (void)requestAlipayVerifyTradeNum:(NSString*)aTradeNum
{
    WeakSelf(self);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if(!aTradeNum)
    {
        aTradeNum = @"  ";
    }
    [dict setObject:aTradeNum forKey:@"out_trade_no"];
    [NetManager requestWith:dict apiName:kAlipayVerifyAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        MLOG(@"requestAlipayVerifyTradeNum = %@",successDict);
        if(successDict == nil)
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(alipay_fail);
                weakself.payReusltBlock = nil;
            }
            return ;
        }
        int tradeState = [[successDict objectForKey:@"tradeState"] intValue];
        if(tradeState==2015 || tradeState==2018 ||tradeState==2019 ||tradeState==2020)
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(alipay_fail);
                weakself.payReusltBlock = nil;
            }
        }
        else
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(alipay_success);
                weakself.payReusltBlock = nil;
            }
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        if(weakself.payReusltBlock)
        {
            weakself.payReusltBlock(alipay_fail);
            weakself.payReusltBlock = nil;
        }
    }];
}
@end
