//
//  BindCashAccontViewController.h
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "BaseViewController.h"

@interface BindCashAccontViewController : BaseViewController
- (void)setAccount:(NSString *)aAccount name:(NSString *)aName;
- (void)getAccount:(void(^)(NSString *account, NSString *name))aBlock;
@end
