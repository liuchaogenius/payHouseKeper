//
//  MQLoginViewController.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MQLoginViewController : BaseViewController
@property (nonatomic, copy)void(^closeWindowItemBlock)(BOOL isClose);

@end
