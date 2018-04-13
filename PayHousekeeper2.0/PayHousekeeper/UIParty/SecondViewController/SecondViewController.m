//
//  SecondViewController.m
//  YHB_Prj
//
//  Created by  striveliu on 14-11-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "SecondViewController.h"
#import <UIView+Toast.h>
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *bgimg = [[UIImage imageNamed:@"home_bg_blue"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgimg];
    [self settitleLabel:@"一键通"];
    
    UIView *yjrzView = [self createCustomBtView:[UIImage imageNamed:@"yijianrongzai"] title:@"一键容灾" rect:CGRectMake(15,30+64,kMainScreenWidth-30,80)];
    yjrzView.tag = 0;
    [yjrzView addTarget:self action:@selector(viewTapItem)];
    [self.view addSubview:yjrzView];

    UIView *yjkrView = [self createCustomBtView:[UIImage imageNamed:@"yijiankuorong"] title:@"一键扩容" rect:CGRectMake(15,yjrzView.bottom+20,kMainScreenWidth-30,80)];
    yjkrView.tag = 1;
    [yjkrView addTarget:self action:@selector(viewTapItem)];
    [self.view addSubview:yjkrView];
    
    UIView *yjxlView = [self createCustomBtView:[UIImage imageNamed:@"yijianxianliu"] title:@"一键限流" rect:CGRectMake(15,yjkrView.bottom+20,kMainScreenWidth-30,80)];
    yjxlView.tag = 2;
    [yjxlView addTarget:self action:@selector(viewTapItem)];
    [self.view addSubview:yjxlView];
}

- (void)viewTapItem
{
    [self.view makeToast:@"敬请期待"];
    
//    [self.view makeToastActivity:CSToastPositionCenter];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.view hideToastActivity];
//    });
}

- (UIView *)createCustomBtView:(UIImage *)aBtImg title:(NSString *)aTitle rect:(CGRect)aRect
{
    UIView *customBtView = [[UIView alloc] initWithFrame:aRect];
    customBtView.backgroundColor = RGBACOLOR(255, 255, 255, 0.1);
    customBtView.layer.cornerRadius = 5.0f;
    CGSize tsize = [aTitle sizeWithFont:kFont18];
    int offsetx = (customBtView.width-aBtImg.size.width-tsize.width-22)/2;
    int imgoffsety = (customBtView.height-aBtImg.size.height)/2;
    int toffsety = (customBtView.height-tsize.height)/2;
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(offsetx, imgoffsety, aBtImg.size.width, aBtImg.size.height)];
    [imgview setImage:aBtImg];
    [customBtView addSubview:imgview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgview.right+20, toffsety, tsize.width, tsize.height)];
    label.backgroundColor = kClearColor;
    label.textColor = kcolorWhite;
    label.text = aTitle;
    label.font = kFont18;
    [customBtView addSubview:label];
    return customBtView;
}

- (void)buttonItem:(UIButton *)aBt
{
    
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
