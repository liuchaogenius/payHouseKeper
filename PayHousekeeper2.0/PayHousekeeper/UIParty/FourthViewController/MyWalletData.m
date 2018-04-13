//
//  MyWalletData.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/16.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MyWalletData.h"

@implementation MyWalletData

- (void)unpacketData:(NSDictionary *)aDict
{
    self.shellCount = [[aDict objectForKey:@"shellCount"] floatValue];
    self.moneyCount = [[aDict objectForKey:@"moneyCount"] floatValue];
    self.rule = [[aDict objectForKey:@"rule"] floatValue];
    self.desc = [aDict objectForKey:@"desc"];
    self.cashRate = [[aDict objectForKey:@"cashrate"]floatValue];
    
    if([aDict objectForKey:@"shellCount"] && self.shellCount > 0)
    {
        [[UserInfoData shareUserInfoData] setCurrentShellCount:self.shellCount];
    }
    if([aDict objectForKey:@"moneyCount"] && self.moneyCount > 0)
    {
        [[UserInfoData shareUserInfoData] setCurrentMoneyCount:self.moneyCount];
    }
}

@end
