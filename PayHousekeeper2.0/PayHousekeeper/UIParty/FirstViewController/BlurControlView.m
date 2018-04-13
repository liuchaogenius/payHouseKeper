//
//  BlurControlView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BlurControlView.h"
#import "AppDelegate.h"

#define heightTag 40

@interface BlurControlView()
{
    NSTimer *timer;
}
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGFloat startVB;

@end
@implementation BlurControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initHideTimer
{
    [self stopTimer];

    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideBlurSlider) userInfo:nil repeats:NO];
}

- (void)hideBlurSlider
{
    [self stopTimer];
    WeakSelf(self)
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         weakself.blurSliderView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         weakself.blurSliderView.hidden = YES;
                         weakself.blurSliderView.alpha = 1;
                     }];
}

- (void)stopTimer
{
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _blurSliderView = [[BlurSliderView alloc] initWithFrame:CGRectMake(9, 0, 4, self.height)];
        _blurSliderView.backgroundColor = [UIColor clearColor];
        [self addSubview:_blurSliderView];
        _blurSliderView.hidden = YES;
    }
    
    return self;
}

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_movingBlock)
        _movingBlock(YES);
    [self stopTimer];
    _blurSliderView.hidden = NO;
//    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    _startPoint = [touch locationInView:self];
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [self stopTimer];
    _blurSliderView.hidden = NO;
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    
    CGPoint panPoint = CGPointMake(currentP.x - _startPoint.x, currentP.y - _startPoint.y);
//    if (fabs(panPoint.y))// >= self.height/10.0)
    {
        _startPoint = currentP;
        [_blurSliderView setProcessValue:_blurSliderView.precess - (panPoint.y>0?fabs(panPoint.y)/self.height:-fabs(panPoint.y)/self.height)];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_movingBlock)
        _movingBlock(NO);
    [self initHideTimer];
}

- (void)setProcessValue:(float)value
{
    [_blurSliderView setProcessValue:value];
}

- (void)showAndHideSlider
{
    [self stopTimer];
    _blurSliderView.hidden = !_blurSliderView.hidden;
    if(!_blurSliderView.hidden)
    {
        [self initHideTimer];
    }
}

- (void)dealloc
{
    NSString *str = [NSString stringWithFormat:@"%@ dealloc",[NSString stringWithUTF8String:object_getClassName(self)]];
    NSLog(@"%@",str);
}

@end
