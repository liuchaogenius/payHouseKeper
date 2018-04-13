//
//  PersonLevelData.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/19.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonLevelData.h"

@implementation PersonLevelData
- (void)unPacketData:(NSDictionary *)aDict
{
    AssignMentID(self.strLevel, [aDict objectForKey:@"level"]);
    AssignMentID(self.strCharmVal, [aDict objectForKey:@"charmVal"]);
    AssignMentID(self.strPercent, [aDict objectForKey:@"percent"]);
    AssignMentNSNumber(self.iMark, [aDict objectForKey:@"mark"]);
    AssignMentNSNumber(self.iNextMark, [aDict objectForKey:@"nextMark"]);
    AssignMentNSNumber(self.iNeedMark, [aDict objectForKey:@"needMark"]);
    AssignMentNSNumber(self.iActiveVal, [aDict objectForKey:@"activeVal"]);
    AssignMentNSNumber(self.iWealthVal, [aDict objectForKey:@"wealthVal"]);
    AssignMentID(self.strUserCode, [aDict objectForKey:@"userCode"]);
}

@end
