//
//  GoMatchVCTransition.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "GoMatchVCTransition.h"

@interface GoMatchVCTransition()

@property(nonatomic,strong)id<UIViewControllerContextTransitioning>transitionContext;
@property(nonatomic,strong) UIImageView *imgView;
@end

@implementation GoMatchVCTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    if (self.isPush)
    {
        [self startPushAnimation];
    }
    else
    {
        [self startPopAnimation];
    }
}

- (void)startPopAnimation
{
    WeakSelf(self)
    UIView *contentView = [self.transitionContext containerView];
    UIViewController *toVc = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    float width = 100 * kScale;
    float height = 140 * kScale;
   
//    UIView *view = [self bgView];
    self.imgView.image = [[GPUImageManager sharedInstance] getCurrentImage];
    self.imgView.frame = CGRectMake(kMainScreenWidth-width-12, kMainScreenHeight-height-67.5, width, height);
    [contentView addSubview:self.imgView];
    
//    GPUImageView *gpuView = [GPUImageManager sharedInstance].localPreviewView;
//    [view insertSubview:gpuView atIndex:0];
//    [[GPUImageManager sharedInstance] adjustBounds];
    
//    self.imgView.transform = CGAffineTransformMakeScale(width/kMainScreenWidth, height/kMainScreenHeight);
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
//    [UIView setAnimationDuration:1.0f];//动画时间
//    self.imgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//    [UIView commitAnimations]; //启动动画
    
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         weakself.imgView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
//                         [[GPUImageManager sharedInstance] adjustBounds];
                     }
                     completion:^(BOOL finished) {
                         [weakself.imgView removeFromSuperview];
                         [contentView addSubview:toVc.view];
                         [weakself.transitionContext completeTransition:YES];
                         [weakself.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
                         [weakself.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
                     }];
}

- (void)startPushAnimation
{
    WeakSelf(self)
    UIView *contentView = [self.transitionContext containerView];
    UIViewController* toVc = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVc.view.frame = contentView.bounds;
    [contentView addSubview:toVc.view];
    
    float width = 100*kScale;
    float height = 140*kScale;
    
//    UIView *view = [self bgView];
    self.imgView.frame = [UIScreen mainScreen].bounds;
    self.imgView.image = [[GPUImageManager sharedInstance] getCurrentImage];
    [contentView addSubview:self.imgView];
    
//    GPUImageView *gpuView = [GPUImageManager sharedInstance].localPreviewView;
//    [view insertSubview:gpuView atIndex:0];
    
//    self.imgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);//将要显示的view按照正常比例显示出来
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
//    [UIView setAnimationDuration:1.0f];//动画时间
//    self.imgView.transform=CGAffineTransformMakeScale(width/kMainScreenWidth, height/kMainScreenHeight);//先让要显示的view最小直至消失
//    [UIView commitAnimations]; //启动动画
    
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         weakself.imgView.frame = CGRectMake(kMainScreenWidth-width-12, kMainScreenHeight-height-67.5, width, height);

                     }
                     completion:^(BOOL finished) {
                         [weakself.imgView removeFromSuperview];
                         [weakself.transitionContext completeTransition:YES];
                         [weakself.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
                         [weakself.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
                     }];
}

- (UIView*)bgView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = 121212;
    return view;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = DEFAULTCALLBG;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imgView;
}
@end
