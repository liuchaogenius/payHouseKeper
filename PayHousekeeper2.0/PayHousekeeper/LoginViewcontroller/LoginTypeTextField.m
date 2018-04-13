//
//  LoginTypeTextField.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "LoginTypeTextField.h"

@interface LoginTypeTextField()<UITextFieldDelegate>
{
    UIView *view;
}
@end
@implementation LoginTypeTextField
@synthesize inputTextField;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createCustomTextfieldleftDesc:(NSString *)aLeftDesc ploc:(NSString *)aPloc isSecurity:(BOOL)aIsSecurity
{

    
    CGSize lsize = [aLeftDesc sizeWithFont:kFont16];
    int lwidth = 95;
    if(lsize.width>(95-10))
    {
        lwidth = lsize.width+10;
    }
    UILabel *lLabel = [self labelWithFrame:CGRectMake(17, (self.height-18)/2, lwidth, 18) text:aLeftDesc textFont:kFont16 textColor:[UIColor colorWithHexValue:0x666666]];
    self.backgroundColor = kcolorWhite;
    [self addSubview:lLabel];
    inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(lLabel.right, (self.height-18)/2, self.width-(95+15), 18)];
    inputTextField.font = kFont16;
    inputTextField.placeholder = aPloc;
    inputTextField.textColor = kBlackColor;
    inputTextField.delegate = self;
//    inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if(aIsSecurity)
    {
        inputTextField.secureTextEntry = YES;
    }
    [self addSubview:inputTextField];
}

- (void)createAdditionPersonTF:(NSString *)aLeftConten
{
    CGSize size = [aLeftConten sizeWithFont:kFont16];
    
    UILabel *label = [self labelWithFrame:CGRectMake(0, (self.height-18)/2, size.width+2, 18) text:aLeftConten textFont:kFont16 textColor:kBlackColor];
    [self addSubview:label];
    inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(label.right+5, (self.height-18)/2, self.width-label.right, 18)];
    inputTextField.font = kFont16;
    inputTextField.textColor = kGrayColor;
    inputTextField.textAlignment = NSTextAlignmentRight;
    inputTextField.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
//    inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputTextField.delegate = self;

    [self addSubview:inputTextField];
}

-(void)createTextfieldCenterPloc:(NSString *)aPloc isSecurity:(BOOL)aIsSecurity
{
    inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.height-18)/2, self.width, 18)];
    inputTextField.font = kFont16;
    inputTextField.placeholder = aPloc;
    inputTextField.textColor = kBlackColor;
    inputTextField.textAlignment = NSTextAlignmentCenter;
//    inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputTextField.contentVerticalAlignment= UIControlContentVerticalAlignmentCenter;
    inputTextField.delegate = self;
    if(aIsSecurity)
    {
        inputTextField.secureTextEntry = YES;
    }
    [self addSubview:inputTextField];
}

- (void)setType:(TextFieldType)type
{
    if (type == TextFieldTypePhone) {
        
        [inputTextField setKeyboardType:UIKeyboardTypePhonePad];
        
    }
    if (type == TextFieldTypeMix) {
        [inputTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    }
}

- (void)setKeyType:(UIKeyboardType)aKeyType
{
    inputTextField.keyboardType = aKeyType;
}

- (void)setInputTextFieldDelegate:(id)aDelegate
{
    inputTextField.delegate = aDelegate;
}

- (NSString *)getInputText
{
    return inputTextField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    
    if(text.length>40)
    {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
