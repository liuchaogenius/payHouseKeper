//
//  FMDBNewFirstManager.h
//  PayHousekeeper
//
//  Created by BY on 2017/3/3.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBNewFirstManager : NSObject

// 缓存一条搜索列表的数据
+ (void)addSearche:(NSDictionary *)dic;


// 缓存多条搜索列表的数据 
+ (void)addSearches:(NSArray *)dicArr;

+ (NSArray *)searchesWithPage:(int)page size:(int)size;
@end
