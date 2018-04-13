//
//  ExchangeDBDataList.h
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExchangeDBData : NSObject
@property (nonatomic) NSString *dataId;
@property (nonatomic) NSString *shellCount;//咚果
@property (nonatomic) NSString *moneyCount; //咚币
@end


@interface ExchangeDBDataList : NSObject
@property (nonatomic)NSMutableArray<ExchangeDBData*> *dataList;
- (void)unPacketDatalist:(NSArray<NSDictionary *> *)aDictArry;
@end
