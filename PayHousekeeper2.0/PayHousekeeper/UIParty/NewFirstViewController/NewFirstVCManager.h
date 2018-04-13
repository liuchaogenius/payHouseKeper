//
//  NewFirstVCManager.h
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewFirstData;

@interface NewFirstVCManager : NSObject

// 获取搜索列表信息
- (void)requestWithStrUserId:(NSString *)userId Page:(int)page size:(int)size searchDataCompleteBloock:(void(^)(NewFirstData *))searchData;

+ (NewFirstVCManager *)newFirstInstance;

@end
