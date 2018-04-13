//
//  BlurSliderView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BlurSliderView.h"

@interface BlurSliderView()
@property (nonatomic, strong) UILabel *valueLab;
@end

@implementation BlurSliderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        _maxImgView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, self.width-2, self.height)];
        _maxImgView.image = IMG(@"maxTrick");
        [self addSubview:_maxImgView];
        
        _minImgView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, self.width-2, self.height)];
        _minImgView.image = IMG(@"minTrick");
        [self addSubview:_minImgView];
        
        _thumbImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-2-2, -2-2, self.width+4+4, self.width+4+4)];
        _thumbImgView.image = IMG(@"thumb");
        [self addSubview:_thumbImgView];
        
        _valueLab = [[UILabel alloc] initWithFrame:CGRectMake(_thumbImgView.x-30, _thumbImgView.y, 30, _thumbImgView.height)];
        _valueLab.backgroundColor = [UIColor clearColor];
        _valueLab.adjustsFontSizeToFitWidth = YES;
        _valueLab.text = [NSString stringWithFormat:@"%d%%",100];
        _valueLab.textColor = RGBACOLOR(255, 255, 255, 0.9);
        _valueLab.font = kFont11;
        _valueLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_valueLab];
        
//        [self setProcessValue:[[[NSUserDefaults standardUserDefaults] valueForKey:BLURKEY] floatValue]];
    }
    
    return self;
}

- (void)setProcessValue:(CGFloat)value
{
    if(value < 0)
        value = 0;
    
    if(value > 1)
        value = 1;
    
    _precess = value;
//    [[NSUserDefaults standardUserDefaults] setValue:@(value) forKey:BLURKEY];
    _valueLab.text = [NSString stringWithFormat:@"%2d%%",(int)(_precess*100)];
    
    [[GPUImageManager sharedInstance] setBlurFilterValue:_precess*30];
    WeakSelf(self)
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         [weakself.minImgView setY:weakself.height*(1-value)];
                         [weakself.minImgView setHeight:weakself.height*value];
                         [weakself.thumbImgView setY:(weakself.height-12)*(1-value)];
                         [weakself.valueLab setY:weakself.thumbImgView.y];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
