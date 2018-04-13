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

#import "FTAnimation+UIView.h"
#import "FTUtils.h"
#import "FTUtils+NSObject.h"

@implementation UIView (FTAnimationAdditions)

//#pragma mark - Sliding Animations


- (void)popInWithHeartbeat:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector
{
    CAAnimation *anim = [[FTAnimationManager sharedManager] popInWithHeartbeatAnimationFor:self duration:duration delegate:delegate startSelector:startSelector stopSelector:stopSelector];
    [self.layer addAnimation:anim forKey:kFTAnimationPopInWithHeartbeat];
}

- (void)popInWithHeartbeat:(NSTimeInterval)duration delegate:(id)delegate
{
    [self popInWithHeartbeat:duration delegate:delegate startSelector:nil stopSelector:nil];
}

#pragma mark - Popping Animations

- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CAAnimation *anim = [[FTAnimationManager sharedManager] popInAnimationFor:self duration:duration delegate:delegate startSelector:startSelector stopSelector:stopSelector];
  [self.layer addAnimation:anim forKey:kFTAnimationPopIn];
}

- (void)popIn:(NSTimeInterval)duration delegate:(id)delegate {
  [self popIn:duration delegate:delegate startSelector:nil stopSelector:nil];
}

- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
  CAAnimation *anim = [[FTAnimationManager sharedManager] popOutAnimationFor:self duration:duration delegate:delegate 
                                                               startSelector:startSelector stopSelector:stopSelector];
  [self.layer addAnimation:anim forKey:kFTAnimationPopOut];
}

- (void)popOut:(NSTimeInterval)duration delegate:(id)delegate {
  [self popOut:duration delegate:delegate startSelector:nil stopSelector:nil];
}



@end
