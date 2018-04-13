//
//  ApplePayOrderData.m
//  PayHousekeeper
//
//  Created by sp on 2017/2/4.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "ApplePayService.h"

@interface ApplePayService()

@property (nonatomic, copy)void(^payReusltBlock)(ApplePayResultType result);

@end
@implementation ApplePayService

+ (ApplePayService *)shareApplePayService
{
    static ApplePayService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ApplePayService alloc] init];
    });
    return service;
}

- (void)requestApplePayVerify:(NSString*)receipt
                  appleitemid:(NSString *)appleitemid
                       amount:(NSString *)aAmount //购买个数
                completeBlock:(void(^)(ApplePayResultType ret))aBlock;
{
    self.payReusltBlock = aBlock;
    WeakSelf(self);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if(!receipt)
    {
        receipt = @"  ";
    }
    [dict setObject:receipt forKey:@"receipt-data"];
    [dict setValue:appleitemid forKey:@"appleitemid"];
    [dict setValue:aAmount forKey:@"amount"];
    [dict setValue:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [NetManager requestWith:dict apiName:kAppleVerifyAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        MLOG(@"requestApplePayVerify = %@",successDict);
        NSString *tradeState = [successDict objectForKey:@"tradeState"];
        if([tradeState isEqualToString:@"SUCCESS"])
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(applepay_success);
                weakself.payReusltBlock = nil;
            }
        }
        else
        {
            if(weakself.payReusltBlock)
            {
                weakself.payReusltBlock(applepay_fail);
                weakself.payReusltBlock = nil;
            }
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        if(weakself.payReusltBlock)
        {
            weakself.payReusltBlock(applepay_fail);
            weakself.payReusltBlock = nil;
        }
    }];
}

@end
