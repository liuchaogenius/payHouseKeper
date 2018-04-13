//
//  WXCameraCoverView.m
//  WXCustomCamera
//
//  Created by wx on 16/7/8.
//  Copyright © 2016年 WX. All rights reserved.
//

#import "WXCameraCoverView.h"
#import "WXHead.h"
@interface WXCameraCoverView()
{
    float roundX;
    float roundY;
    float roundWidth;
}
@end
@implementation WXCameraCoverView
-(id)initWithRoundFrame:(CGRect)theFrame
{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        self.opaque = NO;
        roundWidth = theFrame.size.width;
        roundX = theFrame.origin.x;
        roundY = theFrame.origin.y;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // Get the current graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor( context, WXColorFromRGB(0x0A233C).CGColor );
    CGContextFillRect( context, rect );
    
    CGRect roundRect = CGRectMake(roundX, roundY, roundWidth, roundWidth);
    if( CGRectIntersectsRect( roundRect, rect ) )
    {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor clearColor] set];
        CGContextFillEllipseInRect( context, roundRect);
    }
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    //return (point.y < MIDDLE_Y1 || point.y > MIDDLE_Y2);
    return NO;
}
@end
