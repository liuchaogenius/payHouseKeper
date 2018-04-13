//
//  ToolsViewControl.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectValue)(NSInteger index);

@interface ToolsViewControl : UIControl

@property (copy)        SelectValue selectValue;


- (void)show;

- (void)dismiss;
@end
