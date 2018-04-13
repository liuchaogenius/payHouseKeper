//
//  FactoryModel.m
//  YHB_Prj
//
//  Created by  striveliu on 14/12/3.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "FactoryModel.h"


//#import "FifthViewController.h"
@interface FactoryModel()
{
    UIViewController *vc1;
    UIViewController *vc2;
    UIViewController *vc3;
//    UIViewController *vc4;
//    UIViewController *vc5;
}
@end
@implementation FactoryModel
+ (FactoryModel *)shareFactoryModel
{
    static FactoryModel *factoryModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(factoryModel == nil)
        {
            factoryModel = [[FactoryModel alloc] init];
        }
    });
    return factoryModel;
}

- (NSArray *)getTabbarArrys
{
    vc1 = [self getFirstViewController];
    vc2 = [self getSecondViewController];
    vc3 = [self getThirdViewController];
//    vc4 = [self getFourthViewController];
    NSArray *arry = @[vc1,vc2,vc3];
    return arry;
}

- (UIViewController *)getFirstViewController
{
    if(!vc1)
    {
        vc1 = [[NewFirstViewController alloc] init];
    }
    return vc1;
}

- (UIViewController *)getSecondViewController
{
    if(!vc2)
    {
        vc2 = [[NewRootViewController alloc] init];
    }
    return vc2;
}
- (UIViewController *)getThirdViewController
{
    if(!vc3)
    {
        vc3 = [[ThirdViewController alloc] init];
    }
    return vc3;
}

- (void)refreshNewRootUserHead
{
    NewRootViewController *rootvc = (NewRootViewController *)vc2;
    [rootvc refreshHeadView];
}
//- (UIViewController *)getFourthViewController
//{
//    if(!vc4)
//    {
//        vc4 = [[FourthViewController alloc] init];
//    }
//    return vc4;
//}

//- (UIViewController *)getFifthViewController
//{
//    if(!vc5)
//    {
//        vc5 = [[FifthViewController alloc] init];
//    }
//    return vc5;
//}
//- (UIViewController *)getloginViewController
//{
//    return nil;
//}
@end
