//
//  PersonInfoEditViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/15.
//  Copyright © 2016年 striveliu. All rights reserved.
//  个性签名控制器

#import "PersonInfoEditViewController.h"

@interface PersonInfoEditViewController ()<UITextViewDelegate>
{
    NSString *title;
    NSString *source;
    UITextView *textview;
    UILabel *unitCount;
}
@property (nonatomic, copy) void(^completeBlock)(NSString *content);
@end

@implementation PersonInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:title];
    self.view.backgroundColor = kViewBackgroundHexColor;
    textview = [[UITextView alloc] initWithFrame:CGRectMake(0, 14, self.view.width, 94)];
    textview.delegate = self;
    textview.scrollEnabled = NO; //禁止滑动 UITextView
    textview.font = [UIFont systemFontOfSize:13];
    textview.backgroundColor = kcolorWhite;
    textview.layer.borderColor = kLineColor.CGColor;
    textview.layer.borderColor = [UIColor clearColor].CGColor;
    textview.layer.borderWidth = kLineWidth;
    textview.textColor = kBlackColor;
    textview.textContainerInset = UIEdgeInsetsMake(23.0f, 17.0f, 35.0f, 24.0f);
    [self setRightButton:nil title:@"保存" titlecolor:kFcolorFontGreen target:self action:@selector(commitModifyInfo)];
    if(source)
    {
        NSMutableString *sourcePle = [NSMutableString stringWithFormat:@"%@", source];
        
        textview.text = sourcePle;
    }
    
    [self.view addSubview:textview];

    // 控制textviw里面属性
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距 textview高度太大，这个值太小会出问题
    paragraphStyle.firstLineHeadIndent = 25.f;    /**首行缩进宽度*/
    paragraphStyle.alignment = NSTextAlignmentJustified;
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textview.attributedText = [[NSAttributedString alloc] initWithString:textview.text attributes:attributes];
    
    
    
    // 文字个数
    unitCount = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 116, CGRectGetMaxY(textview.frame) - 36, 100, 24)];
    unitCount.textAlignment = NSTextAlignmentRight;
    unitCount.font = [UIFont systemFontOfSize:15];
    unitCount.textColor = RGBCOLOR(102, 102, 102);
    [self.view addSubview:unitCount];
    unitCount.text = [NSString stringWithFormat: @"%ld", 30 - textview.text.length];
    
//    if (textview.text.length > 4) {
//        NSUInteger leng = textview.text.length;
//        unitCount.text =  [NSString stringWithFormat: @"%lu", (unsigned long)leng];;
//    }
    
}


- (void)commitModifyInfo
{
    
    if(self.completeBlock)
    {

        self.completeBlock(textview.text);
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

#pragma mark -显示当前textView的改变状态
//- (void)textViewDidChange:(UITextView *)textView{
//    
//    
//    int leng = (int)textview.text.length;
//    unitCount.text =  [NSString stringWithFormat: @"%d", 30 - leng];
//    
//    int i = 30 - leng;
//    MLOG(@"gexingqianm  =  %@",textView.text);
//    MLOG(@"gexingqianm.lenth = %d",textView.text.length);
//    if (i <= 0) {
//        unitCount.text = @"0";
//        [textview resignFirstResponder];
//        NSString *subStr = [textview.text substringWithRange:NSMakeRange(0, 30)];
//        textview.text = subStr;
//    }
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *temstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(temstr.length > 30)
    {
        textView.text = [temstr substringToIndex:30];
        unitCount.text = @"0";
        return NO;
    }
    else
    {
        unitCount.text =  [NSString stringWithFormat: @"%d", (int)(30 - temstr.length)];
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
