//
//  AlterNicknameVC.h
//  PayHousekeeper
//
//  Created by BY on 17/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//  



#import "BaseViewController.h"

@interface AlterNicknameVC : BaseViewController


- (void)setVCTitle:(NSString *)aTitle
            source:(NSString *)aSource
             block:(void(^)(NSString *aContent))completeBlock;

@end
