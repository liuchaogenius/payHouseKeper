//
//  NewRootTabBar.h
//  PayHousekeeper
//
//  Created by 1 on 2017/2/16.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRootTabBar : UIViewController

- (void)setSelectTabBarViewController:(int)aIndex;
- (void)refreshNewRootUserHead;
- (UINavigationController *)getCurrentNavController;

- (void)hiddenBottomView;

- (void)showBottomView;

- (void)hiddenMatchBtns;
@end
