//
//  RechargeDataList.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RechargeData : NSObject
@property (nonatomic, strong) NSString *title;//充值项目
@property (nonatomic) CGFloat price;//价格 单位人民币
@property (nonatomic, strong) NSString *type;//类型，0表示充值咚币，1表示充值vip
@property (nonatomic, strong) NSString *discount;//折扣
@property (nonatomic, strong) NSString *desc;//描述
@property (nonatomic, strong) NSString *freeNum;//赠送
@property (nonatomic, strong) NSString *dataID;
@property (nonatomic, strong) NSString *appleItemId;
@property (nonatomic) int isRec;//是否推荐 1 表示推荐
- (void)unPacketData:(NSDictionary *)aDict;
@end

@interface RechargeDataList : NSObject
@property (nonatomic) NSMutableArray *datalist;
@property (nonatomic) NSMutableArray *appleItemIds;
- (void)unpacketDataList:(NSArray *)aDictArry;
@end

@interface VIPRechargeDataList : NSObject
@property (nonatomic) NSMutableArray *datalist;
@property (nonatomic) NSMutableArray *appleItemIds;
- (void)unpacketDataList:(NSDictionary *)aDict;
@property (nonatomic) BOOL isvip;
@property (nonatomic) NSString *strVipNotice;
@property (nonatomic) NSString *strVipLoseTime;

@property (nonatomic) NSString *vipName;
@end
