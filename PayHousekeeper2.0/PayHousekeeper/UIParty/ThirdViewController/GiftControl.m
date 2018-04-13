//
//  GiftControl.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "GiftControl.h"
#import "GiftModel.h"
#import "UIButton+WebCache.h"

#define GiftTagIndex 1000

@interface GiftControl()<UIScrollViewDelegate>
{
    int selectFlag;
    UIImageView *selectImg;
    NSMutableArray *giftsArr;
}

@property(nonatomic, strong)UIView          *bgView;
@property(nonatomic, strong)UIScrollView    *propsSC;
@property(nonatomic, strong)UIPageControl   *pageCtrl;

@end
@implementation GiftControl

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
        selectFlag = -1;
        [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)initGiftssView:(NSMutableArray *)giftArr
{
    giftsArr = [NSMutableArray arrayWithArray:giftArr];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-205*kScale, kMainScreenWidth, 205*kScale)];
    _bgView.backgroundColor = [UIColor clearColor];//RGBACOLOR(0, 0, 0, 0.2);
    [self addSubview:_bgView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0, _bgView.width, _bgView.height);
    [_bgView addSubview:effectview];
    
    _propsSC = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _bgView.width, _bgView.height-40)];
    _propsSC.backgroundColor = _bgView.backgroundColor;
    [_bgView addSubview:_propsSC];
    _propsSC.pagingEnabled = YES;
    _propsSC.delegate = self;
    _propsSC.showsHorizontalScrollIndicator = NO;
    
    UIButton *btn;
    UILabel *lab;
    UIImageView *imgView;
    float width = kMainScreenWidth/4.0;
    int num = (int)giftArr.count;
    int row = 4;
    for(int i = 0; i < num; i++)
    {
        GiftModel *model = [giftArr objectAtIndex:i];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i%row*width+i/(row*2)*_bgView.width, i%(row*2)/row*_propsSC.height/2, width, _propsSC.height/2);
        [_propsSC addSubview:btn];
        btn.backgroundColor = [UIColor clearColor];
        btn.clipsToBounds = YES;
        btn.tag = i+GiftTagIndex;

        [btn addTarget:self action:@selector(selectGift:) forControlEvents:UIControlEventTouchUpInside];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width/4+5, -10, width/2-10, btn.height)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [btn addSubview:imgView];
        [imgView sd_setImageWithURL:URL(model.icon) placeholderImage:DEFAULTAVATAR];
        
        lab = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.height-24, width, 10)];
        lab.text = [NSString stringWithFormat:@"%@咚币",model.price];
        lab.textColor = RGBCOLOR(38, 214, 153);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:10];
        [btn addSubview:lab];
        
        lab = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.height-10, width, 10)];
        lab.text = [NSString stringWithFormat:@"+%@秒",model.seconds];
        lab.textColor = kcolorWhite;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:10];
        [btn addSubview:lab];
    }
    int page = num/8+(num%8>0?1:0);
    _propsSC.contentSize = CGSizeMake(page*_bgView.width, 0);
    _pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _bgView.height-30-20, _bgView.width, 30)];
    _pageCtrl.numberOfPages = page;
    _pageCtrl.currentPage = 0;
    [_bgView addSubview:_pageCtrl];
    _pageCtrl.hidden = page <= 1;
    
    selectImg = [[UIImageView alloc] initWithImage:IMG(@"present_list_selector")];
    [_propsSC addSubview:selectImg];
    selectImg.hidden = YES;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _propsSC.bottom, kMainScreenWidth, 40)];
    bottomView.backgroundColor = _bgView.backgroundColor;
    [_bgView addSubview:bottomView];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kMainScreenWidth-40, bottomView.height)];
    lab.text = [NSString stringWithFormat:@"当前余额:%lld咚币",[UserInfoData shareUserInfoData].moneyCount];
    lab.textColor = RGBCOLOR(162, 162, 162);
    lab.font = kFont10;
    [bottomView addSubview:lab];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(bottomView.width/2-30, 0, 60, 40);
    [bottomView addSubview:btn];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:@"去充值>>" forState:UIControlStateNormal];
    [btn setTitleColor:RGBCOLOR(38, 214, 153) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoPay) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = kFont11;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(bottomView.width-20-55, 7, 55, 26);
    [bottomView addSubview:btn];
    btn.backgroundColor = RGBCOLOR(38, 214, 153);
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = btn.height/2;
    [btn setTitleColor:kcolorWhite forState:UIControlStateNormal];
    [btn setTitle:@"赠送" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(presentGift) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = kFont13;
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

- (void)selectGift:(UIButton *)btn
{
    if(btn.selected)
        return;
    
    UIButton *b = (UIButton *)[_propsSC viewWithTag:GiftTagIndex+selectFlag];
    b.selected = NO;
    btn.selected = YES;
    
    selectImg.frame = btn.frame;
    selectImg.hidden = NO;
    selectImg.center = btn.center;
    selectFlag = (int)btn.tag - GiftTagIndex;
}

- (void)gotoPay
{
    if(_gotoVCBlock)
    {
        _gotoVCBlock();
    }
    [self dismiss];
}

- (void)presentGift
{
    if(selectFlag != -1 && _presentGiftBlock)
    {
        _presentGiftBlock(giftsArr[selectFlag]);
        [self dismiss];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
}

//图片压缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize sourceImage:(UIImage *)img
{
    UIImage *sourceImage = img;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end
