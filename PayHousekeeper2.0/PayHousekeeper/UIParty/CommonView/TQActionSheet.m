//
//  TQActionSheet.m
//  PayHousekeeper
//
//  Created by BY on 2017/3/25.
//  Copyright © 2017年 striveliu. All rights reserved.
//


// 行高
#define K_ROW_HEIGHT     44.0

#import "TQActionSheet.h"

@interface TQActionSheet ()
@property (nonatomic, strong)NSMutableArray *rowViewArr;

@property (nonatomic, strong)NSMutableArray *leftViewArr;
@property (nonatomic, strong)NSMutableArray *middleViewArr;
@property (nonatomic, strong)NSMutableArray *rightViewArr;

@property (nonatomic, weak)UILabel *titleView;
@property (nonatomic, weak)UIButton *confirmBtn;

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong)NSArray *allTitleArr;

@property (nonatomic, assign)CGFloat sH;
@end

@implementation TQActionSheet

- (instancetype)initWithTitle:(NSString *)title columnTitles:(NSArray *)allTitleArr
                                   dismissMsg:(NSString *)message
                                     delegate:(id<TQActionSheetDelegate>)delegate
{
    self = [super initWithFrame:CGRectMake(37, 114, kMainScreenWidth - 37 * 2, K_ROW_HEIGHT * (allTitleArr.count + 2))];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.allTitleArr = allTitleArr;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        
        
        self.delegate = delegate;
        
        UILabel *titleView = [[UILabel alloc] init];
        // 粗体
        
        titleView.textColor = RGBCOLOR(51, 51, 51);
        titleView.font = [UIFont systemFontOfSize:16];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.text = title;
        [self addSubview:titleView];
        self.titleView = titleView;
        
        // 设置每行View
        [self setupCell:allTitleArr];
        
        
        UIButton *confirmBtn = [[UIButton alloc] init];
        [confirmBtn setTitle:message forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [confirmBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setBackgroundImage:[UIImage imageNamed:@"Normal_BG"] forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[UIImage imageNamed:@"Normal_BG"] forState:UIControlStateHighlighted];
        [self addSubview:confirmBtn];
        self.confirmBtn = confirmBtn;
        
    }
    return self;
}

- (void)setupCell:(NSArray *)titleArr
{
        self.rowViewArr = [NSMutableArray array];
        
        self.leftViewArr = [NSMutableArray array];
        self.middleViewArr = [NSMutableArray array];
        self.rightViewArr = [NSMutableArray array];
    
        for (int i = 0; i < titleArr.count; i ++) {
            
            UIView *cell = [[UIView alloc] init];
            [self addSubview:cell];
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = RGBCOLOR(238, 238, 238);
            [cell addSubview:line];
            
            [self.rowViewArr addObject:cell];
         
            
            // cell里的子控件
            UILabel * leftView = [[UILabel alloc] init];
            leftView.textColor = RGBCOLOR(153, 153, 153);
            leftView.font = [UIFont systemFontOfSize:13];
            leftView.textAlignment = NSTextAlignmentCenter;
            if ([titleArr[i] count]) {
                leftView.text = titleArr[i][0];
            }
            [cell addSubview:leftView];
            [self.leftViewArr addObject:leftView];
            
            if ([titleArr[i] count] > 1) {
                if ([titleArr[i][1] isEqualToString:@"gou"]) {
                    UIButton * middleView = [[UIButton alloc] init];
                    middleView.enabled = NO;
                    [middleView setImage:[UIImage imageNamed:@"打钩-(1)"] forState:UIControlStateNormal];
                    [cell addSubview:middleView];
                    [self.middleViewArr addObject:middleView];
                }
                else
                {
                    UILabel * middleView = [[UILabel alloc] init];
                    middleView.textColor = RGBCOLOR(33, 235, 190);
                    middleView.font = [UIFont systemFontOfSize:13];
                    middleView.textAlignment = NSTextAlignmentCenter;
                    middleView.text = titleArr[i][1];
                    [cell addSubview:middleView];
                    [self.middleViewArr addObject:middleView];
                }
            }
            
            if ([titleArr[i] count] > 2) {
                if ([titleArr[i][2] isEqualToString:@"hui"]) {
                    UIButton * rightView = [[UIButton alloc] init];
                    rightView.enabled = NO;
                    [rightView setImage:[UIImage imageNamed:@"没有图标"] forState:UIControlStateNormal];
                    [cell addSubview:rightView];
                    [self.rightViewArr addObject:rightView];
                }
                else
                {
                    UILabel * rightView = [[UILabel alloc] init];
                    rightView.textColor = RGBCOLOR(153, 153, 153);
                    rightView.font = [UIFont systemFontOfSize:13];
                    rightView.textAlignment = NSTextAlignmentCenter;
                    
                    rightView.text = titleArr[i][2];
                    [cell addSubview:rightView];
                    [self.rightViewArr addObject:rightView];
                }
            }
            
            
        }
    
}



- (void)layoutSubviews
{
    [super layoutSubviews];


    CGFloat maxCellY = 0;
    
    self.titleView.frame = CGRectMake(0, 0, self.width, K_ROW_HEIGHT);
    
    // 设置每行cell的frame
    for (int i = 0; i < self.rowViewArr.count; i ++) {
        UIView *cell = self.rowViewArr[i];
        
        // 格子上面的灰色线
        UIView *line = [cell.subviews firstObject];
        line.frame = CGRectMake(0, 0, self.width, 1);
        
        cell.frame = CGRectMake(0, i * K_ROW_HEIGHT + K_ROW_HEIGHT, self.width, K_ROW_HEIGHT);
        
        if (i == self.rowViewArr.count - 1) { // 纪录最后一个cell的最大Y值
            maxCellY = CGRectGetMaxY(cell.frame);
        }
        
   
        // 设置每行cell左边子控件的frame
        UILabel *leftLabel = self.leftViewArr[i];
//        leftLabel.text = self.allTitleArr[i][0];
        leftLabel.frame = CGRectMake(0, 0, self.width / 2, K_ROW_HEIGHT);
        
        // 设置每行cell中间子控件的frame
        UIView *middleLabel = self.middleViewArr[i];
//        middleLabel.text = self.allTitleArr[i][1];
        middleLabel.frame = CGRectMake(self.width / 2, 0, self.width / 4, K_ROW_HEIGHT);
        
        
        // 设置每行cell右边子控件的frame
        UIView *rightLabel = self.rightViewArr[i];
//        rightLabel.text = self.allTitleArr[i][2];
        rightLabel.frame = CGRectMake(self.width / 4 * 3, 0, self.width / 4, K_ROW_HEIGHT);
     
        if (i == 0) {
            leftLabel.textColor = RGBCOLOR(51, 51, 51);
            
            ((UILabel *)middleLabel).textColor = RGBCOLOR(102, 102, 102);
            ((UILabel *)rightLabel).textColor = RGBCOLOR(102, 102, 102);
        }
    }
    
    self.confirmBtn.frame = CGRectMake(0, maxCellY, self.width, K_ROW_HEIGHT);
    
    self.sH = CGRectGetMaxY(self.confirmBtn.frame);
}


- (void)show
{
    self.backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [self.backgroundView setImage:[UIImage imageNamed:@"透明底框"]];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView  addSubview:self];
    
    
//    self.frame = CGRectMake(37, 114, kMainScreenWidth - 37 * 2, self.sH);
    self.center = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2);
    
    UIWindow *showWindow = [[UIApplication sharedApplication] keyWindow];
    [showWindow addSubview:self.backgroundView];
}

- (void)btnClicked:(UIButton *)btn
{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectActionSheetButton:)])
    {
        [self.delegate performSelector:@selector(didSelectActionSheetButton:) withObject:btn.titleLabel.text];
    }
}

- (void)dismiss
{
    
    [self.backgroundView removeFromSuperview];
}

@end
