//
//  InviateData.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "InviateData.h"

@implementation FriListInvite

- (void)unpacketData:(NSDictionary *)aDict
{
    self.accid = [aDict objectForKey:@"accid"];
    self.nickname = [aDict objectForKey:@"nickName"];
    self.headUrl = [aDict objectForKey:@"avatar"];
}

@end


@implementation InviateData
- (void)unpacketData:(NSDictionary *)aDict
{
    AssignMentID(self.inviteCode, [aDict objectForKey:@"inviteCode"]);
    AssignMentNSNumberFloat(self.income, [aDict objectForKey:@"income"]);
    if(!self.frilist)
    {
        self.frilist = [NSMutableArray arrayWithCapacity:0];
    }
    NSArray *arry = [aDict objectForKey:@"inviteList"];
    if(arry && arry.count > 0)
    {
        for(NSDictionary *dict in arry)
        {
            FriListInvite* fri = [[FriListInvite alloc] init];
            [fri unpacketData:dict];
            [self.frilist addObject:fri];
        }
    }
}
@end
