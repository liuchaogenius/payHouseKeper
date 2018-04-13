//
//  BroadcastModel.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/20.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BroadcastModel.h"

@implementation BroadcastModel

- (void)unPakceBroadcastInfoDict:(NSDictionary *)aDict
{
    AssignMentID(_content, [aDict objectForKey:@"content"]);
    AssignMentID(_type, [[aDict objectForKey:@"type"] description]);
    AssignMentID(_sendPic, [aDict objectForKey:@"sendPic"]);
    AssignMentID(_senderId, [aDict objectForKey:@"senderId"]);
    AssignMentID(_sender, [aDict objectForKey:@"sender"]);
    AssignMentID(_receiver, [aDict objectForKey:@"receiver"]);
    AssignMentID(_receiverId, [aDict objectForKey:@"receiverId"]);
    AssignMentID(_receiverPic, [aDict objectForKey:@"receiverPic"]);
    AssignMentID(_giftPic, [aDict objectForKey:@"giftPic"]);
    AssignMentID(_effect, [aDict objectForKey:@"effect"]);
}
@end
