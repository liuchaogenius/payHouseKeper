//
//  ZFBPayService.h
//  PayHousekeeper
//
//  Created by 1 on 2016/12/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlipaySDK.framework/Headers/AlipaySDK.h"
typedef enum {
    alipay_success,
    alipay_paying,
    alipay_fail
}AlipayResultType;
@interface ZFBPayService : NSObject

+ (ZFBPayService *)shareZFBPayService;

- (void)requestAliPayOrderItemId:(NSString *)aItemid //商品id
                          amount:(NSString *)aAmount //购买个数
                            type:(NSString *)aType //类型，1 购买 2赠送
                   completeBlock:(void(^)(AlipayResultType ret))aBlock;

- (void)requestAlipayVerifyTradeNum:(NSString*)aTradeNum;
@end
