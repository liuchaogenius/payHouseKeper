//
//  MyWalletViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MyWalletViewController.h"
#import "PersonInfoManager.h"
#import "WXPayService.h"
#import "BuyDBOrderView.h"
#import "ExchangeDongbiViewController.h"
#import "ChanageCashViewController.h"
#import "DDSystemInfoManager.h"


@interface MyWalletViewController ()
{
    

}

@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic, strong) MyWalletData *walletData;
@property (nonatomic, strong) WXPayService *payService;
@property (nonatomic, strong) NSString *strChargeCount;
@property (nonatomic, strong) UILabel *zuanshiCountLabel;
@property (nonatomic, strong) NSString *strZuanshiCount;
@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[PersonInfoManager alloc] init];
    [self settitleLabel:@"我的收益"];
    self.payService = [[WXPayService alloc] init];
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 115)];
    headview.backgroundColor = kFcolorFontGreen;
    [self.view addSubview:headview];
    
    
    
//    UIImage *imgIcon = [UIImage imageNamed:@"dongbiIcon"];
//    UIImageView *iconImgview = [[UIImageView alloc] initWithImage:imgIcon];
//    CGFloat offsetx = (self.view.width-25-32-3)/2;
//    iconImgview.frame = CGRectMake(offsetx, 43, 25, 18);
//    iconImgview.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:iconImgview];
    
    int offsetY = (headview.height-38-15-20)/2;
    self.strZuanshiCount = [NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].shellCount];
    self.zuanshiCountLabel = [self.view labelWithFrame:CGRectMake(0, offsetY, kMainScreenWidth, 38) text:self.strZuanshiCount textFont:[UIFont systemFontOfSize:36] textColor:kcolorWhite];
    self.zuanshiCountLabel.textAlignment = NSTextAlignmentCenter;
    [headview addSubview:self.zuanshiCountLabel];
    
    UILabel *zuanshiDesc = [self.view labelWithFrame:CGRectMake(0, self.zuanshiCountLabel.bottom+15, kMainScreenWidth, 20) text:@"我的咚果" textFont:kFont18 textColor:kcolorWhite];
    zuanshiDesc.textAlignment = NSTextAlignmentCenter;
    [headview addSubview:zuanshiDesc];

    
//    UILabel *charageDesc = [self.view labelWithFrame:CGRectMake(0, zuanshiCount.bottom+32, kMainScreenWidth, 40) text:@"可兑换收益(元)" textFont:[UIFont systemFontOfSize:16] textColor:kFColorFontBlack];
//    charageDesc.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:charageDesc];
//    
//    UILabel *charageCountLabel = [self.view labelWithFrame:CGRectMake(0, zuanshiDesc.bottom+16, kMainScreenWidth, 40) text:strChargeCount textFont:[UIFont systemFontOfSize:36] textColor:kFcolorFontGreen];
//    charageCountLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:charageCountLabel];

    UIButton *chongzhiBt = [[UIButton alloc] initWithFrame:CGRectMake(20, headview.bottom+37, (self.view.width-40), 44)];
    chongzhiBt.titleLabel.font = kFont17;
    [chongzhiBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [chongzhiBt setTitle:@"提现" forState:UIControlStateNormal];
    chongzhiBt.layer.cornerRadius = 22.0f;
    chongzhiBt.layer.masksToBounds = YES;
    chongzhiBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    [chongzhiBt addTarget:self action:@selector(payMoneyItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chongzhiBt];
    if ([DDSystemInfoManager sharedInstance].isOn)
    {
        chongzhiBt.hidden = YES;
    }
    
    
    UIButton *shouyiBt = [[UIButton alloc] initWithFrame:CGRectMake(20, chongzhiBt.bottom+16, chongzhiBt.width, 44)];
    shouyiBt.titleLabel.font = kFont17;
    [shouyiBt setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
    [shouyiBt setTitle:@"兑换咚币" forState:UIControlStateNormal];
    shouyiBt.layer.cornerRadius = 22.0f;
    shouyiBt.layer.borderColor = kFcolorFontGreen.CGColor;
    shouyiBt.layer.borderWidth = kLineWidth;
    shouyiBt.backgroundColor = kcolorWhite;
    [shouyiBt addTarget:self action:@selector(conMoneyCountItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shouyiBt];
    
    
    UILabel *desc = [self.view labelWithFrame:CGRectMake(0, self.view.height-17-40, kMainScreenWidth, 40) text:@"收到礼物会自动兑换成咚果\n咚果可以用来提现，也可以用来兑换咚币" textFont:[UIFont systemFontOfSize:12] textColor:[UIColor colorWithHexValue:0xbbbbbb]];
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 2;
    [self.view addSubview:desc];
    
}

- (void)firstMovingToParentvc
{
    WeakSelf(self);
    [self.view makeCenterToastActivity];
    [self.manager requestMyWallet:^(MyWalletData *data) {
        [weakself.view hideToastActivity];
        weakself.walletData = data;
        [weakself reloadViewData];
    }];
}

- (void)reloadViewData
{
    self.zuanshiCountLabel.text = [NSString stringWithFormat:@"%d",(int)self.walletData.shellCount];
    
}

#pragma mark 兑换事件

- (void)conMoneyCountItem
{
    ExchangeDongbiViewController *vc = [[ExchangeDongbiViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
//    __block BuyDBOrderView *orderview = [[BuyDBOrderView alloc] initWithFrame:self.view.bounds];
//    WeakSelf(self);
//    [orderview setBGColor:[UIColor blackColor] alpha:0.5];
//    [orderview setConvRule:self.walletData.rule];
//    [orderview createOrderview:[NSString stringWithFormat:@"%d",(int)self.walletData.moneyCount] clickBlock:^(int buttonTag, NSString *covCount) {
//        if(buttonTag == buttonItem_ok)
//        {
//            [weakself conversionAmount:covCount orderView:orderview];
//        }
//        else
//        {
//            orderview.hidden = YES;
//            [orderview removeSubviews];
//            orderview = nil;
//        }
//    }];
//    [self.view addSubview:orderview];
}

- (void)payMoneyItem
{
    ChanageCashViewController *vc = [[ChanageCashViewController alloc] init];
//    vc.cashRate = self.walletData.cashRate;
    [self.navigationController pushViewController:vc animated:YES];
}

//#pragma mark 兑换接口
//- (void)conversionAmount:(NSString *)aAmcount
//               orderView:(BuyDBOrderView*)aOrderView
//{
//    WeakSelf(self);
//    if([aAmcount intValue]>self.walletData.shellCount)
//    {
//        aOrderView.hidden = YES;
//        [aOrderView removeSubviews];
//        aOrderView = nil;
//        [self.view makeToast:@"咚币不足"];
//    }
//    else
//    {
//        [self.manager requestMyConversion:[aAmcount intValue] completeBlock:^(int moneyCount, int shellCount) {
//            if(moneyCount>-1)
//            {
//                weakself.strZuanshiCount = [NSString stringWithFormat:@"%d",moneyCount];
//                weakself.zuanshiCountLabel.text = weakself.strZuanshiCount;
//                aOrderView.hidden = YES;
//                [aOrderView removeSubviews];
//                [[UserInfoData shareUserInfoData] setCurrentMoneyCount:moneyCount];
//            }
//            if(shellCount > -1)
//            {
//                [[UserInfoData shareUserInfoData] setCurrentShellCount:shellCount];
//            }
//        }];
//    }
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.strZuanshiCount = [NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].shellCount];
    self.zuanshiCountLabel.text = self.strZuanshiCount;
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
