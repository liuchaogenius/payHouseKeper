//
//  NoticsMoodsModel.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/10.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "NoticsMoodsModel.h"

@implementation NoticsMoodsModel

- (void)unPackeDict:(NSDictionary *)aDict
{
    _content = [aDict objectForKey:@"content"];
    _type = [aDict objectForKey:@"type"];    
}

@end
