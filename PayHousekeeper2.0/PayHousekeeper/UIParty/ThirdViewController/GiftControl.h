//
//  GiftControl.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiftModel.h"

typedef void (^PresentGift)(GiftModel *gift);
typedef void (^GoToPayVC)();

@interface GiftControl : UIControl
@property (copy)        PresentGift presentGiftBlock;
@property (copy)        GoToPayVC gotoVCBlock;

- (void)initGiftssView:(NSMutableArray *)giftArr;

- (void)show;

- (void)dismiss;
@end
