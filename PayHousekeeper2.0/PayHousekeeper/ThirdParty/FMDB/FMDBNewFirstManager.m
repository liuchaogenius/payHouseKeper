//
//  FMDBNewFirstManager.m
//  PayHousekeeper
//
//  Created by BY on 2017/3/3.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "FMDBNewFirstManager.h"
#import "FMDB.h"

@implementation FMDBNewFirstManager

static FMDatabaseQueue *_queue;

+ (void)initialize
{
    
    NSString *path = [DocumentPath stringByAppendingPathComponent:@"search.sqlite"];
    
    NSLog(@"path=====%@", path);
    
    // 创建队列，已经做了加锁处理。
    _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    // 创表
     [_queue inDatabase:^(FMDatabase *db) {
         [db executeUpdate:@"create table if not exists t_seachs (id integer primary key autoincrement, userToken text, userId text, dict blob);"];
     }];
}


+ (void)addSearches:(NSArray *)dicArr
{
    for (NSDictionary *dic in dicArr) {
        [self addSearche:dic];
    }
}

+ (void)addSearche:(NSDictionary *)dic
{
    NSString *userToken = [UserInfoData shareUserInfoData].strUserToken;
    NSString *userId = [UserInfoData shareUserInfoData].strUserId;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"insert into t_seachs (userToken, userId, dict) values(?, ?, ?)", userToken, userId, data];
    }];
}

+ (NSArray *)searchesWithPage:(int)page size:(int)size
{
    __block NSMutableArray *dicArr = nil;
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        dicArr = [NSMutableArray array];
        
        NSString *userToken = [UserInfoData shareUserInfoData].strUserToken;
        
        FMResultSet *rs = nil;
        rs = [db executeQuery:@"select * from t_seachs where userToken = ? limit ?, ?;", userToken, @((page - 1) * size), @(size)];
        while (rs.next) {
            NSData *data = [rs dataForColumn:@"dict"];
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            [dicArr addObject:dic];
        }

    }];
    
    return dicArr;
}

@end
