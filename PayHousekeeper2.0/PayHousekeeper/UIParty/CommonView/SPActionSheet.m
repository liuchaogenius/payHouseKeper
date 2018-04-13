//
//  SPActionSheet.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/24.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "SPActionSheet.h"

#define Screen_Width            [UIScreen mainScreen].bounds.size.width
#define Screen_Height           [UIScreen mainScreen].bounds.size.height
#define View_Margin             40
#define View_Width              (Screen_Width-2*View_Margin)
#define Title_Height             50
#define Btn_Height               50
#define Msg_Margin               20
#define Msg_Width                (self.frame.size.width-2*Msg_Margin)
#define View_Corner              10

#define SPRGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface SPActionSheet ()

@property (nonatomic, assign) BOOL     isVisible;
@property (nonatomic, assign) CGFloat  yPos;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIFont    *buttonFont;
@property (nonatomic, strong) UIImageView *backgroundView;

@end
@implementation SPActionSheet

- (instancetype)initWithTitle:(NSString *)title
                   dismissMsg:(NSString *)message
                     delegate:(id<SPActionSheetDelegate>)delegate
                 buttonTitles:(NSArray *)buttonTitles
{
    self = [super initWithFrame:CGRectMake(View_Margin, 200, Screen_Width-2*View_Margin, 200)];
    if (self) {
        self.title = title;
        self.dismissMsg = message;
        self.delegate = delegate;
        self.buttonTitles = buttonTitles;
        self.backgroundColor = [UIColor whiteColor];
        self.yPos = 0;
        
        self.titleColor = [UIColor grayColor];
        self.contentBtnColor = [UIColor blackColor];
        self.dismissBtnColor = [UIColor grayColor];
        
        self.titleBackgroundColor = [UIColor whiteColor];
        self.contentBackgroundBtnColor = [UIColor whiteColor];
        self.dismissBackgroundBtnColor = [UIColor whiteColor];
        
        self.contentBtnFont = [UIFont systemFontOfSize:14];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = View_Corner;
        
        
        
    }
    return self;
}

- (void)updateTitleLabel
{
    if (self.title)
    {
        if (!self.titleLabel)
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.yPos, self.frame.size.width, Title_Height)];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.textColor = self.titleColor;
            self.titleLabel.backgroundColor = self.titleBackgroundColor;
            self.titleLabel.font = [UIFont systemFontOfSize:16];
       
            self.yPos = self.yPos + Title_Height;
        }
        self.titleLabel.text = self.title;
        [self addSubview:self.titleLabel];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,Title_Height-0.5, View_Width, 0.5)];
        line.backgroundColor = SPRGBCOLOR(0xd8, 0xdb, 0xdc);//[UIColor colorWithHexValue:0xd8d8dc];
        [self addSubview:line];
    } else
    {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    
}

- (void)updatedismissButton
{
    if (!self.dismissButton) {
        if (!self.dismissButton) {
            self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.dismissButton.backgroundColor = self.dismissBackgroundBtnColor;// kFcolorFontGreen;
            
            self.dismissButton.frame = CGRectMake(0, self.yPos, View_Width, Btn_Height);
            
            
            self.dismissButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [self.dismissButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.dismissButton setTitle:self.dismissMsg forState:UIControlStateNormal];
        [self.dismissButton setTitleColor:self.dismissBtnColor forState:UIControlStateNormal];
        [self addSubview:self.dismissButton];
    } else {
        [self.dismissButton removeFromSuperview];
        self.dismissButton = nil;
    }
    
}

- (void)updateTitleButtons
{
    if (self.buttonTitles.count>0)
    {
//        self.yPos = self.yPos+self.buttonTitles.count*Btn_Height;
        for (NSUInteger i = 0; i < self.buttonTitles.count; i++)
        {
    
            NSString *title = self.buttonTitles[i];

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, self.yPos,View_Width , Btn_Height);
            button.tag = i;
            button.titleLabel.font = self.contentBtnFont;
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = self.contentBackgroundBtnColor;
            [button setTitleColor:self.contentBtnColor forState:UIControlStateNormal];
            [self addSubview:button];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, View_Width, 0.5)];
            line.backgroundColor = SPRGBCOLOR(0xd8, 0xdb, 0xdc);
            [button addSubview:line];
          
            self.yPos = self.yPos +Btn_Height;
        }
    }
}
- (void)show
{
    if (self.isVisible)
    {
        return;
    }
    self.isVisible = YES;
    if ([self.title length]>0)
    {
        [self updateTitleLabel];
    }
    if(self.buttonTitles.count>0)
    {
        [self updateTitleButtons];
    }
    
    if ([self.dismissMsg length]>0)
    {
        [self updatedismissButton];
    }
    self.yPos = self.yPos+Btn_Height;
    self.frame = CGRectMake(View_Margin, (Screen_Height-self.yPos)/2, Screen_Width-2*View_Margin, self.yPos);
    
    self.backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [self.backgroundView setImage:[UIImage imageNamed:@"透明底框"]];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView  addSubview:self];
    
    UIWindow *showWindow = [[UIApplication sharedApplication] keyWindow];
    [showWindow addSubview:self.backgroundView];
    
}
- (void)dismiss
{
    self.isVisible = NO;
    [self.backgroundView removeFromSuperview];
}
- (void)btnClicked:(UIButton *)btn
{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectActionSheetButton:)])
    {
        [self.delegate performSelector:@selector(didSelectActionSheetButton:) withObject:btn.titleLabel.text];
    }
}
@end
