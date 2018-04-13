//
//  NewFirstVCManager.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "NewFirstVCManager.h"
#import "NetManager.h"
#import "NewFirstData.h"
#import "FMDBNewFirstManager.h"

@interface NewFirstVCManager ()
{
    NewFirstData *nfData;
}
@end

@implementation NewFirstVCManager
//
//#pragma mark 初始化方法
//- (instancetype)init
//{
//    self=[super init];
//    if(self)
//    {
//        nfData = [[NewFirstData alloc] init];
//        
//    }
//    return self;
//}

+ (NewFirstVCManager *)newFirstInstance
{
    static dispatch_once_t onceToken;
    static NewFirstVCManager *newFirstInstance;
    dispatch_once(&onceToken, ^{
        newFirstInstance = [[NewFirstVCManager alloc] init];
    });
    return newFirstInstance;
}

- (void)requestWithStrUserId:(NSString *)userId Page:(int)page size:(int)size searchDataCompleteBloock:(void(^)(NewFirstData *))aBlock
{
//    NSArray *dicArr = [FMDBNewFirstManager searchesWithPage:page size:size];
//    
//    if (dicArr.count) { // 有缓存
//        
//        if (aBlock) {
//            
//            nfData = [[NewFirstData alloc] init];
//            [nfData unPacketSearchData:dicArr];
//            
//            aBlock(nfData);
//        }
//    }
//    else
//    {
        MLOG(@"++++++++ %d", page);
    
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:userId forKey:@"accid"];
        [dict setObject:[NSNumber numberWithInt:page] forKey:@"page"];
        [dict setObject:[NSNumber numberWithInt:size] forKey:@"size"];
        
        NSString *apiName = @"explore/exploreList";
        
        [NetManager requestWith:dict apiName:apiName method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            
            if (page == 1) {
                
                MLOG(@"++++++++ %d", page);
                // 缓存
                [FMDBNewFirstManager addSearches:(NSArray *)successDict];

            }
            
            if(successDict)
            {
                
                nfData = [[NewFirstData alloc] init];
                [nfData unPacketSearchData:(NSArray *)successDict];
                
                
                aBlock(nfData);
                
            }
            else{
                aBlock(nil);
            }
            
            
        } failure:^(NSDictionary *failDict, NSError *error) {
            
        }];
//    }

    
}


@end
