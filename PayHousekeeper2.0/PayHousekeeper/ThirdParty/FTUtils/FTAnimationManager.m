/*
 The MIT License
 
 Copyright (c) 2009 Free Time Studios and Nathan Eror
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import "FTAnimationManager.h"
#import "FTUtils.h"
#import "FTUtils+NSObject.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

NSString *const kFTAnimationName = @"kFTAnimationName";
NSString *const kFTAnimationType = @"kFTAnimationType";
NSString *const kFTAnimationTypeIn = @"kFTAnimationTypeIn";
NSString *const kFTAnimationTypeOut = @"kFTAnimationTypeOut";

NSString *const kFTAnimationSlideOut = @"kFTAnimationNameSlideOut";
NSString *const kFTAnimationSlideIn = @"kFTAnimationNameSlideIn";
NSString *const kFTAnimationBackOut = @"kFTAnimationNameBackOut";
NSString *const kFTAnimationBackIn = @"kFTAnimationNameBackIn";
NSString *const kFTAnimationFadeOut = @"kFTAnimationFadeOut";
NSString *const kFTAnimationFadeIn = @"kFTAnimationFadeIn";
NSString *const kFTAnimationFadeBackgroundOut = @"kFTAnimationFadeBackgroundOut";
NSString *const kFTAnimationFadeBackgroundIn = @"kFTAnimationFadeBackgroundIn";
NSString *const kFTAnimationPopIn = @"kFTAnimationPopIn";
NSString *const kFTAnimationPopInWithHeartbeat = @"kFTAnimationPopInWithHeartbeat";
NSString *const kFTAnimationPopOut = @"kFTAnimationPopOut";
NSString *const kFTAnimationFallIn = @"kFTAnimationFallIn";
NSString *const kFTAnimationFallOut = @"kFTAnimationFallOut";
NSString *const kFTAnimationFlyOut = @"kFTAnimationFlyOut";

NSString *const kFTAnimationCallerDelegateKey = @"kFTAnimationCallerDelegateKey";
NSString *const kFTAnimationCallerStartSelectorKey = @"kFTAnimationCallerStartSelectorKey";
NSString *const kFTAnimationCallerStopSelectorKey = @"kFTAnimationCallerStopSelectorKey";
NSString *const kFTAnimationTargetViewKey = @"kFTAnimationTargetViewKey";
NSString *const kFTAnimationIsChainedKey = @"kFTAnimationIsChainedKey";
NSString *const kFTAnimationNextAnimationKey = @"kFTAnimationNextAnimationKey";
NSString *const kFTAnimationPrevAnimationKey = @"kFTAnimationPrevAnimationKey";
NSString *const kFTAnimationWasInteractionEnabledKey = @"kFTAnimationWasInteractionEnabledKey";

@interface FTAnimationManager ()

//- (CGPoint)overshootPointFor:(CGPoint)point withDirection:(FTAnimationDirection)direction threshold:(CGFloat)threshold;

@end


@implementation FTAnimationManager

#pragma mark -
#pragma mark Utility Methods

- (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
                               duration:(NSTimeInterval)duration delegate:(id)delegate 
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector
                                   name:(NSString *)name type:(NSString *)type {
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = [NSArray arrayWithArray:animations];
  group.delegate = self;
  group.duration = duration;
  group.removedOnCompletion = NO;
  if([type isEqualToString:kFTAnimationTypeOut]) {
    group.fillMode = kCAFillModeBoth;
  }
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [group setValue:view forKey:kFTAnimationTargetViewKey];
  [group setValue:delegate forKey:kFTAnimationCallerDelegateKey];
  if(!startSelector) {
    startSelector = @selector(animationDidStart:);
  }
  [group setValue:NSStringFromSelector(startSelector) forKey:kFTAnimationCallerStartSelectorKey];
  if(!stopSelector) {
    stopSelector = @selector(animationDidStop:finished:);
  }
  [group setValue:NSStringFromSelector(stopSelector) forKey:kFTAnimationCallerStopSelectorKey];
  [group setValue:name forKey:kFTAnimationName];
  [group setValue:type forKey:kFTAnimationType];
  return group;
}


#pragma mark -
#pragma mark Popin Heartbeat

- (CAAnimation *)popInWithHeartbeatAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.2, @0.6, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    
    CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObjects: animation, nil] withView:view        duration:duration delegate:delegate startSelector:startSelector stopSelector:stopSelector
                                                 name:kFTAnimationPopInWithHeartbeat type:kFTAnimationTypeIn];
    return group;
}

#pragma mark -
#pragma mark Pop Animation Builders

- (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
    
    
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    
//    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
//                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
//                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
//    animation.keyTimes = @[ @0, @0.5, @1 ];
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;
//    animation.duration = duration;
    
    
      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
      animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(view.left+view.width/2, view.bottom+view.height/2)];
      animation.toValue = [NSValue valueWithCGPoint:CGPointMake(view.left+view.width/2, view.bottom-view.height/2)];
      animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
      animation.fillMode = kCAFillModeForwards;
    
      CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObjects: animation, nil] withView:view        duration:duration delegate:delegate startSelector:startSelector stopSelector:stopSelector
                                                 name:kFTAnimationPopIn type:kFTAnimationTypeIn];
    
   // group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return group;

}

- (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
    
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    
//    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
//                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
//                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
//    animation.keyTimes = @[ @0, @0.5, @1 ];
//    animation.fillMode = kCAFillModeRemoved;
//    animation.duration = duration;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(view.left+view.width/2, view.bottom-view.height/2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(view.left+view.width/2, view.bottom+view.height/2)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fillMode = kCAFillModeForwards;
    
    return [self animationGroupFor:[NSArray arrayWithObjects:animation, nil] withView:view duration:duration
                          delegate:delegate startSelector:startSelector stopSelector:stopSelector
                              name:kFTAnimationPopOut type:kFTAnimationTypeOut];
}



#pragma mark -
#pragma mark Animation Delegate Methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
  UIView *targetView = [theAnimation valueForKey:kFTAnimationTargetViewKey];
//  [theAnimation setValue:[NSNumber numberWithBool:targetView.userInteractionEnabled] forKey:kFTAnimationWasInteractionEnabledKey];
//  [targetView setUserInteractionEnabled:NO];
  
  if([[theAnimation valueForKey:kFTAnimationType] isEqualToString:kFTAnimationTypeIn]) {
    [targetView setHidden:NO];
  }
  
  //Check for chaining and forward the delegate call if necessary
  NSObject *callerDelegate = [theAnimation valueForKey:kFTAnimationCallerDelegateKey];
  SEL startSelector = NSSelectorFromString([theAnimation valueForKey:kFTAnimationCallerStartSelectorKey]);
  
  FT_CALL_DELEGATE_WITH_ARG(callerDelegate, startSelector, theAnimation)
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
  UIView *targetView = [theAnimation valueForKey:kFTAnimationTargetViewKey];
//  BOOL wasInteractionEnabled = [[theAnimation valueForKey:kFTAnimationWasInteractionEnabledKey] boolValue];
//  [targetView setUserInteractionEnabled:wasInteractionEnabled];
  
  if([[theAnimation valueForKey:kFTAnimationType] isEqualToString:kFTAnimationTypeOut]) {
    [targetView setHidden:YES];
  }
  [targetView.layer removeAnimationForKey:[theAnimation valueForKey:kFTAnimationName]];
  
  //Forward the delegate call
  id callerDelegate = [theAnimation valueForKey:kFTAnimationCallerDelegateKey];
  SEL stopSelector = NSSelectorFromString([theAnimation valueForKey:kFTAnimationCallerStopSelectorKey]);
  
  if([theAnimation valueForKey:kFTAnimationIsChainedKey]) {
    CAAnimation *next = [theAnimation valueForKey:kFTAnimationNextAnimationKey];
    if(next) {
      //Add the next animation to its layer
      UIView *nextTarget = [next valueForKey:kFTAnimationTargetViewKey];
      [nextTarget.layer addAnimation:next forKey:[next valueForKey:kFTAnimationName]];
    }
  }
  
  void *arguments[] = { &theAnimation, &finished };
  [callerDelegate performSelectorIfExists:stopSelector withArguments:arguments];
}

#pragma mark Singleton

static FTAnimationManager *sharedAnimationManager = nil;

+ (FTAnimationManager *)sharedManager {
  @synchronized(self) {
    if (sharedAnimationManager == nil) {
      sharedAnimationManager = [[self alloc] init];
    }
  }
  return sharedAnimationManager;
}

- (id)init {
  self = [super init];
  if (self != nil) {
    overshootThreshold_ = 10.f;
  }
  return self;
}

@end



