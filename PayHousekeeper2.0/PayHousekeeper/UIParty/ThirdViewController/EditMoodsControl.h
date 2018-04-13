//
//  EditMoodsControl.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/13.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EndEditMoods)(NSString *string);

@interface EditMoodsControl : UIControl
@property (copy)        EndEditMoods endEditMoods;

+ (EditMoodsControl *)sharedInstance;
- (void)setMood:(NSString *)mood;
- (void)show;

- (void)dismiss;


@end
