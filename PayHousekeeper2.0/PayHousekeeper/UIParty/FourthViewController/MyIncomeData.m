//
//  MyIncomeData.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MyIncomeData.h"

@implementation MyIncomeData

- (void)unpacketData:(NSDictionary *)aDict
{
    AssignMentID(self.giftName, [aDict objectForKey:@"name"]);
    AssignMentNSNumberFloat(self.price, [aDict objectForKey:@"price"]);

    AssignMentNSNumberFloat(self.realPrice, [aDict objectForKey:@"realprice"]);

    AssignMentID(self.incomeTime, [aDict objectForKey:@"incometime"]);
    AssignMentID(self.sendAccid, [aDict objectForKey:@"send_accid"]);
    AssignMentID(self.sendName, [aDict objectForKey:@"send_name"]);

}
@end
