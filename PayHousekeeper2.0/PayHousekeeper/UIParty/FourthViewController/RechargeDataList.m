//
//  RechargeDataList.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "RechargeDataList.h"

@implementation RechargeData

- (void)unPacketData:(NSDictionary *)aDict
{
    AssignMentID(self.title, [aDict objectForKey:@"title"]);
    AssignMentNSNumberFloat(self.price, [aDict objectForKey:@"price"]);
    AssignMentID(self.type, [aDict objectForKey:@"type"]);
    AssignMentID(self.discount, [aDict objectForKey:@"discount"]);
    AssignMentID(self.desc, [aDict objectForKey:@"description"]);
    AssignMentID(self.freeNum, [aDict objectForKey:@"freenum"]);
    AssignMentID(self.dataID, [aDict objectForKey:@"id"]);
    AssignMentID(self.appleItemId, [aDict objectForKey:@"appleitemid"]);
    AssignMentNSNumber(self.isRec, [aDict objectForKey:@"isrec"]);
}

@end

@implementation RechargeDataList
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datalist = [NSMutableArray arrayWithCapacity:0];
        self.appleItemIds = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)unpacketDataList:(NSArray *)aDictArry
{
    if(aDictArry && aDictArry.count>0)
    {
        [self.datalist removeAllObjects];
        for(NSDictionary *dict in aDictArry)
        {
            RechargeData *data = [[RechargeData alloc] init];
            [data unPacketData:dict];
            [self.datalist addObject:data];
            NSString *appleitemid = data.appleItemId;
            if ([appleitemid length]>0)
            {
                [self.appleItemIds addObject:appleitemid];
            }
        }
    }
}

@end

@implementation VIPRechargeDataList
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datalist = [NSMutableArray arrayWithCapacity:0];
        self.appleItemIds = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)unpacketDataList:(NSDictionary *)aDict
{
    self.isvip = [[aDict objectForKey:@"vip"] boolValue];
    if([aDict objectForKey:@"vip"] && ([UserInfoData shareUserInfoData].isVip != self.isvip))
    {
        [[UserInfoData shareUserInfoData] setUserVip:self.isvip];
    }
    
    if ([aDict objectForKey:@"vipName"]) {
        self.vipName = [aDict objectForKey:@"vipName"];
    }
    
    
    self.strVipNotice = [aDict objectForKey:@"vipNotice"];
    self.strVipLoseTime = [aDict objectForKey:@"vip_losetime"];
    NSArray *aDictArry = [aDict objectForKey:@"rechargeList"];
    if(aDictArry && aDictArry.count>0)
    {
        [self.datalist removeAllObjects];
        for(NSDictionary *dict in aDictArry)
        {
            RechargeData *data = [[RechargeData alloc] init];
            [data unPacketData:dict];
            [self.datalist addObject:data];
            NSString *appleitemid = data.appleItemId;
            if ([appleitemid length]>0)
            {
                [self.appleItemIds addObject:appleitemid];
            }
        }
    }
}
@end

