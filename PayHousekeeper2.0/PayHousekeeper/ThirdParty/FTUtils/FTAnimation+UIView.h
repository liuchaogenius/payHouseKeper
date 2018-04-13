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

/**
 This category provides extra methods on `UIView` which make it very easy to use
 the FTAnimationManager pre-built animations.
*/
@interface UIView (FTAnimationAdditions)

///---------------------------------------------------------------------------
/// @name Sliding the view on and off the screen
///---------------------------------------------------------------------------

//带有心跳的弹出动画
- (void)popInWithHeartbeat:(NSTimeInterval)duration delegate:(id)delegate;


//带有心跳的弹出动画
- (void)popInWithHeartbeat:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

/** 
 Pops the view in from the center of the screen similar to the animation of a `UIAlertView`. 
 The view will start invisible and small in the center of the screen, and it will be animated
 to its final size with a rubber band bounce at the end.
*/
- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate;

/** 
 Pops the view in from the center of the screen similar to the animation of a `UIAlertView`. 
 The view will start invisible and small in the center of the screen, and it will be animated
 to its final size with a rubber band bounce at the end.
*/
- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

/** 
 This is the reverse of the *popIn* animation. The view will scale to a slightly larger size
 before shrinking to nothing in the middle of the screen.
*/
- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate;

/** 
 This is the reverse of the *popIn* animation. The view will scale to a slightly larger size
 before shrinking to nothing in the middle of the screen.
*/
- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;


@end
