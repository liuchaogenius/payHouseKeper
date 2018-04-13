//
//  LoginWindow.h
//  YHB_Prj
//
//  Created by  striveliu on 16/1/21.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWindow : NSObject
+ (LoginWindow *)showLoginview;
@property (nonatomic, copy)void(^closeWindowItemBlock)(BOOL isClose);
- (void)showAdditionaPersonInfovc;
- (void)showtopVc;

- (UINavigationController *)loginRootNav;
@end
