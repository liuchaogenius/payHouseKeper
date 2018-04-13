//
//  DongBiViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "DongBiViewController.h"
#import "PersonInfoDongBiCell.h"
#import "PersonInfoManager.h"
#import "PersonInfoManager.h"
#import "WXPayService.h"
#import "ZFBPayService.h"
#import "RMStore.h"
#import "UIViewAdaptive.h"
#import "ApplePayService.h"


#define kDBUntilViewWidth 80
#define kDBUntilViewHeight 70
@interface DongBiViewController () <UITableViewDelegate,UITableViewDataSource,RMStoreObserver>
{
    UIView *headview;
    int paybuttonTop;
    RechargeData *payChargeData;
}
@property (nonatomic, strong) UITableView *tableview;
//@property (nonatomic) NSString *moneyCount;
@property (nonatomic, strong) NSMutableArray *dataArry;
@property (nonatomic, strong) UIButton *bottomBt;
@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic, strong) WXPayService *wxpservice;
@property (nonatomic, strong) UIButton *wxzfBt;
@property (nonatomic, strong) UIButton *zfbBt;
@property (nonatomic, strong) UIButton *appleBt;
@property (nonatomic) int payTpye;
@property (nonatomic, strong) NSMutableArray *viewArry;
@property (nonatomic, strong) UILabel *moneyCountLabel;
@property (nonatomic, strong) NSString *supportPayType; //1:苹果支付  2、微信支付+支付宝支付   3、苹果支付+微信支付+支付宝支付
//@property (nonatomic) UILabel *headLabel;
@property (nonatomic, strong) NSArray *appleProductIds;
@property (nonatomic, strong) NSArray *invalidProductIds;
@property (nonatomic) BOOL hasRequestedProducts;//为了用户体验，只向appstore请求一次Product Ids
@property (nonatomic) BOOL isApplePaying;//正在调用苹果支付
@property (nonatomic, strong) ChongzhiDBData *appleBuyData;
@end

@implementation DongBiViewController
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.baseRatio = RatioBaseOn_6_ScaleFor5;
        self.hasRequestedProducts = NO;
        self.isApplePaying = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"我的充值"];
    self.view.backgroundColor = kViewBackgroundHexColor;
    self.payTpye = 10;
    _wxpservice = [WXPayService shareWXPayService];
    self.manager = [[PersonInfoManager alloc] init];
    //    self.viewArry = [NSMutableArray arrayWithCapacity:0];
    self.supportPayType = [DDSystemInfoManager sharedInstance].supportPayType;
    [self createTableview];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RMStore defaultStore] addStoreObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RMStore defaultStore] removeStoreObserver:self];
}
- (void)firstMovingToParentvc
{
    [self.view makeCenterToastActivity];
    WeakSelf(self);
    [self.manager requestRechargeList:0 completeBock:^(RechargeDataList *dataList) {
        [weakself.view hideToastActivity];
        weakself.dataArry = dataList.datalist;
        weakself.appleProductIds = dataList.appleItemIds;
        [weakself.tableview reloadData];
        //        [weakself addHeadView];
        //        [weakself addBuyView];
        //        [weakself addPayButton];
    }];
}


- (void)createTableview
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kView_Height) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource =  self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableview.tableHeaderView = [self getTableviewHeadView];
    self.tableview.tableFooterView = [UIView new];
    [self.view addSubview:self.tableview];
}

- (UIView *)getTableviewHeadView
{
    headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 215)];
    headview.backgroundColor = kcolorWhite;
    
    UIView *titlBgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 118)];
    titlBgview.backgroundColor = RGBCOLOR(33, 235, 190);
    [headview addSubview:titlBgview];
    
    self.moneyCountLabel = [self.view labelWithFrame:CGRectMake(0, (titlBgview.height-38-10-20)/2, headview.width, 38) text:[NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].moneyCount] textFont:[UIFont systemFontOfSize:36] textColor:kcolorWhite];
    self.moneyCountLabel.textAlignment = NSTextAlignmentCenter;
    [titlBgview addSubview:self.moneyCountLabel];
    
    UILabel *titleLabel = [self.view labelWithFrame:CGRectMake(0, self.moneyCountLabel.bottom+10, headview.width, 20) text:@"我的咚币" textFont:kFont18 textColor:kcolorWhite];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titlBgview addSubview:titleLabel];
    if ([self.supportPayType isEqualToString:@"1"])//苹果支付
    {
        self.payTpye = 9;
        UILabel *appleLabel =  [self.view labelWithFrame:CGRectMake(16, titlBgview.bottom, self.view.width-32, 48) text:@" " textFont:kFont15 textColor:RGBCOLOR(0x66, 0x66, 0x66)];
        [headview addSubview:appleLabel];
        headview.height = 164;
    }
    else
    {
        self.wxzfBt = [self.view buttonWithFrame:CGRectMake(28, titlBgview.bottom+26, (self.view.width-28*2-25)/2, 44) titleFont:[UIFont systemFontOfSize:15] titleStateNorColor:RGBCOLOR(33, 235, 190) titleStateNor:@"微信支付"];
        self.wxzfBt.backgroundColor = RGBCOLOR(33, 235, 190);
        self.wxzfBt.layer.cornerRadius = 22.0f;
        [self.wxzfBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
        //    self.wxzfBt.layer.cornerRadius = 22.0f;
        //    self.wxzfBt.backgroundColor = kcolorWhite;
        self.wxzfBt.layer.borderWidth = kLineWidth;
        self.wxzfBt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
        [self.wxzfBt addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
        self.wxzfBt.tag = 10;
        [headview addSubview:self.wxzfBt];
        
        
        self.zfbBt = [self.view buttonWithFrame:CGRectMake(self.wxzfBt.right+25, self.wxzfBt.top, (self.view.width-28*2-25)/2, 44) titleFont:[UIFont systemFontOfSize:15] titleStateNorColor:RGBCOLOR(33, 235, 190) titleStateNor:@"支付宝支付"];
        self.zfbBt.layer.cornerRadius = 22.0f;
        self.zfbBt.backgroundColor = kcolorWhite;
        self.zfbBt.layer.borderWidth = kLineWidth;
        self.zfbBt.tag = 11;
        self.zfbBt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
        [self.zfbBt addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:self.zfbBt];
        
        if ([self.supportPayType isEqualToString:@"3"])//苹果支付+微信支付+支付宝支付
        {
            self.payTpye = 9;
            CGFloat btnWidth = (self.view.width-40-30)/3;
            self.appleBt = [self.view buttonWithFrame:CGRectMake(20, self.wxzfBt.top, btnWidth, 44) titleFont:[UIFont systemFontOfSize:15] titleStateNorColor:RGBCOLOR(33, 235, 190) titleStateNor:@"苹果支付"];
            [self.appleBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
            self.appleBt.layer.cornerRadius = 22.0f;
            self.appleBt.backgroundColor = RGBCOLOR(33, 235, 190);
            self.appleBt.layer.borderWidth = kLineWidth;
            self.appleBt.tag = 9;
            self.appleBt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
            [self.appleBt addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
            [headview addSubview:self.appleBt];
            
            self.wxzfBt.frame = CGRectMake(self.appleBt.right+15, self.wxzfBt.top, btnWidth, self.wxzfBt.height);
            [self.wxzfBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
            self.wxzfBt.backgroundColor =kcolorWhite;
            
            self.zfbBt.frame = CGRectMake(self.wxzfBt.right+15, self.wxzfBt.top, btnWidth, self.wxzfBt.height);
        }
        
    }
    
    [headview viewAddBottomLine];
    return headview;
}

- (UIView *)getPayView:(CGRect)frame
{
    UIView *payView  = [[UIView alloc]initWithFrame:frame];
    
    return payView;
    
}
//- (void)addBuyView
//{
//    int startx = 20;
//    int starty = headview.bottom+30;
//    int space = (self.view.width-40-kDBUntilViewWidth*3)/2;
//    [self.viewArry removeAllObjects];
//    for(int i=1; i<=self.dataArry.count; i++)
//    {
//        int y = (i-1)%3;
//        if(y == 0)
//        {
//            startx = 20;
//        }
//        RechargeData *rData = [self.dataArry objectAtIndex:(i-1)];
//        CGRect rect = CGRectZero;
//        if(i == 1)
//        {
//            rect = CGRectMake(startx, starty, kDBUntilViewWidth, kDBUntilViewHeight);
//        }
//        else
//        {
//            rect = CGRectMake(startx, starty, kDBUntilViewWidth, kDBUntilViewHeight);
//        }
////        UIView *view = [self createBuyUnitViewRect:rect isFirstBuy:NO moneyCount:rData.title presentCount:rData.description price:rData.price];
//
//
//        UIButton *view = [self createBuyUnitViewRect:rect isFirstBuy:NO moneyCount:20 presentCount:[rData.freeNum intValue] price:rData.price];
//        view.tag = i-1;
//        [view addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:view];
//        startx  = view.right+space;
//        if(i != 1 && (i+1)%3 == 0 && (i+1) < self.dataArry.count)
//        {
//            starty = view.bottom+10;
//        }
//        [self.viewArry addObject:view];
//    }
//    paybuttonTop = starty+kDBUntilViewHeight;
//}
//
//- (void)clickItem:(UIButton *)aBt
//{
//    RechargeData *data = [self.dataArry objectAtIndex:aBt.tag];
//    payChargeData = data;
//    aBt.backgroundColor = kFcolorFontGreen;
//    for(UIButton *bt in self.viewArry)
//    {
//        if(bt.tag != aBt.tag)
//        {
//            bt.backgroundColor = self.view.backgroundColor;
//        }
//    }
//}
//
//- (UIButton *)createBuyUnitViewRect:(CGRect)aRect
//                   isFirstBuy:(BOOL)aIsFirstBuy
//               moneyCount:(int)aMoneyCount
//             presentCount:(int)aPresentCount
//                    price:(int)aPrice
//{
//    UIButton *unitView = [[UIButton alloc] initWithFrame:aRect];
//    unitView.layer.cornerRadius = 5.0f;
//    unitView.layer.borderWidth = kLineWidth;
//    unitView.layer.borderColor = kFcolorFontGreen.CGColor;
//    int offsety = (aRect.size.height - (16+4+12+6+14))/2;
//    NSString *strTitle = [NSString stringWithFormat:@"%d咚币",aMoneyCount];
//    UILabel *titleLabel = [self.view labelWithFrame:CGRectMake(0, offsety, unitView.width, 16) text:strTitle textFont:kFont14 textColor:kColorBlack];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [unitView addSubview:titleLabel];
//
//    if(aPresentCount > 0)
//    {
//        NSString *strPresent = [NSString stringWithFormat:@"送%d咚币",aPresentCount];;
//        UILabel *presentLabel = [self.view labelWithFrame:CGRectMake(0, titleLabel.bottom+4, unitView.width, 12) text:strPresent textFont:kFont10 textColor:RGBCOLOR(178, 172, 59)];
//        presentLabel.textAlignment = NSTextAlignmentCenter;
//        [unitView addSubview:presentLabel];
//    }
//
//    NSString *strPirce = [NSString stringWithFormat:@"¥%d元",aPrice];
//    UILabel *priceLabel = [self.view labelWithFrame:CGRectMake(0, titleLabel.bottom+4+12+6, unitView.width, 14) text:strPirce textFont:kFont14 textColor:RGBCOLOR(102, 102, 102)];
//    priceLabel.textAlignment = NSTextAlignmentCenter;
//    [unitView addSubview:priceLabel];
//
//    return unitView;
//}


//- (void)addPayButton
//{
//    self.wxzfBt = [self.view buttonWithFrame:CGRectMake(28, paybuttonTop+30, (self.view.width-28*2-25)/2, 44) titleFont:[UIFont systemFontOfSize:17] titleStateNorColor:RGBCOLOR(33, 235, 190) titleStateNor:@"微信支付"];
//    self.wxzfBt.layer.cornerRadius = 22.0f;
//    self.wxzfBt.backgroundColor = kcolorWhite;
//    self.wxzfBt.layer.borderWidth = kLineWidth;
//    self.wxzfBt.tag = 11;
//    self.wxzfBt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
//    [self.wxzfBt addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
//    self.wxzfBt.tag = 10;
//    [self.view addSubview:self.wxzfBt];
//
//
//    self.zfbBt = [self.view buttonWithFrame:CGRectMake(self.wxzfBt.right+25, paybuttonTop+30, (self.view.width-28*2-25)/2, 44) titleFont:[UIFont systemFontOfSize:17] titleStateNorColor:RGBCOLOR(33, 235, 190) titleStateNor:@"支付宝支付"];
//    self.zfbBt.layer.cornerRadius = 22.0f;
//    self.zfbBt.backgroundColor = kcolorWhite;
//    self.zfbBt.layer.borderWidth = kLineWidth;
//    self.zfbBt.tag = 11;
//    self.zfbBt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
//    [self.zfbBt addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.zfbBt];
//
//}

- (void)changePayType:(UIButton *)aBt
{
    self.payTpye = (int)aBt.tag;
    if(aBt.tag == 10)//微信
    {
        self.wxzfBt.backgroundColor = RGBCOLOR(33, 235, 190);
        [self.wxzfBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
        
        [self.zfbBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.zfbBt.backgroundColor = kcolorWhite;
        
        [self.appleBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.appleBt.backgroundColor = kcolorWhite;
    }
    else if(aBt.tag == 11)//支付宝
    {
        self.zfbBt.backgroundColor = RGBCOLOR(33, 235, 190);
        [self.zfbBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
        
        [self.wxzfBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.wxzfBt.backgroundColor = kcolorWhite;
        
        [self.appleBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.appleBt.backgroundColor = kcolorWhite;
    }
    else if(aBt.tag == 9)//苹果
    {
        self.appleBt.backgroundColor = RGBCOLOR(33, 235, 190);
        [self.appleBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
        
        [self.wxzfBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.wxzfBt.backgroundColor = kcolorWhite;
        
        [self.zfbBt setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        self.zfbBt.backgroundColor = kcolorWhite;
    }
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 60.0f;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonInfoDongBiCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"chognzhidongbicell"];
    if(!cell)
    {
        cell = [[PersonInfoDongBiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chognzhidongbicell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self configCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)configCell:(PersonInfoDongBiCell *)aCell cellForRowAtIndexPath:(NSIndexPath *)aIndexPath
{
    if(aIndexPath.row < self.dataArry.count)
    {
        RechargeData *rData = [self.dataArry objectAtIndex:aIndexPath.row];
        ChongzhiDBData *data = [[ChongzhiDBData alloc] init];
        if(rData.desc)
        {
            data.dataDesc = rData.desc;
        }
        data.RMBCount = [NSString stringWithFormat:@"%.2f",rData.price];
        data.dataId = rData.dataID;
        data.czdbNum = [NSString stringWithFormat:@"%@",rData.title];
        data.appleProductId = rData.appleItemId;
        [aCell setCellData:data];
        WeakSelf(self);
        [aCell setBuyButtonClickBlock:^(ChongzhiDBData *data) {
            if(weakself.payTpye == 10)
            {
                [weakself wxPayOrder:data];
            }
            else if(weakself.payTpye == 11)
            {
                [weakself aliPayOrder:data];
            }
            else if (weakself.payTpye == 9)
            {
                [weakself applePayOrder:data];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark 调用微信支付
- (void)wxPayOrder:(ChongzhiDBData *)aData
{
    WeakSelf(self);
    [self.view makeToast:@"支付中..."];
    [self.wxpservice requestWXPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(WXpayResultType ret) {
        MLOG(@"payorder");
        if(ret == WXPay_success)
        {
            [weakself getCurrentUserMoney];
            
        }
        else
        {
            [weakself.view makeToast:@"支付失败" duration:1.f position:CSToastPositionCenter];
        }
        //        [weakself.wxpservice WXPay:orderData];
    }];
    
    //    [self.wxpservice requestWXPayOrderItemId:aData.dataId amount:aData.czdbNum type:@"1" completeBlock:^(WXPayOrderData *orderData) {
    //        MLOG(@"payorder");
    //    }];
}

- (void)aliPayOrder:(ChongzhiDBData *)aData
{
    WeakSelf(self);
    [self.view makeToast:@"支付中"];
    [[ZFBPayService shareZFBPayService] requestAliPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(AlipayResultType ret) {
        if(ret == alipay_success)
        {
            [weakself getCurrentUserMoney];
        }
        else
        {
            [weakself.view makeToast:@"支付失败" duration:1.f position:CSToastPositionCenter];
        }
    }];
}

//	com.intalk.recharge.dongbi10
- (void)applePayOrder:(ChongzhiDBData *)aData
{
    self.appleBuyData = aData;
    if([RMStore canMakePayments])
    {
        if (self.isApplePaying == NO)
        {
            [SVProgressHUD showWithStatus:@"正在连接苹果商店"];
            self.isApplePaying = YES;
            if (self.hasRequestedProducts == NO)
            {
                [self requestProducts];
                self.hasRequestedProducts = YES;
            }
            else
            {
                [self addPayment];
            }
        }
       
    }
    else
    {
        [self.view makeToast:@"用户不允许内购" duration:1.f position:CSToastPositionCenter];
    }
}
- (void)verifyAppleReceipt:(NSString *)receipt
{
    WeakSelf(self);
    [[ApplePayService shareApplePayService] requestApplePayVerify:self.appleBuyData.appleReceipt appleitemid:self.appleBuyData.appleProductId amount:@"1"  completeBlock:^(ApplePayResultType ret) {
        if(ret == applepay_success)
        {
        }
        else
        {
            [weakself.view makeToast:@"支付失败" duration:1.f position:CSToastPositionCenter];
        }
        [weakself performSelector:@selector(getCurrentUserMoney) withObject:nil afterDelay:1];

    }];
}

- (void)requestProducts
{
    NSArray *products = self.appleProductIds;
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        self.invalidProductIds = invalidProductIdentifiers;
        [self addPayment];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:@"连接失败，请重试" duration:1.f position:CSToastPositionCenter];
        
        self.isApplePaying = NO;
    }];
    
}

- (void)addPayment
{
    if ([self.invalidProductIds containsObject:self.appleBuyData.appleProductId])
    {
        [SVProgressHUD dismiss];
        [self.view makeToast:@"该充值金额不支持苹果内支付" duration:1.f position:CSToastPositionCenter];
        self.isApplePaying = NO;
    }
    else
    {
        [[RMStore defaultStore] addPayment:self.appleBuyData.appleProductId success:^(SKPaymentTransaction *transaction) {
            self.isApplePaying = NO;
            [SVProgressHUD dismiss];
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSString *errMsg = error.localizedDescription;
            if ((error.code == 2)&&[error.domain isEqualToString:@"SKErrorDomain"])
            {
                [SVProgressHUD dismiss];
                
            }
            else
            {
                errMsg = @"连接苹果服务失败,请重试";
                [SVProgressHUD dismiss];
                [self.view makeToast:errMsg duration:1.f position:CSToastPositionCenter];
            }

            self.isApplePaying = NO;
        }];
    }
}
#pragma mark RMStoreObserver
/* ======= 请求Product Id ======== */
- (void)storeProductsRequestFinished:(NSNotification*)notification
{
    self.invalidProductIds = [notification.userInfo objectForKey:@"invalidProductIdentifiers"];
}
- (void)storeProductsRequestFailed:(NSNotification*)notification
{
    self.invalidProductIds = [notification.userInfo objectForKey:@"invalidProductIdentifiers"];
}


/* ======= 交易 ======== */
- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:0];
    self.appleBuyData.appleReceipt = encodeStr;
    [self verifyAppleReceipt:encodeStr];
}

- (void)getCurrentUserMoney
{
    WeakSelf(self);
    [self.manager requestMyWallet:^(MyWalletData *data) {
        [weakself.view hideToastActivity];
        [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
        weakself.moneyCountLabel.text = [NSString stringWithFormat:@"%d",(int)data.moneyCount];
    }];
}

- (void)getCurrentMoney
{
    WeakSelf(self);
    [self.manager requestMyWallet:^(MyWalletData *data) {
        weakself.moneyCountLabel.text = [NSString stringWithFormat:@"%d",(int)data.moneyCount];
    }];
    
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
