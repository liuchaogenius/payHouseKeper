//
//  VideoChatBottomView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "VideoChatBottomView.h"

#define BtnWidth 40
#define BtnTag   30000

@implementation VideoChatBottomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSArray *arr = @[@"dressupBtn",@"likeBtn",@"giftBtn",@"countBtn",@"switchCameraBtn"];
        UIButton *btn;
        NSInteger count = arr.count;
        float fx = (frame.size.width-40-BtnWidth*count)/4.0;
        for(int i = 0; i < count; i++)
        {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(20+(fx+BtnWidth)*i, (frame.size.height-BtnWidth)/2.0, BtnWidth, BtnWidth);
            [btn setBackgroundImage:[UIImage imageNamed:arr[i]] forState:UIControlStateNormal];
            [self addSubview:btn];
            btn.tag = i+BtnTag;
            btn.exclusiveTouch = YES;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            if(i == 3)
            {
                self.countBtn = btn;
            }
        }
        
        _durationLabel = [self labelWithFrame:CGRectMake(20+(fx+BtnWidth)*3, (frame.size.height-BtnWidth)/2.0, BtnWidth, BtnWidth) text:@"" textFont:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self addSubview:_durationLabel];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.hidden = YES;
        
        _countImg = [[UIImageView alloc] initWithFrame:_durationLabel.frame];
        [self addSubview:_countImg];
        _countImg.image = [UIImage imageNamed:@"clockwise"];
        _countImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)btnClick:(UIButton *)btn
{
    if(_clickBlock)
    {
        _clickBlock((int)btn.tag - BtnTag);
    }
}
@end
