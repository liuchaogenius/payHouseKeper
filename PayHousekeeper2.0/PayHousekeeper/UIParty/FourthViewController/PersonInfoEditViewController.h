//
//  PersonInfoEditViewController.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/15.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BaseViewController.h"

@interface PersonInfoEditViewController : BaseViewController


- (void)setVCTitle:(NSString *)aTitle
            source:(NSString *)aSource
             block:(void(^)(NSString *aContent))completeBlock;

@end
