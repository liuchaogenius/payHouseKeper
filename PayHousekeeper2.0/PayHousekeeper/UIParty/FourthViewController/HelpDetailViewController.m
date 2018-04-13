//
//  HelpDetailViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/1/3.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "HelpDetailViewController.h"

@interface HelpDetailViewController ()

@end

@implementation HelpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:self.titleStr];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    UIView *spaceview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 43)];
    spaceview.backgroundColor = kShortColor(238);
    [self.view addSubview:spaceview];
    
    UILabel *tlabel = [self.view labelWithFrame:CGRectMake(16, 0, spaceview.width-32, 43) text:self.titleStr textFont:kFont13 textColor:kShortColor(74)];
    tlabel.numberOfLines = 0;
    [spaceview addSubview:tlabel];
    
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, spaceview.bottom, self.view.width, self.view.height-spaceview.bottom)];
    bgview.backgroundColor = kcolorWhite;
    [self.view addSubview:bgview];
    
    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(16, 24, self.view.width-32, bgview.height-24)];
    textview.editable = NO;
    textview.backgroundColor = kClearColor;
    textview.textColor = RGBCOLOR(113, 113, 113);
    textview.font = kFont14;
    textview.text = self.content;
    [bgview addSubview:textview];
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
