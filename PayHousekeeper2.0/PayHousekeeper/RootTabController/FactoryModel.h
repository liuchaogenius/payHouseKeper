//
//  FactoryModel.h
//  YHB_Prj
//
//  Created by  striveliu on 14/12/3.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewRootViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "NewFirstViewController.h"
@class UIViewController;
@interface FactoryModel : NSObject
+ (FactoryModel *)shareFactoryModel;
- (NSArray *)getTabbarArrys;
- (UIViewController *)getFirstViewController;
- (UIViewController *)getSecondViewController;
- (UIViewController *)getThirdViewController;
- (void)refreshNewRootUserHead;
//- (void)refreshNewFirstVCHeadView;
//- (UIViewController *)getFourthViewController;
//- (UIViewController *)getloginViewController;
@end
