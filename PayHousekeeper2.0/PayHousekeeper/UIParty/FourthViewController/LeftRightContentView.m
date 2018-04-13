//
//  LeftRightContentView.m
//  PayHousekeeper
//
//  Created by BY on 17/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "LeftRightContentView.h"

@interface LeftRightContentView ()<UITextFieldDelegate>
{
    UILabel *leftLabel;
    UILabel *rightLabel;
//    UITextField *rightTextField;
}

@end


@implementation LeftRightContentView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        leftLabel = [[UILabel alloc] init];
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.font = [UIFont systemFontOfSize:15];
        leftLabel.textColor = RGBCOLOR(51, 51, 51);
        [self addSubview:leftLabel];
        
        self.rightTextField = [[UITextField alloc] init];
        self.rightTextField.hidden = YES;
        self.rightTextField.delegate = self;
        self.rightTextField.textAlignment = NSTextAlignmentLeft;
        self.rightTextField.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.rightTextField];
        self.rightTextField.placeholder = @"";

        rightLabel = [[UILabel alloc] init];
        rightLabel.hidden = YES;
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.font = [UIFont systemFontOfSize:15];
        rightLabel.textColor = RGBCOLOR(102, 102, 102);
        [self addSubview:rightLabel];

    }
    return  self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    leftLabel.frame = CGRectMake(16, 0, 79, self.frame.size.height);

    rightLabel.frame = CGRectMake(0, 0, self.frame.size.width - 16, self.frame.size.height);

    self.rightTextField.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame) + 30, 0, 200, self.frame.size.height);

}

- (void)leftLabel:(NSString *)leftText rightText:(NSString *)rightText
{
    leftLabel.text = leftText;
    rightLabel.text = rightText;
    rightLabel.hidden = NO;
}

- (void)leftLabel:(NSString *)leftText textFieldPlaceholder:(NSString *)placeholder
{
    leftLabel.text = leftText;
    self.rightTextField.placeholder = placeholder;
    self.rightTextField.hidden = NO;
}



@end
