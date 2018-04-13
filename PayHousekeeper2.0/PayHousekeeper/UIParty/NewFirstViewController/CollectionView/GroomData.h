//
//  GroomData.h
//  DongDong
//
//  Created by BY on 2017/3/14.
//  Copyright © 2017年 BestLife. All rights reserved.

#import <UIKit/UIKit.h>

@class GroomData;

@interface GroomData : NSObject
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int loveCount;

+ (GroomData *)unPacketData:(NSDictionary *)aDict;
@end
