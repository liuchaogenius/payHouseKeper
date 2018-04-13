//
//  PHBaseAnimation.m
//  PayHousekeeper
//
//  Created by striveliu on 16/8/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PHBaseAnimation.h"

@implementation PHBaseAnimation
+ (CABasicAnimation *)getBaseAnimation:(CFTimeInterval)aDuration
                      timeFunctionName:(NSString *)aTimeFunctionName
                           repeatCount:(float)aRepeatCount
                              delegate:(id)aDelegate
{
    int direction = 1;
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * direction];
    rotationAnimation.duration = aDuration;
    rotationAnimation.repeatCount = aRepeatCount;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:aTimeFunctionName];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.delegate = aDelegate;
    rotationAnimation.fillMode = kCAFillModeForwards;
    return rotationAnimation;
}


+ (CABasicAnimation *)customBaseAnimation:(CFTimeInterval)aDuration
                      timeFunctionName:(NSString *)aTimeFunctionName
                           repeatCount:(float)aRepeatCount
                                 delegate:(id)aDelegate
                               startValue:(id)aStartValue
                                 endValue:(id)aEndValue
{
//    int direction = 1;
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.fromValue = aStartValue;
    rotationAnimation.toValue = aEndValue;
    rotationAnimation.duration = aDuration;
    rotationAnimation.repeatCount = aRepeatCount;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:aTimeFunctionName];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.delegate = aDelegate;
    rotationAnimation.fillMode = kCAFillModeForwards;
    return rotationAnimation;
}
@end
