//
//  AlterNicknameVC.m
//  PayHousekeeper
//
//  Created by BY on 17/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//  修改昵称控制器

#import "AlterNicknameVC.h"
#import "LeftRightContentView.h"

@interface AlterNicknameVC ()
{
    NSString *title;
    NSString *source;
    UITextView *textview;
    UILabel *unitCount;
    LeftRightContentView *lrView1;
}
@property (nonatomic, copy) void(^completeBlock)(NSString *content);
@end

@implementation AlterNicknameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:title];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    lrView1 = [[LeftRightContentView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 56)];
    lrView1.type = RightContentTypeTextField;
    [self.view addSubview:lrView1];
    [lrView1 leftLabel:@"修改昵称" textFieldPlaceholder:@"请输入新的昵称"];
    
    [lrView1.rightTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];

    
    LeftRightContentView *lrView2 = [[LeftRightContentView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lrView1.frame) + 1, self.view.frame.size.width, 56)];
    lrView2.type = RightContentTypeTitle;
    [self.view addSubview:lrView2];
    [lrView2 leftLabel:@"当前昵称" rightText:source];
    
    [self setRightButton:nil title:@"保存" titlecolor:kFcolorFontGreen target:self action:@selector(commitModifyInfo)];

}

- (void)textFieldDidChange
{
    NSString *toBeString = lrView1.rightTextField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [lrView1.rightTextField markedTextRange];
    UITextPosition *position = [lrView1.rightTextField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 12)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:12];
            if (rangeIndex.length == 1)
            {
                lrView1.rightTextField.text = [toBeString substringToIndex:12];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 12)];
                lrView1.rightTextField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

- (void)commitModifyInfo
{
    
    if(self.completeBlock)
    {
        self.completeBlock(lrView1.rightTextField.text);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setVCTitle:(NSString *)aTitle
            source:(NSString *)aSource
             block:(void(^)(NSString *aContent))completeBlock
{
    self.completeBlock = completeBlock;
    title = aTitle;
    source = aSource;
}


@end
