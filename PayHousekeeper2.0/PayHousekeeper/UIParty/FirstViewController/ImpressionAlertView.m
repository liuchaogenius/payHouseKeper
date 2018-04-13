//
//  ImpressionAlertView.m
//  PayHousekeeper
//
//  Created by BY on 2017/3/27.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#define KDetailFont 16
#define KTitleFont 18
#define KTagFont 13

#import "ImpressionAlertView.h"
#import "NSString+Count.h"

@implementation BQButton
- (void)setHighlighted:(BOOL)highlighted {}

// 内部图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = 35;
    CGFloat imageH = 35;
    return CGRectMake((self.frame.size.width - imageW) / 2, 0, imageW, imageH);
}

// 内部文字的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height - 30;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(0, titleY, titleW, titleH);
}

@end

@interface ImpressionAlertView ()
{
    UIView *contenView;
    // 上
    UILabel *titleLabel;
    UILabel *leftValue;
    UILabel *rightValue;
    
    // 中
    BQButton *leftBtn;
    BQButton *rightBtn;
    
    // 装着标签
    NSMutableArray *tagArrView;
    // 装着已经先中的标签，确定后会传给传给控制器
    NSMutableArray *selectedTagArr;
    
    // 下
    UIScrollView *scrView;
    UIButton *cancelBtn;
    UIButton *confirmBtn;
}
@end

@implementation ImpressionAlertView

- (instancetype)initTimeStr:(NSString *)timeStr dongbiCount:(NSString *)dbCount tagArrray:(NSArray *)tagTextArr isSelf:(BOOL)isSelf
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    
    if (self)
    {
        
        contenView = [[UIView alloc] init];
        contenView.backgroundColor = [UIColor whiteColor];
        contenView.layer.masksToBounds = YES;
        contenView.layer.cornerRadius = 6;
        [self addSubview:contenView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:KTitleFont];
        titleLabel.text = @"印象";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        [contenView addSubview:titleLabel];
        
        leftValue = [[UILabel alloc] init];
        leftValue.font = [UIFont systemFontOfSize:KDetailFont];
        leftValue.text = timeStr;
        leftValue.textColor = [UIColor blackColor];
        [contenView addSubview:leftValue];
        
        
        rightValue = [[UILabel alloc] init];
        rightValue.font = [UIFont systemFontOfSize:KDetailFont];
        rightValue.text = dbCount;
        rightValue.textColor = [UIColor blackColor];
        [contenView addSubview:rightValue];
        
        leftBtn = [[BQButton alloc] init];
        leftBtn.tag = 0;
        [leftBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [leftBtn setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [leftBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(orLike:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setImage:[UIImage imageNamed:@"noLike_N"] forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"noLike_S"] forState:UIControlStateSelected];
        [contenView addSubview:leftBtn];
        
        
        rightBtn = [[BQButton alloc] init];
        rightBtn.selected = YES;
        rightBtn.tag = 1;
        [rightBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [rightBtn setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        [rightBtn setTitle:@"喜欢" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(orLike:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [rightBtn setImage:[UIImage imageNamed:@"like_N"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
        [contenView addSubview:rightBtn];
        
        scrView = [[UIScrollView alloc] init];
        scrView.showsVerticalScrollIndicator = NO;
        [contenView addSubview:scrView];
        
        
        tagArrView = [NSMutableArray array];
        
        for (int i = 0; i < tagTextArr.count; i++) {
            UILabel *tagView = [[UILabel alloc] init];
            tagView.userInteractionEnabled = NO;
            tagView.textAlignment = NSTextAlignmentCenter;
            tagView.text = tagTextArr[i];
            tagView.textColor = [UIColor whiteColor];
            tagView.backgroundColor = RGBCOLOR(215,212,212);
            tagView.layer.masksToBounds = YES;
            tagView.layer.cornerRadius = 8;
            tagView.tag = i;
            tagView.font = [UIFont systemFontOfSize:KTagFont];
            [tagView addTarget:self action:@selector(tagClicked:)];
            [scrView addSubview:tagView];
            
            [tagArrView addObject:tagView];
        }
        
        
        
        cancelBtn = [[UIButton alloc] init];
        confirmBtn.tag = 0;
        cancelBtn.backgroundColor = RGBCOLOR(33,235,190);
        [cancelBtn setTitle:@"忽略" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(bottomViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contenView addSubview:cancelBtn];
        
        confirmBtn = [[UIButton alloc] init];
        confirmBtn.tag = 1;
        [confirmBtn addTarget:self action:@selector(bottomViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        confirmBtn.backgroundColor = RGBCOLOR(33,235,190);
        [contenView addSubview:confirmBtn];
        
    }
    
    return self;
}

- (void)btnClicked:(UIButton *)btn
{
    if (btn.tag == 0) {
        leftBtn.selected = YES;
        rightBtn.selected = NO;
    }
    else
    {
        leftBtn.selected = NO;
        rightBtn.selected = YES;
    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat conX = 37;
    if (kMainScreenWidth == 320) { // 适配宽度为320的手机
        conX = 25;
    }
    CGFloat conViewWidth = self.width - conX * 2;
    
    titleLabel.frame = CGRectMake(0, 0, conViewWidth, 57);
    
    CGFloat leftX = 50;
    if (kMainScreenWidth == 320) { // 适配宽度为320的手机
        leftX = 30;
    }
    leftValue.frame = CGRectMake(leftX, CGRectGetMaxY(titleLabel.frame), conViewWidth / 2 - 30, 30);
    rightValue.frame = CGRectMake(CGRectGetMaxX(leftValue.frame) + 20, CGRectGetMaxY(titleLabel.frame), conViewWidth / 2 - 20, 30);

    leftBtn.frame = CGRectMake(leftX, CGRectGetMaxY(leftValue.frame) + 20, 65, 70);
    rightBtn.frame = CGRectMake(conViewWidth - leftX - 70, CGRectGetMaxY(leftValue.frame) + 20, 65, 70);
    
    
    scrView.frame = CGRectMake(conX, CGRectGetMaxY(leftBtn.frame) + 25, conViewWidth - 2 * conX, 133);
    
    
    // 间距
    CGFloat gapX = 18;
    CGFloat gapY = 31;
    
    int row = 0; // 记录行数行
    CGFloat col = 0; // 记录X值的倍数 列
    CGFloat x = 0;
    
    CGFloat beforeMaxX = 0; // 记录上一个View的最大X值
    
    CGFloat MaxY = 0; // 记录最后一个 tagView 的最大Y值
    
    CGFloat around = 8; // 上左下右各增 8/2
    
    for (int i = 0; i < tagArrView.count; i ++) {
        
        UILabel *tagView = tagArrView[i];
        
        CGSize MaxSize = CGSizeMake(scrView.width, MAXFLOAT);
        CGSize leftSize = [NSString getSizeByWidthSize:MaxSize title:tagView.text font:[UIFont systemFontOfSize:KTagFont]];
        
        x = gapX + beforeMaxX;
        if (i == 0) {
            x = 0;
        }
        
        // view的最大X值都判断一次是否超出scrView的范围
        if (x + around + leftSize.width > scrView.width) {
            
            row += 1;
            col = 0;
            x = 0;
            
        }
        
        tagView.frame = CGRectMake(x, row * (gapY + around) + leftSize.height, leftSize.width + around, leftSize.height + around);
        
        col += 1;
        
        beforeMaxX = CGRectGetMaxX(tagView.frame);
        
        if (i == tagArrView.count - 1) {
            MaxY = CGRectGetMaxY(tagView.frame);
        }
    }
    
    
    // 由最后一行的标签最大Y值决定
    scrView.contentSize = CGSizeMake(0, MaxY);
    
    
    cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(scrView.frame) + 10, conViewWidth / 2 - 0.5, 45);
    confirmBtn.frame = CGRectMake(conViewWidth / 2 + 0.5, CGRectGetMaxY(scrView.frame) + 10, conViewWidth / 2 - 0.5, 45);
    
    
    
    contenView.frame = CGRectMake(conX, 200, conViewWidth, CGRectGetMaxY(cancelBtn.frame));
    // 保证显示在中心
    contenView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
}

#pragma mark - 喜欢 或者 不喜欢点击事件
- (void)orLike:(UIButton *)btn
{
    for (UILabel *view in tagArrView) {
        view.backgroundColor = RGBCOLOR(215,212,212);
    }
    
}

- (void)tagClicked:(UITapGestureRecognizer *)recognizer
{
    UILabel *label = (UILabel*)recognizer.view;

    if (leftBtn.selected == YES) {
        
        if ([label.backgroundColor isEqual:RGBCOLOR(215,212,212)]) {
           
            label.backgroundColor = RGBCOLOR(163,188,229);
        }
        else
        {
            label.backgroundColor = RGBCOLOR(215,212,212);
        }
    }
    else
    {
        
        if ([label.backgroundColor isEqual:RGBCOLOR(215,212,212)]) {
    
            label.backgroundColor = RGBCOLOR(236,85,63);
        }
        else
        {
            label.backgroundColor = RGBCOLOR(215,212,212);
        }
    }
}

#pragma mark - 底部按钮点击事件
- (void)bottomViewClicked:(UIButton *)btn
{

    if (btn.tag == 1) { // 点击了确定
        
        selectedTagArr = [NSMutableArray array];
        
        for (UILabel *view in tagArrView) {
            BOOL sele =  ![view.backgroundColor isEqual:RGBCOLOR(215,212,212)];
            
            if (sele) { // 选中的label加到数组中
                [selectedTagArr addObject:view.text];
            }
        }
        
//        MLOG(@"选中的label加到数组中，回调给控制器====%@", selectedTagArr);
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(impressionViewDidBtnClicked:)])
    {
        [self.delegate performSelector:@selector(impressionViewDidBtnClicked:) withObject:selectedTagArr];
//        [self.delegate impressionViewDidBtnClicked:btn.tag];
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
