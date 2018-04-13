//
//  CirqueView.m
//  CirqueView
//
//  Created by chenghao on 2017/2/5.
//  Copyright © 2017年 clearcdm.com. All rights reserved.
//

#import "CirqueView.h"
@implementation CirqueView
{
    UILabel* _statsCount;
    CGFloat _totle;
}


- (instancetype)initCirqueViewWithFrame:(CGRect)frame andDatas:(NSArray*)datas
{
    if (self = [super initWithFrame:frame]) {
        _totle = 0.0;
        for (int i = 0; i < datas.count; i++) {
            NSString *count = datas[i];
            _totle = _totle + [count floatValue];
        }
        [self createPieView:datas];
    }
    return self;
    
}

- (void)createPieView:(NSArray*)datas
{
    NSArray* colors = @[RGBCOLOR(246, 194, 51), RGBCOLOR(255, 133, 161), RGBCOLOR(232, 179, 115)];
    
    CGFloat start = 0.0 ;
    CGFloat end;
    for (int i = 0; i<datas.count; i++) {
        NSString* count = datas[i];
        end = [count floatValue] / _totle+start;
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.strokeStart = start;
        circleLayer.strokeEnd = end;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        circleLayer.path = circlePath.CGPath;
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.lineWidth = 10.0f; // 环宽度
        UIColor* color = colors[i];
        circleLayer.strokeColor = color.CGColor;
        [self.layer addSublayer:circleLayer];
        CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnima.fromValue = @(start); //开始动画位置
        pathAnima.toValue = @(end); //结束动画位置
        pathAnima.autoreverses = NO;
        pathAnima.duration = 1.0;
        pathAnima.removedOnCompletion=NO;
        [circleLayer addAnimation:pathAnima forKey:@"strokeEnd"];
        start = end;
    }
    
}
@end
