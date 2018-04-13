//
//  OtherPersonInfoViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "OtherPersonInfoViewController.h"
#import "PersonInfoManager.h"
#import "PersonInfoManager.h"

@interface OtherPersonInfoViewController ()
{
    NSString *strHeadUrl;
    NSString *strNick;
    int sexType;
    NSString *strUserid;
    NSString *strSingContent;
    BOOL isVip;
    int vipLevel;
    UIView *headview;
    UIView *vipview;
    NSString *strOtherUserid;
    PersonInfoManager *manager;
    
}
@property (nonatomic, strong)UserInfoData *otherInfo;
@end

@implementation OtherPersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    manager = [[PersonInfoManager alloc] init];
    [self createHeadview];
    [self createVIP];
    [self addBottomButton];
}

- (void)setUserAccid:(NSString *)aAccid
{
    strOtherUserid = aAccid;
}

- (void)firstMovingToParentvc
{
//    WeakSelf(self);
//    [manager requestOterPersonInfo:strOtherUserid completeBlock:^(UserInfoData *data) {
//       if(data)
//       {
//           weakself.otherInfo = data;
//           [weakself reloadUserview];
//       }
//    }];
}

- (void)reloadUserview
{
    strHeadUrl = self.otherInfo.strHeadUrl;
    strNick = self.otherInfo.strUserNick;
    sexType = self.otherInfo.sexType;
    strUserid = self.otherInfo.strUserId;
    strSingContent = self.otherInfo.strUserMsg;
    isVip = self.otherInfo.isVip;
    vipLevel = self.otherInfo.userLeval;
    [self.view removeSubviews];
    [self createHeadview];
    [self createVIP];
    [self addBottomButton];
}

- (void)createHeadview
{
    headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 252)];
    headview.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    UIImageView *headImgview = [[UIImageView alloc] initWithFrame:CGRectIntegral(CGRectMake((kMainScreenWidth-70)/2, (headview.height-164)/2, 70, 70))];
    
    [headImgview sd_setImageWithURL:[NSURL URLWithString:strHeadUrl] placeholderImage:[UIImage imageNamed:@"personInfoheadimg"]];
    [headview addSubview:headImgview];
    
    if([UserInfoData shareUserInfoData].isVip)
    {
        UIImage *vipImg = [UIImage imageNamed:@"personVip"];
        UIImageView *vipImgview = [[UIImageView alloc] initWithFrame:CGRectMake(headImgview.right-vipImg.size.width, headImgview.bottom-vipImg.size.height, vipImg.size.width, vipImg.size.height)];
        [vipImgview setImage:vipImg];
        [headview addSubview:vipImgview];
    }
    NSString *name = strNick;
    CGSize namesize = [name sizeWithFont:kFont17];
    int offsetx = (kMainScreenWidth-namesize.width-2-36-2)/2;
    UILabel *namelabel = [self.view labelWithFrame:CGRectMake(offsetx, headImgview.bottom+15, namesize.width+1, 17) text:name textFont:kFont17 textColor:kcolorWhite];
    [headview addSubview:namelabel];
    
    
    UIButton *sexbt = [self.view buttonWithFrame:CGRectMake(namelabel.right+1, namelabel.top, 36, 17) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [sexbt setImage:[UIImage imageNamed:@"personseximg"] forState:UIControlStateNormal];
    [headview addSubview:sexbt];
    
    NSString *userid = [NSString stringWithFormat:@"ID:%@",strUserid];
    UILabel *idlabel = [self.view labelWithFrame:CGRectMake(0, sexbt.bottom+8, kMainScreenWidth, 12) text:userid textFont:kFont12 textColor:kcolorWhite];
    idlabel.textAlignment = NSTextAlignmentCenter;
    [headview addSubview:idlabel];
    
    UILabel *singLabel = [self.view labelWithFrame:CGRectMake(40, idlabel.bottom+10, kMainScreenWidth-80, 40) text:strSingContent textFont:kFont14 textColor:kcolorWhite];
    [headview addSubview:singLabel];
    [self.view addSubview:headview];
}

- (void)createVIP
{
    UIView *spaceview = [[UIView alloc] initWithFrame:CGRectMake(0, headview.bottom, self.view.width, 20)];
    [self.view addSubview:spaceview];
    
    vipview = [[UIView alloc] initWithFrame:CGRectMake(0, spaceview.bottom, self.view.width, 110)];
    [self.view addSubview:vipview];
    
    UILabel *titlLabel = [vipview labelWithFrame:CGRectMake(16, 20, kMainScreenWidth-15, 15) text:@"账号等级" textFont:kFont14 textColor:[UIColor colorWithHexValue:0x333333]];
    [vipview addSubview:titlLabel];
    
    UIImage *vipImg = nil;
    NSString *vipDesc = nil;
    UIColor *vipFontcolor = nil;
    if(isVip)
    {
        vipImg = [UIImage imageNamed:@"personVip"];
        vipDesc = @"VIP会员";
        vipFontcolor = [UIColor colorWithHexValue:0x00d898];
    }
    else
    {
        vipImg = [UIImage imageNamed:@"persionNoVip"];
        vipDesc = @"请开通vip";
        vipFontcolor = [UIColor colorWithHexValue:0x999999];
    }
    
    UIImageView *vipImgview = [[UIImageView alloc] initWithFrame:CGRectMake(titlLabel.left, 50, 44, 44)];
    [vipImgview setImage:vipImg];
    [vipview addSubview:vipImgview];
    
    UILabel *vipDescLabel = [vipview labelWithFrame:CGRectMake(vipImgview.right+15, vipImgview.top+(vipImgview.height-17)/2, 90, 18) text:vipDesc textFont:kFont17 textColor:vipFontcolor];
    [vipview addSubview:vipDescLabel];
    
    UIImage *leveImg = [UIImage imageNamed:@"vipLevelimg"];
    UIImageView *levelImgview = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth-125-44, vipImgview.top, 44, 44)];
    [levelImgview setImage:leveImg];
    [vipview addSubview:levelImgview];
    
    NSString *strlevel = [NSString stringWithFormat:@"Lv.%d",vipLevel];
    UILabel *levelLabel = [vipview labelWithFrame:CGRectMake(levelImgview.right+15, levelImgview.top+(levelImgview.height-17)/2, 90, 18) text:strlevel textFont:kFont17 textColor:[UIColor colorWithHexValue:0x00d898]];
    [vipview addSubview:levelLabel];
    
    [vipview viewAddTopLine];
    [vipview viewAddBottomLine];
    
    UIButton *vipBt = [vipview buttonWithFrame:CGRectMake(0, 0, vipDescLabel.right, vipview.height) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    vipBt.tag = 0;
    [vipBt addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
    [vipview addSubview:vipBt];
    
    UIButton *levelBt = [vipview buttonWithFrame:CGRectMake(vipDescLabel.right, 0, vipview.width-vipDescLabel.right, vipview.height) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    levelBt.tag = 1;
    [levelBt addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
    [vipview addSubview:levelBt];
}

- (void)buttonClickItem:(UIButton *)aBt
{
}

- (void)addBottomButton
{
    UIButton *shouyiBt = [[UIButton alloc] initWithFrame:CGRectMake(20, vipview.bottom+30, (self.view.width-40), 44)];
    shouyiBt.titleLabel.font = kFont17;
    [shouyiBt setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
    [shouyiBt setTitle:@"发起视频通话" forState:UIControlStateNormal];
    shouyiBt.layer.cornerRadius = 22.0f;
    shouyiBt.layer.borderColor = kFcolorFontGreen.CGColor;
    shouyiBt.layer.borderWidth = kLineWidth;
    shouyiBt.backgroundColor = kcolorWhite;
    shouyiBt.tag = 0;
    [self.view addSubview:shouyiBt];
    
    
    UIButton *chongzhiBt = [[UIButton alloc] initWithFrame:CGRectMake(20, shouyiBt.bottom+16, shouyiBt.width, 44)];
    chongzhiBt.titleLabel.font = kFont17;
    [chongzhiBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [chongzhiBt setTitle:@"发消息" forState:UIControlStateNormal];
    chongzhiBt.layer.cornerRadius = 22.0f;
    chongzhiBt.layer.masksToBounds = YES;
    chongzhiBt.tag = 1;
    chongzhiBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    [self.view addSubview:chongzhiBt];
}

- (void)bottomButton:(UIButton *)aBt
{
    if(aBt.tag == 0)//发起视频
    {
    }
    else//发消息
    {
    }
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
