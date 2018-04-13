//
//  BindCrashAccountData.h
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/11.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BindCrashAccountData : NSObject
@property(nonatomic, strong) NSString *strAccount;
@property(nonatomic, strong) NSString *strAccountName;
@property(nonatomic, strong) NSString *strgivePercent;
@property(nonatomic) CGFloat givePercent;
@property(nonatomic) CGFloat cashRate;
- (void)unPackeData:(NSDictionary *)aDict;
@end
