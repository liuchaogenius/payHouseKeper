//
//  PHBaseAnimation.h
//  PayHousekeeper
//
//  Created by striveliu on 16/8/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHBaseAnimation : NSObject

/**
 *  转圈的动画 transform.rotation.z
 *
 *  @param aDuration         每旋转一圈的时间
 *  @param aTimeFunctionName 动画的方式 eg：kCAMediaTimingFunctionEaseOut
 *  @param aRepeatCount      动画重复次数
 *  @param aDelegate         CAAnimationDelegate 回调
 *
 *  @return 返回动画
 */
+ (CABasicAnimation *)getBaseAnimation:(CFTimeInterval)aDuration
                      timeFunctionName:(NSString *)aTimeFunctionName
                           repeatCount:(float)aRepeatCount
                              delegate:(id)aDelegate;

+ (CABasicAnimation *)customBaseAnimation:(CFTimeInterval)aDuration
                         timeFunctionName:(NSString *)aTimeFunctionName
                              repeatCount:(float)aRepeatCount
                                 delegate:(id)aDelegate
                               startValue:(id)aStartValue
                                 endValue:(id)aEndValue;
@end
