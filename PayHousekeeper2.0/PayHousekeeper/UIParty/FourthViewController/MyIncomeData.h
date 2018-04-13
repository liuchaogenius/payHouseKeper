//
//  MyIncomeData.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyIncomeData : NSObject

@property (nonatomic, strong) NSString *giftName;//礼物名称
@property (nonatomic) CGFloat price;//虚拟价格 单位咚币
@property (nonatomic) CGFloat realPrice;//真是价格 单位人民币
@property (nonatomic, strong) NSString *incomeTime;//收益事件
@property (nonatomic, strong) NSString *sendAccid;//发送成id
@property (nonatomic, strong) NSString *sendName;//发送者名称
- (void)unpacketData:(NSDictionary *)aDict;
@end
