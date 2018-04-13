//
//  ToolsViewControl.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "ToolsViewControl.h"
#import "AppDelegate.h"

#define Scale (kMainScreenWidth/375.0)
#define TypeTagIndex 100
#define PropTagIndex 1000

@interface ToolsViewControl()<UIScrollViewDelegate>

@property(nonatomic, strong)UIView          *bgView;
@property(nonatomic, strong)UIScrollView    *propsSC;
@property(nonatomic, strong)UIPageControl   *pageCtrl;
@property(nonatomic, strong)UIImageView     *maskImg;
@end

@implementation ToolsViewControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init;
{
    self = [super initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    if (self)
    {
        [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [self initToolsView];
    }
    
    return self;
}

- (void)initToolsView
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-kMainScreenWidth/2, kMainScreenWidth, kMainScreenWidth/2)];
    _bgView.backgroundColor = [UIColor clearColor];//RGBACOLOR(0, 0, 0, 0.4);
    [self addSubview:_bgView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0, _bgView.width, _bgView.height);
    [_bgView addSubview:effectview];
    
    //道具
    _propsSC = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _bgView.width, _bgView.height)];
    _propsSC.backgroundColor = _bgView.backgroundColor;
    [_bgView addSubview:_propsSC];
    _propsSC.pagingEnabled = YES;
    _propsSC.delegate = self;
    
    UIButton *btn;
    float height = _propsSC.height/2.0;
    float width = kMainScreenWidth/4.0;//63*Scale;
    int num = 8;
    for(int i = 0; i < num; i++)
    {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.exclusiveTouch = YES;
        btn.frame = CGRectMake(i%4*width+i/8*_bgView.width, i%8/4*height, width, height);
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dressupList%d",i]];
//        btn.frame = CGRectMake(0, 0, image.size.width*image.size.height/height*0.5, height*0.5);
//        btn.center = CGPointMake(i%4*width+i/8*_bgView.width+width/2.0, i%8/4*height+height/2.0);
        [_propsSC addSubview:btn];
        btn.tag = i+PropTagIndex;
        [btn setImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectProp:) forControlEvents:UIControlEventTouchUpInside];
    }
    int page = num/8+(num%8>0?1:0);
    _propsSC.contentSize = CGSizeMake(page*_bgView.width, 0);
    _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _bgView.height-30, _bgView.width, 30)];
    _pageCtrl.numberOfPages = page;
    _pageCtrl.currentPage = 0;
    [_bgView addSubview:_pageCtrl];
    _pageCtrl.hidden = page <= 1;
    
    _maskImg = [[UIImageView alloc] initWithImage:IMG(@"present_list_selector")];
    _maskImg.hidden = [GPUImageManager sharedInstance].dressupIndex == -1;
    [_propsSC addSubview:_maskImg];
    if(!_maskImg.hidden)
    {
        NSInteger i = [GPUImageManager sharedInstance].dressupIndex;
        _maskImg.frame = CGRectMake(i%4*width+i/8*_bgView.width, i%8/4*height, width, height);
    }
}



- (void)show
{
    WeakSelf(self)
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [DLAPPDELEGATE.window addSubview:weakself];
                     } completion:nil];
    
}

- (void)dismiss
{
    WeakSelf(self)
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [weakself removeFromSuperview];
                     } completion:nil];
}

- (void)selectProp:(UIButton *)btn
{
    if(_selectValue)
    {
        _selectValue(btn.tag-PropTagIndex);
    }
    [self dismiss];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
}

@end
