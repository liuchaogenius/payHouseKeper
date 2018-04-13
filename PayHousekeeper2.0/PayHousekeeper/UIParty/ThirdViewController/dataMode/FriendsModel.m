//
//  FriendsModel.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "FriendsModel.h"

@implementation FriendsModel

- (void)unPakceFriendsInfoDict:(NSDictionary *)aDict
{
    AssignMentID(_friendId, [aDict objectForKey:@"friendId"]);
    AssignMentID(_remarks, [aDict objectForKey:@"remarks"]);
    AssignMentID(_nickName, [aDict objectForKey:@"nickName"]);
    AssignMentID(_avatar, [aDict objectForKey:@"avatar"]);
    AssignMentID(_gender, [aDict objectForKey:@"gender"]);
    AssignMentID(_userSign, [aDict objectForKey:@"userSign"]);
    _isVip = [[aDict objectForKey:@"vip"] boolValue];
}

@end
