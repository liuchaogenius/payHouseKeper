//
//  MQNavigationController.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "MQNavigationController.h"
//#import "AppDelegate.h"
@interface MQNavigationController ()

@end

@implementation MQNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.childViewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
        [DLAPPDELEGATE.newtabr hiddenBottomView];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(self.childViewControllers.count <= 2)
    {
        [DLAPPDELEGATE.newtabr showBottomView];
    }
    return [super popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    //AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [DLAPPDELEGATE.newtabr showBottomView];
    return [super popToRootViewControllerAnimated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
