//
//  NewFirstData.h
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewFirstData : NSObject

@property (nonatomic, readonly) NSString *topicId; // 话题ID
@property (nonatomic, readonly) NSString *distributeUrl; // 搭配图
@property (nonatomic, readonly) NSString *contentStr; // 话题内容
@property (nonatomic, readonly) int videoCount; // 视频
@property (nonatomic, readonly) int sharesCount; // 分享

+ (NewFirstData *)newFirstData;
- (void)unPacketSearchData:(NSArray *)aDict;

@property (nonatomic) NSMutableArray *datalist;

@end
