//
//  DDAlertView.m
//  DongDong
//
//  Created by BY on 2017/3/26.
//  Copyright © 2017年 BestLife. All rights reserved.
//
#define KDetailFont 16
#define KTitleFont 18
#define KHeadWH 50.0

#import "DDAlertView.h"
#import "NSString+Count.h"

@interface DDAlertView ()
{
    UIView *contenView; // 中心父控件
    UIView *topContenView; // 提示标题的父控件
    
    // 上
    UILabel *titleLabel; // 用来显示 普通文字标题 或 者用户名
    UIImageView *headView; // 用户头像
    UIButton *timeView; // 用来显示 时间图标 和时间数字
    
    // 中
    UILabel *detailLabel; // 内容
    
    // 下
    UIButton *leftBtn;
    UIButton *rightBtn;
    
    // 白色背景时底部需要两条辅助线
    UIView *rowLine;
    UIView *colLine;
    
    UILabel *leftValue;
    UILabel *rightValue;
    
    UIView *hideView; // 点击会隐藏 在对话框的后面
}
@property (nonatomic, assign) DDAlertViewTitleType type;
@end

@implementation DDAlertView

- (instancetype)initWithTitleText:(NSString *)title headUrlStr:(NSString *)headStr valueArray:(NSArray<NSString *> *)valueArray detailsText:(NSString *)detailsStr closeText:(NSString *)closeStr nextText:(NSString *)nextStr translucencyBackground:(BOOL)translucency  type:(DDAlertViewTitleType)DDAlertViewTitleType
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];

    
    if (self) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
        
        self.type = DDAlertViewTitleType;
        
        
        hideView = [[UIView alloc] init];
        // 打开点击屏幕任何地方可以关闭弹框
//        [hideView addTarget:self action:@selector(hideViewClicked)];
        hideView.backgroundColor = [UIColor clearColor];
        [self addSubview:hideView];
        
        
        contenView = [[UIView alloc] init];
        contenView.layer.masksToBounds = YES;
        contenView.layer.cornerRadius = 6;
        [self addSubview:contenView];
        
        
        // 上
        if (title) {
            topContenView = [[UIView alloc] init];
            [contenView addSubview:topContenView];
            
            
            switch (DDAlertViewTitleType) {
                case BlackAlertViewTypeTitle: // 普通类型 标题
                    // 显示普通标题
                    titleLabel = [[UILabel alloc] init];
                    titleLabel.font = [UIFont systemFontOfSize:KTitleFont];
                    titleLabel.text = title;
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [topContenView addSubview:titleLabel];
                    break;
                    
                case BlackAlertViewTypeCallHead: // 头像类型 标题
                    // 显示用户名
                    titleLabel = [[UILabel alloc] init];
                    titleLabel.font = [UIFont systemFontOfSize:KTitleFont];
                    titleLabel.text = title;
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [topContenView addSubview:titleLabel];
                    if (headStr) {
                        headView = [[UIImageView alloc] init];
                        headView.layer.masksToBounds = YES;
                        headView.layer.cornerRadius = KHeadWH / 2;
                        [headView sd_setImageWithURL:URL(headStr) placeholderImage:[UIImage imageNamed:@"DDBear"]];
                        [topContenView addSubview:headView];
                    }
                    
                    break;
                    
                case BlackAlertViewTypeTime: // 时间类型 标题
                    
                    timeView = [[UIButton alloc] init];
                    timeView.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
                    timeView.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                    timeView.enabled = NO;
                    [timeView setImage:[UIImage imageNamed:@"vidicon_gray"] forState:UIControlStateNormal];
                    [timeView setTitle:title forState:UIControlStateNormal];
                    [topContenView addSubview:timeView];
                    
                    break;
                    
                default:
                    break;
            }
        }
        

        // 数组内容 和 detailsStr 只能选其一 优先选择detailsStr
        // 不需要detailsStr 时应该传nil
        
        // 中
        if (detailsStr) {
            detailLabel = [[UILabel alloc] init];
            detailLabel.text = detailsStr;
            detailLabel.font = [UIFont systemFontOfSize:KDetailFont];
            detailLabel.numberOfLines = 0;

            [contenView addSubview:detailLabel];
        }
        else // 数组内容
        {
            // BlackAlertViewTypeTimeAndResidueValue 不需要detaiLabel
            [detailLabel removeSubviews];
            detailLabel = nil;
            
            leftValue = [[UILabel alloc] init];
            leftValue.font = [UIFont systemFontOfSize:KDetailFont];
            if (valueArray.count) {
                leftValue.text = valueArray[0];
            }
            leftValue.textColor = [UIColor whiteColor];
            [contenView addSubview:leftValue];
            
            
            rightValue = [[UILabel alloc] init];
            rightValue.font = [UIFont systemFontOfSize:KDetailFont];
            if (valueArray.count >= 1) {
                rightValue.text = valueArray[1];
            }
            rightValue.textColor = [UIColor whiteColor];
            [contenView addSubview:rightValue];
        
        }
        
        
        // 下
        if (closeStr) {
            leftBtn = [[UIButton alloc] init];
            leftBtn.tag = 0;
            [leftBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [leftBtn setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
            [leftBtn setTitle:closeStr forState:UIControlStateNormal];
            [contenView addSubview:leftBtn];
        }
        
        if (nextStr) {
            rightBtn = [[UIButton alloc] init];
            rightBtn.tag = 1;
            [rightBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [rightBtn setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
            [rightBtn setTitle:nextStr forState:UIControlStateNormal];
            [contenView addSubview:rightBtn];
        }
        
        
        if (translucency) {
            contenView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
            titleLabel.textColor = [UIColor whiteColor];
            detailLabel.textColor = [UIColor whiteColor];
            
            [timeView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            leftBtn.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
            
            rightBtn.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        }
        else
        {
            rowLine = [[UIView alloc] init];
            rowLine.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
            [contenView addSubview:rowLine];
            
            [timeView setTitleColor:kBlackColor forState:UIControlStateNormal];
            
            colLine = [[UIView alloc] init];
            colLine.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
            [contenView addSubview:colLine];
            
            contenView.backgroundColor = [UIColor whiteColor];
            
            titleLabel.textColor = kBlackColor;
            detailLabel.textColor = kBlackColor;
            
            leftBtn.backgroundColor = kClearColor;
            
            rightBtn.backgroundColor = kClearColor;
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    hideView.frame = self.frame;
    
    CGFloat conX = 40;
    if (kMainScreenWidth == 320) { // 适配宽度为320的手机
        conX = 25;
    }
    CGFloat conViewWidth = self.width - conX * 2;

    // 上
    if (topContenView) {
        
        topContenView.frame = CGRectMake(0, 0, conViewWidth, 45);
    }
    
    CGSize tiMaxSize = CGSizeMake(conViewWidth, MAXFLOAT);
    CGSize tisize = [NSString getSizeByWidthSize:tiMaxSize title:titleLabel.text font:[UIFont systemFontOfSize:KTitleFont]];

    
    switch (self.type) {
            
        case BlackAlertViewTypeTitle: // 普通类型 标题
            
            titleLabel.frame = CGRectMake(0, 20, tisize.width, tisize.height);
            titleLabel.center = CGPointMake(topContenView.width / 2, tisize.height / 2 + 20);
            break;
            
        case BlackAlertViewTypeCallHead: // 头像类型 标题
            
            headView.frame = CGRectMake(conViewWidth / 2 - KHeadWH / 2, 20, KHeadWH, KHeadWH);
            
            titleLabel.frame = CGRectMake(0, CGRectGetMaxY(headView.frame) + 10, tisize.width, tisize.height);
            titleLabel.center = CGPointMake(topContenView.width / 2, tisize.height / 2 + CGRectGetMaxY(headView.frame) + 10);
            
            topContenView.frame = CGRectMake(0, 0, conViewWidth, CGRectGetMaxY(titleLabel.frame));

            break;
            
        case BlackAlertViewTypeTime: // 时间类型 标题
            
            timeView.frame = topContenView.frame;
            timeView.imageView.size = timeView.imageView.image.size;
            break;
            
        default:
            break;
    }
    
    // 中
    CGFloat gap = 10;
    if (topContenView == nil) {
        gap = 35;
    }
    if (detailLabel) {
        CGFloat deX = 40;
        
        CGSize deMaxSize = CGSizeMake(conViewWidth - deX * 2, MAXFLOAT);
        
        CGSize size = [NSString getSizeByWidthSize:deMaxSize title:detailLabel.text font:[UIFont systemFontOfSize:KDetailFont]];

        detailLabel.frame = CGRectMake(deX, CGRectGetMaxY(topContenView.frame) + gap, size.width, size.height);
        
    }
    else
    {
        CGFloat leftX = 50;
        if (kMainScreenWidth == 320) { // 适配宽度为320的手机
            leftX = 30;
        }
        CGSize MaxSize = CGSizeMake(conViewWidth / 2 - 40, MAXFLOAT);
        
        CGSize leftSize = [NSString getSizeByWidthSize:MaxSize title:leftValue.text font:[UIFont systemFontOfSize:KDetailFont]];
        leftValue.frame = CGRectMake(leftX, CGRectGetMaxY(topContenView.frame) + gap, leftSize.width, leftSize.height);
        
        CGSize rightSize = [NSString getSizeByWidthSize:MaxSize title:rightValue.text font:[UIFont systemFontOfSize:KDetailFont]];
        rightValue.frame = CGRectMake(conViewWidth / 2 + 25, CGRectGetMaxY(topContenView.frame) + gap, rightSize.width, rightSize.height);
    }
    
    CGFloat labelMaxY = CGRectGetMaxY(detailLabel.frame);
    if (detailLabel == nil) {
        labelMaxY = CGRectGetMaxY(leftValue.frame);
    }
    
    // 下
    if (leftBtn) {
        leftBtn.frame = CGRectMake(0, labelMaxY + 20, conViewWidth / 2 - 0.5, 60);
    }
    
    if (rightBtn) {
        rightBtn.frame = CGRectMake(conViewWidth / 2 + 0.5, labelMaxY + 20, conViewWidth / 2 - 0.5, 60);
        
        if (rowLine) {
            rowLine.frame = CGRectMake(0, labelMaxY + 19, conViewWidth, 0.5);
            
            colLine.frame = CGRectMake(conViewWidth / 2, labelMaxY + 19, 0.5, leftBtn.height);
        }
    }
    else // 底部只有一个按钮
    {
        leftBtn.frame = CGRectMake(0, labelMaxY + 20, conViewWidth, 60);
    }
    
    
    
    // 中心父控件
    contenView.frame = CGRectMake(0, 0, conViewWidth, CGRectGetMaxY(leftBtn.frame));
    // 保证显示在中心
    contenView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
}

- (void)btnClicked:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alerViewDidBtnClicked:)])
    {
        [self.delegate alerViewDidBtnClicked:btn];
    }
    [self removeAlerView];
}

- (void)show
{

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)hideViewClicked
{
    
    for (UIView *view in self.subviews) {
        
        [view removeFromSuperview];
        
    }
    
    [self removeFromSuperview];
    
}

- (void)removeAlerView
{
    [self hideViewClicked];
}

@end
