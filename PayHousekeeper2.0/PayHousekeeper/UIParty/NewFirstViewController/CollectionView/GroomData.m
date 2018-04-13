//
//  GroomData.m
//  DongDong
//
//  Created by BY on 2017/3/14.
//  Copyright © 2017年 BestLife. All rights reserved.

#import "GroomData.h"

@implementation GroomData
+ (GroomData *)unPacketData:(NSDictionary *)aDict
{
    GroomData *data = [[GroomData alloc] init];
    
    data.title = [aDict objectForKey:@"price"];
    
    data.img = [aDict objectForKey:@"img"];
    
    data.loveCount = [[aDict objectForKey:@"h"] intValue] ;
    
    
    return data;
}
@end
