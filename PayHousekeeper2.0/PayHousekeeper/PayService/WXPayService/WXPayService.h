//
//  WXPayService.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WXPay_success,
    WXPay_paying,
    WXPay_fail
}WXpayResultType;

@interface WXPayOrderData : NSObject
@property (nonatomic) NSString *prepayId;//预支付交易会话标识
@property (nonatomic) NSString *appId; //应用id
@property (nonatomic) NSString *nonceStr;//随机字符串
@property (nonatomic) NSString *packageValue;//扩展字段，暂填写固定值Sign=WXPay
@property (nonatomic) NSString *partnerId;//商户号
@property (nonatomic) NSString *timeStamp;//时间戳
@property (nonatomic) NSString *sign;//签名
@end

@interface WXPayService : NSObject
@property (nonatomic, strong) NSString *strPrepayId;
@property (nonatomic, copy)void(^payResultBlock)(WXpayResultType ret);
+ (WXPayService *)shareWXPayService;

- (void)requestWXPayOrderItemId:(NSString *)aItemid //商品id
                   amount:(NSString *)aAmount //购买个数
                     type:(NSString *)aType //类型，1 购买 2赠送
            completeBlock:(void(^)(WXpayResultType ret))aBlock;

- (void)requestWXPayVerify:(void(^)(NSString *tradeState, NSString *out_trade_no,int ret))aBlock;

@end

