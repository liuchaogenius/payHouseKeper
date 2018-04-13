//
//  BlurControlView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlurSliderView.h"

typedef void (^TouchMoving)(BOOL isMoving);

@interface BlurControlView : UIView
@property (nonatomic, strong) BlurSliderView *blurSliderView;
@property (copy) TouchMoving movingBlock;
- (void)initHideTimer;
- (void)setProcessValue:(float)value;

- (void)showAndHideSlider;

@end
