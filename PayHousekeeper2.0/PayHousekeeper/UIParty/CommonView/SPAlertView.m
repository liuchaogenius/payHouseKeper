//
//  SPAlertView.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/24.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "SPAlertView.h"
#import "Public.h"
#import "UIViewAdaptive.h"

#define MESSAGE_MIN_LINE_COUNT 1
#define MESSAGE_MAX_LINE_COUNT 5


#define Screen_Width            [UIScreen mainScreen].bounds.size.width
#define Screen_Height           [UIScreen mainScreen].bounds.size.height
#define View_Margin             FitSize(37)
#define View_Width              (Screen_Width-2*View_Margin)
#define Title_Height             FitSize(50)
#define Btn_Height               FitSize(50)
#define Msg_Margin               FitSize(20)
#define Msg_Width                (self.frame.size.width-2*Msg_Margin)
#define View_Corner              FitSize(5)


@interface SPAlertView ()

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UILabel  *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, assign) CGFloat  height;
@property (nonatomic, assign) int      btnCount;
@property (nonatomic, assign) CGFloat  yPos;
@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation SPAlertView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.baseRatio = RatioBaseOn_6_ScaleFor5;
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id<SPAlertViewDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle
{
    self = [super initWithFrame:CGRectMake(View_Margin, FitSize(200), Screen_Width-2*View_Margin, FitSize(200))];
    if (self) {
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        self.okButtonTitle  = otherButtonTitle;
        self.backgroundColor = [UIColor whiteColor];
        self.yPos = 0;
        self.btnCount = 0;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = View_Corner;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
  
}

- (void)updateTitleLabel
{
    if (self.title)
    {
        if (!self.titleLabel)
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.yPos, self.frame.size.width, Title_Height)];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.backgroundColor = [UIColor whiteColor];
            self.titleLabel.font = [UIFont systemFontOfSize:20];
//            self.titleLabel.font = self.titleFont;
//            self.titleLabel.textColor = self.titleColor;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.yPos = self.yPos + Title_Height;
        }
        self.titleLabel.text = self.title;
        [self addSubview:self.titleLabel];
    } else
    {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
 
}

- (void)updateMessageLabel
{
    if (self.message) {
        if (!self.messageLabel) {
           
            self.messageLabel = [[UILabel alloc] init];
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
            self.messageLabel.numberOfLines = 0;
            self.messageLabel.lineBreakMode =  NSLineBreakByWordWrapping;
            self.messageLabel.backgroundColor = [UIColor whiteColor];
            self.messageLabel.font = [UIFont systemFontOfSize:16];
            CGFloat messageHeight  =  [self heightForMessageLabel];
            self.messageLabel.frame = CGRectMake(Msg_Margin, self.yPos+Msg_Margin,Msg_Width , messageHeight);
            self.yPos = self.yPos+messageHeight+2*Msg_Margin;
        }
        self.messageLabel.text = self.message;
        [self addSubview:self.messageLabel];
    } else {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
}

- (void)updateOkButton
{
    if (self.okButtonTitle) {
        if (!self.okButton) {
            self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.okButton.backgroundColor = kFcolorFontGreen;
            if (self.btnCount ==1)
            {
                self.okButton.frame = CGRectMake(0, self.yPos, View_Width, Btn_Height);
            }
            else if(self.btnCount == 2)
            {
                self.okButton.frame = CGRectMake(View_Width*0.5, self.yPos, View_Width*0.5, Btn_Height);
            }
            self.okButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [self.okButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
       [self.okButton setTitle:self.okButtonTitle forState:UIControlStateNormal];
        [self addSubview:self.okButton];
    } else {
        [self.okButton removeFromSuperview];
        self.okButton = nil;
    }
    
}

- (void)updateCancelButton
{
    if (self.cancelButtonTitle) {
        if (!self.cancelButton) {
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelButton.backgroundColor = RGBCOLOR(215, 215, 215);
            if (self.btnCount ==1)
            {
                self.cancelButton.frame = CGRectMake(0, self.yPos, View_Width, Btn_Height);
            }
            else if(self.btnCount == 2)
            {
                self.cancelButton.frame = CGRectMake(0, self.yPos, View_Width*0.5, Btn_Height);
            }
            self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [self.cancelButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [self addSubview:self.cancelButton];
    } else {
        [self.cancelButton removeFromSuperview];
        self.cancelButton = nil;
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
    [self updateMessageLabel];
    if (self.okButtonTitle.length>0&&self.cancelButtonTitle.length>0)
    {
       
        self.btnCount = 2;
    }
    else
    {
        self.btnCount = 1;
    }
    
    if ([self.okButtonTitle length]>0)
    {
         [self updateOkButton];
    }
    
    if ([self.cancelButtonTitle length]>0)
    {
        [self updateCancelButton];
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
- (CGFloat)heightForMessageLabel
{
    CGFloat minHeight = MESSAGE_MIN_LINE_COUNT * self.messageLabel.font.lineHeight;
    if (self.messageLabel)
    {
        CGFloat maxHeight = MESSAGE_MAX_LINE_COUNT * self.messageLabel.font.lineHeight;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = self.messageLabel.lineBreakMode;
        
        NSDictionary *attributes = @{NSFontAttributeName:self.messageLabel.font,
                                     NSParagraphStyleAttributeName: paragraphStyle.copy};
        
        CGRect rect = [self.message boundingRectWithSize:CGSizeMake(Msg_Width, maxHeight)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:attributes
                                                         context:nil];
        
        return MAX(minHeight, ceil(rect.size.height));

    }
    
    return minHeight;
}


- (void)btnClicked:(UIButton *)btn
{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectAlertButton:)])
    {
        [self.delegate performSelector:@selector(didSelectAlertButton:) withObject:btn.titleLabel.text];
    }
}
@end
