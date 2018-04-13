//
//  WaveView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2017/1/19.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "WaveView.h"

@interface WaveView ()
@property (nonatomic,strong)WaveProgress *view1;
@property (nonatomic,strong)WaveProgress *view2;
@property (nonatomic,strong)WaveProgress *view3;
@end

@implementation WaveView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _view1 = [[WaveProgress alloc] initWithFrame:self.bounds];
        _view1.waveHeight = 12;
        _view1.speed = 2.0;
        _view1.waveColor = RGBACOLOR(182, 56, 62, 0.1);
        [self addSubview:_view1];
        _view1.transform = CGAffineTransformScale(_view1.transform, 1.0, -1.0);
        
        _view2 = [[WaveProgress alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-20)];
        _view2.waveHeight = 9;
        _view2.speed = 3.0;
        _view2.waveColor = RGBACOLOR(188, 225, 13, 0.1);
        [self addSubview:_view2];
        _view2.transform = CGAffineTransformScale(_view2.transform, 1.0, -1.0);
        
        _view3 = [[WaveProgress alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-30)];
        _view3.waveHeight = 6;
        _view3.speed = 4.0;
        _view3.waveColor = RGBACOLOR(57, 35, 221, 0.1);
        [self addSubview:_view3];
        _view3.transform = CGAffineTransformScale(_view3.transform, 1.0, -1.0);
    }
    return self;
}

- (void)startAnimation
{
    [self stopAnimation];
    [_view1 setProgress:0.9];
    [_view2 setProgress:0.8];
    [_view3 setProgress:0.7];
}

- (void)stopAnimation
{
    [_view1 stopWaveAnimation];
    [_view2 stopWaveAnimation];
    [_view3 stopWaveAnimation];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface WaveProgress ()
@property (nonatomic,assign)CGFloat yHeight;            //当前进度对应的y值,由于y是向下递增,所以要注意
@property (nonatomic,assign)CGFloat offset;             //偏移量,决定了这个点在y轴上的位置,以此来实现动态效果
@property (nonatomic,strong)CADisplayLink * link;       //定时器
@property (nonatomic,strong)CAShapeLayer * waveLayer;   //水波的layer
@end

@implementation WaveProgress

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.waveHeight = 5.0;
        self.waveColor = [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.3];
        self.yHeight = self.bounds.size.height;
        self.waveLayer = [CAShapeLayer layer];
        self.waveLayer.frame = self.bounds;
        self.waveLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:self.waveLayer];
    }
    return self;
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    //由于y坐标轴的方向是由上向下,逐渐增加的,所以这里对于y坐标进行处理
    self.yHeight = self.bounds.size.height * (1 - progress);
    //先停止动画,然后在开始动画,保证不会有什么冲突和重复.
    [self stopWaveAnimation];
    [self startWaveAnimation];
}

#pragma mark -- 开始波动动画
- (void)startWaveAnimation
{
    //相对于NSTimer CADisplayLink更准确,每一帧调用一次.
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(waveAnimation)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark -- 停止波动动画
- (void)stopWaveAnimation
{
    [self.link invalidate];
    self.link = nil;
}

#pragma mark -- 波动动画实现
- (void)waveAnimation
{
    CGFloat waveHeight = self.waveHeight;
    //如果是0或者1,则不需要wave的高度,否则会看出来一个小的波动.
    if (self.progress == 0.0f || self.progress == 1.0f) {
        waveHeight = 0.f;
    }
    //累加偏移量,这样就可以通过speed来控制波动的速度了.对于正弦函数中的各个参数,你可以通过上面的注释进行了解.
    self.offset += self.speed;
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGFloat startOffY = waveHeight * sinf(self.offset * M_PI * 2 / self.bounds.size.width);
    CGFloat orignOffY = 0.0;
    CGPathMoveToPoint(pathRef, NULL, 0, startOffY);
    for (CGFloat i = 0.f; i <= self.bounds.size.width; i++) {
        orignOffY = waveHeight * sinf(2 * M_PI / self.bounds.size.width * i + self.offset * M_PI * 2 / self.bounds.size.width) + self.yHeight;
        CGPathAddLineToPoint(pathRef, NULL, i, orignOffY);
    }
    //连接四个角和以及波浪,共同组成水波.
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, orignOffY);
    CGPathAddLineToPoint(pathRef, NULL, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef, NULL, 0, self.bounds.size.height);
    CGPathAddLineToPoint(pathRef, NULL, 0, startOffY);
    CGPathCloseSubpath(pathRef);
    self.waveLayer.path = pathRef;
    self.waveLayer.fillColor = self.waveColor.CGColor;
    CGPathRelease(pathRef);
}

@end
