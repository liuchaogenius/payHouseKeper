//
//  BlurSliderView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurSliderView : UIView
@property (strong, nonatomic) UIImageView *minImgView;
@property (strong, nonatomic) UIImageView *maxImgView;
@property (strong, nonatomic) UIImageView *thumbImgView;
@property (assign, nonatomic) CGFloat     precess;

- (void)setProcessValue:(CGFloat)value;
@end
