//
//  NewFirstData.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "NewFirstData.h"
#import "NewFirstVCTableviewCell.h" // 为了获得 NewFirstVCCellData


@implementation NewFirstData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datalist = [NSMutableArray arrayWithCapacity:0];
        
    }
    return self;
}

+ (NewFirstData *)newFirstData
{
    static dispatch_once_t onceToken;
    static NewFirstData *newFirsData;
    dispatch_once(&onceToken, ^{
        newFirsData = [[NewFirstData alloc] init];
    });
    return newFirsData;
}

- (void)unPacketSearchData:(NSArray *)aDict
{

    if(aDict && aDict.count>0)
    {
        [self.datalist removeAllObjects];
        
        for(NSDictionary *dict in aDict)
        {

            NewFirstVCCellData *data = [[NewFirstVCCellData alloc] init];
            [data unPacketData:dict];
            [self.datalist addObject:data];

        }
    }
    

}

@end
