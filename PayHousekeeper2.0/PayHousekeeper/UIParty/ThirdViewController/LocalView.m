//
//  LocalView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "LocalView.h"

#define space 25

@implementation LocalView
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    _isMoving = NO;
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    _isMoving = YES;
//    UITouch *touch = [touches anyObject];
//    
//    CGPoint currentPoint = [touch locationInView:self.superview];
//    CGPoint previousPoint = [touch previousLocationInView:self.superview];
//    CGPoint center = self.center;
//    
//    center.x += (currentPoint.x - previousPoint.x);
//    center.y += (currentPoint.y - previousPoint.y);
//    // 修改当前view的中点(中点改变view的位置就会改变)
//    self.center = center;
//    [self setX:self.x<space?space:self.x];
//    [self setY:self.y<0?0:self.y];
//    [self setRight:self.right>kMainScreenWidth-space?kMainScreenWidth-space:self.right];
//    [self setBottom:self.bottom>(kMainScreenHeight-52)?(kMainScreenHeight-52):self.bottom];
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    _isMoving = NO;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
