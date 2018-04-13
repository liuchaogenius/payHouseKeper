//
//  BindNumViewController.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BaseViewController.h"

@interface BindNumViewController : BaseViewController
@property (nonatomic)BOOL isChanagePhonNum;
@property (nonatomic, copy) void (^completeBlock)(NSString * number);
@property (nonatomic, strong)NSString *phoneStr;
- (void)setBindCompleteBlock:(void(^)(NSString * number))aBlock;
@end
