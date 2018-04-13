//
//  TitleSegmentView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/14.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "TitleSegmentView.h"

@interface TitleSegmentView ()
{
    UIImageView *bgImgView;
    UIImage *_normalImg,*_selectedImg;
}
@end

@implementation TitleSegmentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithTitleArr:(NSArray *)titleArr normalImage:(UIImage *)normalImg selectedImage:(UIImage *)selectedImg
{
    self = [super init];
    if (self)
    {
        self.frame = CGRectMake(0, 0, 160, 33);
        self.backgroundColor = [UIColor clearColor] ;
        UIButton *btn;
        float width = self.width/2.0;
        int height = self.height;
        _normalImg = [normalImg copy];
        _selectedImg = [selectedImg copy];
        _index = -1;
        
        bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgImgView.image = _selectedImg;
        bgImgView.userInteractionEnabled = YES;
        [self addSubview:bgImgView];
        
        for(int i = 0; i < titleArr.count; i++)
        {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(width*i, 0, width, height);
            btn.tag = 100+i;
            [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            btn.selected = i==0;
            btn.titleLabel.font = kFont14;
            [btn setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
            [btn setTitleColor:kcolorWhite forState:UIControlStateSelected];
            [bgImgView addSubview:btn];
        }
    }
    return self;
}

- (void)titleClick:(UIButton *)btn
{
    if(btn.tag - 100 == _index)
        return;
    
    for(UIButton *b in bgImgView.subviews)
    {
        b.selected = NO;
    }
    btn.selected = YES;
    if(self.clickTitle)
    {
        self.clickTitle((int)btn.tag-100);
    }
    _index = (int)btn.tag-100;
    
    bgImgView.image = _index == 0?_selectedImg:_normalImg;
}

- (void)switchBtn:(int)index
{
    UIButton *btn = (UIButton *)[self viewWithTag:index+100];
    [self titleClick:btn];
}

@end
