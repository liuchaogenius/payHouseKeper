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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef enum _FTAnimationDirection {
  kFTAnimationTop = 0,
  kFTAnimationRight,
  kFTAnimationBottom,
  kFTAnimationLeft,
  kFTAnimationTopLeft,
  kFTAnimationTopRight,
  kFTAnimationBottomLeft,
  kFTAnimationBottomRight
} FTAnimationDirection;

#pragma mark String Constants

extern NSString *const kFTAnimationName;
extern NSString *const kFTAnimationType;
extern NSString *const kFTAnimationTypeIn;
extern NSString *const kFTAnimationTypeOut;

extern NSString *const kFTAnimationSlideIn;
extern NSString *const kFTAnimationSlideOut;
extern NSString *const kFTAnimationBackOut;
extern NSString *const kFTAnimationBackIn;
extern NSString *const kFTAnimationFadeOut;
extern NSString *const kFTAnimationFadeIn;
extern NSString *const kFTAnimationFadeBackgroundOut;
extern NSString *const kFTAnimationFadeBackgroundIn;
extern NSString *const kFTAnimationPopIn;
extern NSString *const kFTAnimationPopInWithHeartbeat;
extern NSString *const kFTAnimationPopOut;
extern NSString *const kFTAnimationFallIn;
extern NSString *const kFTAnimationFallOut;
extern NSString *const kFTAnimationFlyOut;

extern NSString *const kFTAnimationTargetViewKey;

#pragma mark Inline Functions

@interface FTAnimationManager : NSObject {
@private
  CGFloat overshootThreshold_;
}

/**
 The maximum value (in points) that the bouncing animations will travel past their
 end value before coming to rest. The default is 10.0.
*/
@property(assign) CGFloat overshootThreshold;

///---------------------------------------------------------------------------
/// @name Accessing the animation manager
///---------------------------------------------------------------------------
/**
 Get a reference to the FTAnimationManager singleton creating it if necessary.

 @return The singleton.
*/
+ (FTAnimationManager *)sharedManager;

///---------------------------------------------------------------------------
/// @name Controlling animation timing
///---------------------------------------------------------------------------

- (CAAnimation *)popInWithHeartbeatAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

/**
 Pops a view in from offscreen
*/
- (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

/**
 Pops a view offscreen
*/
- (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;


@end


