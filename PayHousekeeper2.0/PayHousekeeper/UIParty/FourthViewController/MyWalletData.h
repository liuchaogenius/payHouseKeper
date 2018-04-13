//
//  MyWalletData.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWalletData : NSObject
@property (nonatomic) CGFloat shellCount; //咚果
@property (nonatomic) CGFloat moneyCount; //咚币
@property (nonatomic) CGFloat rule;//兑换规则，moneyCount*rule=可以兑换的咚呗
@property (nonatomic) NSString *desc; //保留字段，作为兑换说明
@property (nonatomic) CGFloat  cashRate;//提现汇率
- (void)unpacketData:(NSDictionary *)aDict;
@end
