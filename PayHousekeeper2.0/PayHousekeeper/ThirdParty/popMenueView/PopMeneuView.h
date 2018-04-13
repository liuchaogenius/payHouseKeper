//
//  PopMeneuView.h
//  PayHousekeeper
//
//  Created by 1 on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopMeneuView : UIView

- (void)showPopMenue:(UIView *)aInview titles:(NSArray<NSString *> *)dataArry clickItem:(void(^)(int aClickIndex))aBlock;

@end
