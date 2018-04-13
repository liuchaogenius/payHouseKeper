//
//  GiftModel.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "GiftModel.h"

@implementation GiftModel
- (void)unPakceGiftInfoDict:(NSDictionary *)aDict
{
    AssignMentID(_strID, [aDict objectForKey:@"id"]);
    AssignMentID(_name, [aDict objectForKey:@"name"]);
    AssignMentID(_price, [[aDict objectForKey:@"price"] description]);
    AssignMentID(_seconds, [[aDict objectForKey:@"seconds"] description]);
    AssignMentID(_type, [[aDict objectForKey:@"type"] description]);
    AssignMentID(_isvip, [[aDict objectForKey:@"isvip"] description]);
    AssignMentID(_icon, [aDict objectForKey:@"icon"]);
    AssignMentID(_effect, [aDict objectForKey:@"effect"]);
}

- (NSDictionary *)pakceGiftInfoDict
{
    NSDictionary *dic = @{@"name":_name,
                          @"price":_price,
                          @"seconds":_seconds,
                          @"type":_type,
                          @"isvip":_isvip,
                          @"icon":_icon,
                          @"effect":_effect
                          };
    return dic;
}

@end
