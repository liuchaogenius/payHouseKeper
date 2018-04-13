//
//  PersonLevelViewController.m
//  PayHousekeeper
//
//  Created by 1 on 2016/11/23.
//  Copyright © 2016年 striveliu. All rights reserved.
//  等级控制器

#import "PersonLevelViewController.h"
#import "PersonInfoManager.h"
#import "CirqueView.h"
#import "OvalButton.h"

@interface PersonLevelViewController ()
{
    UIScrollView *contentview;
    UIView *headview;
    UILabel *middleLabel;
    UIView *bottomView;
    NSString *strLevel;
    UILabel *levlLabel;
    UIView *activeView;
    UIView *meilizhiView;
    UIView *caifuView;
    UIView *selProcessView;
    UILabel *botmlevLabel;
    CirqueView *cView;
    OvalButton *wealthValueBtn;
    OvalButton *charmValueBtn;
    OvalButton *activityValueBtn;
}
@property (nonatomic, strong)PersonInfoManager *manager;
@property (nonatomic, strong)PersonLevelData *levelData;
@end

@implementation PersonLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[PersonInfoManager alloc] init];
    
    [self settitleLabel:@"等级"];
    contentview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentview];
    self.view.backgroundColor = contentview.backgroundColor = kViewBackgroundHexColor;
    
    [self createHeadView];
    [self createMiddleLabel];
    
    [self createBottomView];
    
}

- (void)firstMovingToParentvc
{
    WeakSelf(self);
    [DLAPPDELEGATE showMakeToastCenter];
    [self.manager requestUserLevel:^(PersonLevelData *data) {
        [DLAPPDELEGATE hiddenWindowToast];
        if(data)
        {
            NSLog(@"data == %@", data);
            weakself.levelData = data;
            [[UserInfoData shareUserInfoData] setUserLeval:[data.strLevel intValue]];
            [weakself reloadview];
        }
    }];
}

- (void)reloadview
{
    // 等级数据
    levlLabel.text = [NSString stringWithFormat:@"Lv.%@",self.levelData.strLevel];
    botmlevLabel.text = [NSString stringWithFormat:@"Lv.%@",self.levelData.strLevel];
    
    // 活跃数值
    UILabel *actLabel = (UILabel*)[activeView viewWithTag:100];
    actLabel.text = [NSString stringWithFormat:@"%d",self.levelData.iActiveVal];
   
    
    // 魅力数据
    UILabel *mlLabel = (UILabel*)[meilizhiView viewWithTag:100];
    mlLabel.text = [NSString stringWithFormat:@"%@",self.levelData.strCharmVal];
  
    
    // 财富数值
    UILabel *cfLabel = (UILabel*)[caifuView viewWithTag:100];
    cfLabel.text = [NSString stringWithFormat:@"%d",self.levelData.iWealthVal];
    
    
    CGFloat percen = ABS([self.levelData.strPercent floatValue]/100.f);
    selProcessView.width = (self.view.width-28*2)*percen;
    
    NSString *str1 = [NSString stringWithFormat:@"%d", self.levelData.iActiveVal];
    NSString *str2 = self.levelData.strCharmVal;
    NSString *str3 = [NSString stringWithFormat:@"%d", self.levelData.iWealthVal];
    
    cView = [[CirqueView alloc] initCirqueViewWithFrame:CGRectMake(25, 30, 70, 70) andDatas:@[str3, str2, str1]];
    [bottomView addSubview:cView];

    
}

- (void)createHeadView
{
    headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 204)];
    headview.backgroundColor = [UIColor whiteColor];
    UIImage *lImg = [UIImage imageNamed:@"personLevel"];
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width-lImg.size.width)/2, 20, lImg.size.width, lImg.size.height)];
    [imgview setImage:lImg];
    [headview addSubview:imgview];
    
    levlLabel = [self.view labelWithFrame:CGRectMake(0, 180.0/263*imgview.height, imgview.width-14, 30) text:@"Lv.0" textFont:[UIFont systemFontOfSize:22] textColor:kcolorWhite];

    levlLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.f];
    levlLabel.textAlignment = NSTextAlignmentCenter;
    [imgview addSubview:levlLabel];
    
    UIView *processView = [[UIView alloc] initWithFrame:CGRectMake(28, imgview.bottom+20, self.view.width-28*2, 8)];
    processView.layer.cornerRadius = 4.0f;
    processView.backgroundColor = kShortColor(0xef);
    [headview addSubview:processView];
    
    selProcessView = [[UIView alloc] initWithFrame:CGRectMake(28, imgview.bottom+20, (self.view.width-28*2)*0, 8)];
    selProcessView.layer.cornerRadius = 4.0f;
    selProcessView.backgroundColor = [UIColor colorWithHexValue:0xf6dc68];
    [headview addSubview:selProcessView];
    
    [contentview addSubview:headview];
}

- (void)createMiddleLabel
{
    middleLabel = [self.view labelWithFrame:CGRectMake(16, headview.bottom, self.view.width-32, 35) text:@"分值构成" textFont:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexValue:0x8f8e94]];
    [contentview addSubview:middleLabel];
}

- (void)createBottomView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, middleLabel.bottom, self.view.width, 258)];
    bottomView.backgroundColor = kcolorWhite;
    [contentview addSubview:bottomView];
    
    
    
    // [UserInfoData shareUserInfoData].wealthlevel
    wealthValueBtn = [[OvalButton alloc] initWithFrame:CGRectMake(21, bottomView.frame.size.height - 110, 84, 38)];
    wealthValueBtn.backgroundColor = RGBCOLOR(246, 194, 51);
    wealthValueBtn.LvLabel.text = [NSString stringWithFormat:@"Lv%d", [UserInfoData shareUserInfoData].wealthlevel];
    [wealthValueBtn setTitle:@"财富等级" forState:UIControlStateNormal];
    [wealthValueBtn setImage:[UIImage imageNamed:@"钻石"] forState:UIControlStateNormal];
    [bottomView addSubview:wealthValueBtn];
    
    // 间距
    CGFloat gap = (kMainScreenWidth - 42 - 252) / 2;
    
    charmValueBtn = [[OvalButton alloc] initWithFrame:CGRectMake((21 + 84) + gap, bottomView.frame.size.height - 110, 84, 38)];
    charmValueBtn.backgroundColor = RGBCOLOR(255, 133, 161);
    charmValueBtn.LvLabel.text = [NSString stringWithFormat:@"Lv%d", [UserInfoData shareUserInfoData].charmlevel];
    [charmValueBtn setTitle:@"魅力等级" forState:UIControlStateNormal];
    [charmValueBtn setImage:[UIImage imageNamed:@"魅力"] forState:UIControlStateNormal];
    [bottomView addSubview:charmValueBtn];
    
    activityValueBtn = [[OvalButton alloc] initWithFrame:CGRectMake((21 + 84 + 84) + gap * 2, bottomView.frame.size.height - 110, 84, 38)];
    activityValueBtn.backgroundColor = RGBCOLOR(232, 179, 115);
    activityValueBtn.LvLabel.text = [NSString stringWithFormat:@"Lv%d", [UserInfoData shareUserInfoData].activeLevel];
    [activityValueBtn setTitle:@"活跃等级" forState:UIControlStateNormal];
    [activityValueBtn setImage:[UIImage imageNamed:@"活跃值图标"] forState:UIControlStateNormal];
    [bottomView addSubview:activityValueBtn];
    
    
    
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(31, 31, 72, 72)];
//    [imgview setImage:[UIImage imageNamed:@"leve_value_circle"]];
    [bottomView addSubview:imgview];
    
    botmlevLabel = [self.view labelWithFrame:CGRectMake(imgview.right+17, 39, self.view.width-(imgview.right+17), 18) text:@"级别：Lv0" textFont:kFont16 textColor:kShortColor(0x66)];
    [bottomView addSubview:botmlevLabel];
    
    NSString *str = @"等级制度是用户的活跃度，魅力和消费能力的综合体现";
    CGSize size = [str sizeWithFont:kFont12];
    int line = 1;
    if(size.width > (self.view.width-(imgview.right+17)-20))
    {
        line = 2;
    }
    UILabel *levDescLabel = [self.view labelWithFrame:CGRectMake(botmlevLabel.left, botmlevLabel.bottom+10, self.view.width-(imgview.right+17)-20,16*line) text:str textFont:kFont12 textColor:[UIColor colorWithHexValue:0x8f8e94]];
    levDescLabel.numberOfLines = line;
    [bottomView addSubview:levDescLabel];
    
    UIView *sperLine = [self.view getViewLine:CGRectMake(0, imgview.bottom+30, self.view.width, kLineWidth)];
    [bottomView addSubview:sperLine];
    
    caifuView = [self createUntilView:CGRectMake(0, CGRectGetMaxY(wealthValueBtn.frame) + 15, (self.view.width-3)/3, bottomView.height-sperLine.bottom) color:RGBCOLOR(246, 194, 51) desc:@"财富值" value:@"0"];
    caifuView.center = CGPointMake(63, CGRectGetMaxY(wealthValueBtn.frame) + 15 + 25.5);
    [bottomView addSubview:caifuView];

    UIView *mSperLine = [[UIView alloc] initWithFrame:CGRectMake(activeView.right, sperLine.bottom+(bottomView.height-sperLine.bottom-57)/2, kLineWidth, 57)];
    [bottomView addSubview:mSperLine];
    
    
    meilizhiView = [self createUntilView:CGRectMake((self.view.width-3)/3, sperLine.bottom, (self.view.width-3)/3, bottomView.height-sperLine.bottom) color:RGBCOLOR(255, 133, 161) desc:@"魅力值" value:@"0"];
    meilizhiView.center = CGPointMake(kMainScreenWidth / 2, CGRectGetMaxY(wealthValueBtn.frame) + 15 + 25.5);
    [bottomView addSubview:meilizhiView];
    
    UIView *mSperLine2 = [[UIView alloc] initWithFrame:CGRectMake(meilizhiView.right, sperLine.bottom+(bottomView.height-sperLine.bottom-57)/2, kLineWidth, 57)];
    [bottomView addSubview:mSperLine2];

    
    activeView = [self createUntilView:CGRectMake((self.view.width-3)/3 * 2, sperLine.bottom, (self.view.width-3)/3, bottomView.height-sperLine.bottom) color:RGBCOLOR(232, 179, 115) desc:@"活跃值" value:@"0"];
    activeView.center = CGPointMake(kMainScreenWidth - 63, CGRectGetMaxY(wealthValueBtn.frame) + 15 + 25.5);
    [bottomView addSubview:activeView];
    
    
}


- (UIView *)createUntilView:(CGRect)aRect
                      color:(UIColor*)aColor
                       desc:(NSString *)aDesc
                      value:(NSString *)aValue
{
    UIView *untilView = [[UIView alloc] initWithFrame:aRect];
    CGSize size = [aDesc sizeWithFont:kFont12];
    CGSize valuesize = [aValue sizeWithFont:[UIFont systemFontOfSize:32]];
    int offsetx = (aRect.size.width-8-size.width-2)/2;
    int offsety = (aRect.size.height-size.height-valuesize.height-2)/2;
    UIView *colorview = [[UIView alloc] initWithFrame:CGRectMake(offsetx, offsety+4, 8, 8)];
    colorview.layer.cornerRadius = 4.0f;
    colorview.backgroundColor = aColor;
    [untilView addSubview:colorview];
    
    UILabel *tLabel = [self.view labelWithFrame:CGRectMake(colorview.right+1, offsety, size.width+1, size.height) text:aDesc textFont:kFont12 textColor:RGBCOLOR(153, 153, 153)];
    [untilView addSubview:tLabel];
    
    UILabel *valueLabel = [self.view labelWithFrame:CGRectMake(10, tLabel.bottom+2, aRect.size.width-20, valuesize.height) text:aValue textFont:[UIFont systemFontOfSize:32] textColor:RGBCOLOR(153, 153, 153)];
    valueLabel.tag = 100;
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [untilView addSubview:valueLabel];
    
    return untilView;
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
