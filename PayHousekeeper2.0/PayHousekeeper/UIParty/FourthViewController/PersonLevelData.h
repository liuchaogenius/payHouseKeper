//
//  PersonLevelData.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/19.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonLevelData : NSObject
@property (nonatomic, strong) NSString *strLevel;
@property (nonatomic) int iMark; //用户当前分值
@property (nonatomic) int iNextMark;//下一级别分值
@property (nonatomic) int iNeedMark; //下一级别所需分值
@property (nonatomic) int iActiveVal;
@property (nonatomic) int iWealthVal;
@property (nonatomic, strong) NSString *strCharmVal;
@property (nonatomic, strong) NSString *strPercent;
@property (nonatomic, strong) NSString *strUserCode;
- (void)unPacketData:(NSDictionary *)aDict;
@end
