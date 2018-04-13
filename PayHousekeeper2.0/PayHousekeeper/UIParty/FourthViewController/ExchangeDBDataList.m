//
//  ExchangeDBDataList.m
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "ExchangeDBDataList.h"


@implementation ExchangeDBData

- (void)unPacketData:(NSDictionary *)aDict
{
    AssignMentID(self.dataId, [aDict objectForKey:@"id"]);
    AssignMentID(self.shellCount, [aDict objectForKey:@"shellCount"]);
    AssignMentID(self.moneyCount, [aDict objectForKey:@"moneyCount"]);
}

@end

@implementation ExchangeDBDataList

- (void)unPacketDatalist:(NSArray<NSDictionary *> *)aDictArry;
{
    if(aDictArry && aDictArry.count > 0)
    {
        if(!self.dataList)
        {
            self.dataList = [NSMutableArray arrayWithCapacity:0];
        }
        for(NSDictionary *dict in aDictArry)
        {
            ExchangeDBData *data = [ExchangeDBData new];
            [data unPacketData:dict];
            [self.dataList addObject:data];
        }
    }
}

@end
