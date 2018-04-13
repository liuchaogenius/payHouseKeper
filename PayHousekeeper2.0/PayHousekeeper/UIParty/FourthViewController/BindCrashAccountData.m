//
//  BindCrashAccountData.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/11.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "BindCrashAccountData.h"

@implementation BindCrashAccountData

- (void)unPackeData:(NSDictionary *)aDict
{
    AssignMentID(self.strAccount, [aDict objectForKey:@"account"]);
    AssignMentID(self.strAccountName, [aDict objectForKey:@"accountName"]);
    AssignMentID(self.strgivePercent, [aDict objectForKey:@"givePercentStr"]);
    AssignMentNSNumberFloat(self.givePercent, [aDict objectForKey:@"givePercent"]);
    AssignMentNSNumberFloat(self.cashRate, [aDict objectForKey:@"cashRate"]);
}
@end
