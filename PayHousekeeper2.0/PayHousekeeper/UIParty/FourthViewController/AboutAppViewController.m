//
//  AboutAppViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/1/3.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "AboutAppViewController.h"

@interface AboutAppViewController ()

@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"关于"];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImage"]];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 145)];
    view.center = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 60);
    [self.view addSubview:view];
    
    UIImageView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    backView.center = CGPointMake(kMainScreenWidth / 2, 40);
    [backView setImage:[UIImage imageNamed:@"dd"]];
    [view addSubview:backView];
//    CGFloat versionY = 260;
//    if (IsLower6Screen)
//    {
//        versionY = 218;
//    }
//    else if (IsLargeScreen)
//    {
//        versionY = 290;
//    }
//    UILabel *versionLabel = [self.view labelWithFrame:CGRectMake(kComm_Content_Margin, versionY + 70, kComm_Content_Width, 13)
//                                                 text:[self getAppVersion]
//                                             textFont:kFont13
//                                            textColor:RGBCOLOR(0x9d, 0x9d, 0xa2)];
//    versionLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:versionLabel];
    
    
    UILabel *dd = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backView.frame) + 16, kMainScreenWidth, 21)];
    dd.text = @"咚咚";
    dd.textAlignment = NSTextAlignmentCenter;
    dd.textColor = RGBCOLOR(51, 51, 51);
    dd.font = [UIFont systemFontOfSize:22];
    [view addSubview:dd];
    
    UILabel *vL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dd.frame) + 8, kMainScreenWidth, 21)];
    vL.text = [self getAppVersion];
    vL.textAlignment = NSTextAlignmentCenter;
    vL.textColor = RGBCOLOR(157, 157, 162);
    vL.font = [UIFont systemFontOfSize:13];
    [view addSubview:vL];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 127, kMainScreenWidth, 20)];
    label1.font = [UIFont systemFontOfSize:13];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor blackColor];
    label1.text = @"陌趣科技   版权所有";
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label1.frame) + 2, kMainScreenWidth, 20)];
    label2.font = [UIFont systemFontOfSize:13];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor blackColor];
    label2.text = @"Copyright @ 2016-2017 InTalk. All Rights Reserved.";
    [self.view addSubview:label2];
    
}

-(NSString*)getAppVersion
{
    NSDictionary *appInfoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *verionInfo=appInfoDic[@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"V%@",verionInfo];
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
