//
//  FindSliderView.m
//  DongDong
//
//  Created by BY on 2017/3/13.
//  Copyright © 2017年 BestLife. All rights reserved.
//

#import "SegmentedView.h"

@implementation NoHighlightButton
- (void)setHighlighted:(BOOL)highlighted {}
@end

@interface SegmentedView ()
@property (nonatomic, strong)NSMutableArray *btnArr;
@end

@implementation SegmentedView

- (instancetype)initWithTitleArr:(NSArray *)titleArr
{
    self = [super init];
    if (self) {
        
        if (titleArr) {
            self.btnArr = [NSMutableArray array];
            
            for (int i = 0; i < titleArr.count; i++) {
                NoHighlightButton *btn = [[NoHighlightButton alloc] init];
                btn.tag = i;
                if (i == 0) {
                    btn.selected = YES;
                }
                [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
                btn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [btn setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                [btn setTitleColor:kFcolorFontGreen forState:UIControlStateSelected];
                [btn setTitle:titleArr[i] forState:UIControlStateNormal];
                [self addSubview:btn];
                
                [self.btnArr addObject:btn];
            }
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat W = 50;
    CGFloat gap = (self.width - self.btnArr.count * W) / self.btnArr.count;
    
    for (int i = 0; i < self.btnArr.count; i++) {
        NoHighlightButton *btn = self.btnArr[i];
        btn.frame = CGRectMake(i * (W + gap), 0, W, self.height);
    }
}

/**
 *  监听按钮点击
 */
- (void)buttonClick:(NoHighlightButton *)button
{
    // 1.通知代理
    if ([self.delegate respondsToSelector:@selector(segmentedViewDidClickedPlusButton:)]) {
        [self.delegate segmentedViewDidClickedPlusButton:(NSInteger)button.tag];
    }
    
    for (NoHighlightButton *btn in self.btnArr) {
        btn.selected = NO;
    }
    
    button.selected = YES;
}

@end
