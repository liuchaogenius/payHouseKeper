//
//  RootTabBarController.h
//  Hubanghu
//
//  Created by  striveliu on 14-10-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootTabBarController : UITabBarController<UITabBarControllerDelegate,UITabBarDelegate>
- (void)setSelectTabBarViewController:(int)aIndex;
- (void)refreshNewRootUserHead;
- (UINavigationController *)getNavController;
@end
