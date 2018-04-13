//
//  ApplePayOrderData.h
//  PayHousekeeper
//
//  Created by sp on 2017/2/4.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    applepay_success,
    applepay_fail
}ApplePayResultType;

@interface ApplePayService : NSObject
+ (ApplePayService *)shareApplePayService;

- (void)requestApplePayVerify:(NSString*)receipt
                  appleitemid:(NSString *)appleitemid
                       amount:(NSString *)aAmount //购买个数
                completeBlock:(void(^)(ApplePayResultType ret))aBlock;
@end
