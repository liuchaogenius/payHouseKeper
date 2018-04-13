//
//  EditMoodsControl.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/13.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "EditMoodsControl.h"
#import "AppDelegate.h"

#define MAX_LENGTH 14

@interface EditMoodsControl ()<UITextFieldDelegate>
{
    UITextField *moodsTF;
}
@end

@implementation EditMoodsControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (EditMoodsControl *)sharedInstance
{
    static dispatch_once_t onceToken;
    static EditMoodsControl *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EditMoodsControl alloc] init];
    });
    return sSharedInstance;
}

- (id) init;
{
    self = [super initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    if (self)
    {
        [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [self initMoodsView];
    }
    
    return self;
}

- (void)initMoodsView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-57, kMainScreenWidth, 57)];
    [self addSubview:view];
    view.backgroundColor = RGBCOLOR(244, 244, 244);
    
    moodsTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, view.width-40, 47)];
    [view addSubview:moodsTF];
    moodsTF.backgroundColor = view.backgroundColor;
//    moodsTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    moodsTF.returnKeyType = UIReturnKeyDone;
    moodsTF.placeholder = @"现在的心情...";
    moodsTF.delegate = self;
    
    [moodsTF addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange
{
    NSString *toBeString = moodsTF.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [moodsTF markedTextRange];
    UITextPosition *position = [moodsTF positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > MAX_LENGTH)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_LENGTH];
            if (rangeIndex.length == 1)
            {
                moodsTF.text = [toBeString substringToIndex:MAX_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_LENGTH)];
                moodsTF.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

- (void)setMood:(NSString *)mood
{
    if ([mood length]==0)
    {
        return;
    }
    moodsTF.text = mood;
}

- (void)show
{
    WeakSelf(self)
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [DLAPPDELEGATE.window.rootViewController.view addSubview:weakself];
                     } completion:nil];
    [moodsTF becomeFirstResponder];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(_endEditMoods)
    {
        _endEditMoods(textField.text);
        textField.text = @"";
    }
    [self dismiss];
    return YES;
}

@end
