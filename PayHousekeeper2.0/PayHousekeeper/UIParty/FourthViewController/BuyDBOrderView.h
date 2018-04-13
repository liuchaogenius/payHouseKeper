//
//  BuyDBOrderView.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/19.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    buttonItem_close,
    buttonItem_wxPay,
    buttonItem_aliPay,
    buttonItem_applePay,
    buttonItem_ok
}ButtonClickTag;

@interface BuyDBOrderView : UIView

- (void)setBGColor:(UIColor *)aColor alpha:(CGFloat)aAlpha;
//- (void)createOrderview:(NSString *)aShellCount clickBlock:(void(^)(int buttonTag,NSString *convcount))aBlock;
- (void)createChongzhiView:(NSString *)aBuyValue clickBlock:(void(^)(int index))aClickBlock;
- (void)createChongzhiView:(NSString *)aBuyValue  containsApplePay:(BOOL)contains clickBlock:(void(^)(int index))aClickBlock;

- (void)setConvRule:(CGFloat)aRule;

@end
