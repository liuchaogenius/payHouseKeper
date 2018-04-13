//
//  PersonVIPViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/8.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonVIPViewController.h"
#import "PersonVIPCell.h"
#import "PersonInfoManager.h"
#import "NSStringEX.h"
#import "BuyDBOrderView.h"
#import "ZFBPayService.h"
#import "WXPayService.h"
#import "SPActionSheet.h"
#import "RMStore.h"
#import "ApplePayService.h"
#import "TQActionSheet.h"

@interface PersonVIPViewController ()<UITableViewDelegate,UITableViewDataSource,SPActionSheetDelegate,RMStoreObserver, TQActionSheetDelegate>
{
    SPActionSheet *actionsheet;
    TQActionSheet *tqView;
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArry;
@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic, strong) VIPRechargeDataList *vipRechargeList;
@property (nonatomic, strong) BuyDBOrderView *orderview;
@property (nonatomic, strong) NSString *supportPayType; //1:苹果支付  2、微信支付+支付宝支付   3、苹果支付+微信支付+支付宝支付
@property (nonatomic, strong) NSArray *appleProductIds;
@property (nonatomic, strong) NSArray *invalidProductIds;
@property (nonatomic) BOOL hasRequestedProducts;//为了用户体验，只向appstore请求一次Product Ids
@property (nonatomic) BOOL isApplePaying;//正在调用苹果支付
@property (nonatomic, strong) BuyVIPData *appleBuyData;

@end

@implementation PersonVIPViewController
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.hasRequestedProducts = NO;
        self.isApplePaying = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.manager = [[PersonInfoManager alloc] init];
    [self settitleLabel:@"VIP会员"];
    self.supportPayType = [DDSystemInfoManager sharedInstance].supportPayType;
    [self createTableview];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self requestChargeList];
}

- (void)requestChargeList
{
    WeakSelf(self);
    [self.manager requestVIPRechargeList:^(VIPRechargeDataList *dataList) {
        
        [weakself.view hideToastActivity];
        weakself.vipRechargeList = dataList;
        weakself.vipName = weakself.vipRechargeList.vipName;
        // 会员价格清单
        weakself.dataArry = dataList.datalist;
        weakself.appleProductIds = dataList.appleItemIds;
        weakself.tableview.tableHeaderView = [weakself getTableviewHeadView];
        [weakself.tableview reloadData];
    }];
}

- (void)createTableview
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 1.5, kMainScreenWidth, kMainScreenHeight-65.5) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource =  self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableHeaderView = [self getTableviewHeadView];
//    self.tableview.tableFooterView = [self getTableviewFootView];
    [self.view addSubview:self.tableview];
}

- (UIView *)getTableviewHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 180)];
    UIImage *vipimg = [UIImage imageNamed:@"p_vip"];
    NSString *strIsVip = @"";
    
    if(_vipName && _vipName.length > 0)
    {
        strIsVip = [NSString stringWithFormat:@"%@", _vipName];
    }
    UIColor *vipFontColor = RGBCOLOR(239, 191, 43);
    if(![UserInfoData shareUserInfoData].isVip)
    {
        strIsVip = @"暂未开通";
        vipimg = IMG(@"not_vip");
        vipFontColor = RGBCOLOR(153, 153, 153);
    }
    
    UIImageView *vipimgview = [[UIImageView alloc] initWithFrame:CGRectMake((kMainScreenWidth-vipimg.size.width)/2, 20, vipimg.size.width, vipimg.size.height)];
    [vipimgview setImage:vipimg];
    [view addSubview:vipimgview];
    view.backgroundColor = [UIColor whiteColor];
    

    UILabel *deslabel = [self.view labelWithFrame:CGRectMake(0, vipimgview.bottom+20, kMainScreenWidth, 16) text:strIsVip textFont:kFont17 textColor:vipFontColor];
    deslabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:deslabel];
    int viewHeight = deslabel.bottom+30;
    if(self.vipRechargeList.isvip == YES)
    {
//        UILabel *xufeiLabel = [self.view labelWithFrame:CGRectMake(kLeftMragin, view.height-20-17, 44, 17) text:@"续费" textFont:kFont14 textColor:kFcolorFontGreen];
//        [view addSubview:xufeiLabel];
        NSString *strViplosstime = [NSString stringWithFormat:@"有效期至 %@",self.vipRechargeList.strVipLoseTime];
//        CGSize lsize = [strViplosstime sizeWithFont:kFont17];
        UILabel *vipLossTimeLabeldec = [self.view labelWithFrame:CGRectMake(0, deslabel.bottom+13, self.view.width, 20) text:strViplosstime textFont:kFont17 textColor:RGBCOLOR(153, 153, 153)];
        vipLossTimeLabeldec.textAlignment = NSTextAlignmentCenter;
        [view addSubview:vipLossTimeLabeldec];
        
//        CGSize tsize = [self.vipRechargeList.strVipLoseTime sizeWithFont:kFont14];
//        UILabel *vipLossTimeLabel = [self.view labelWithFrame:CGRectMake(view.width-kLeftMragin-tsize.width-1, vipLossTimeLabeldec.bottom+1, 130, 16) text:self.vipRechargeList.strVipLoseTime textFont:kFont14 textColor:kBlackColor];
//        vipLossTimeLabel.textAlignment = NSTextAlignmentRight;
//        [view addSubview:vipLossTimeLabel];
        viewHeight+=vipLossTimeLabeldec.height;
    }
    view.frame = CGRectMake(0, 0, self.view.width, viewHeight);
    return view;
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArry.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 68.0f;
    if(indexPath.row == (self.dataArry.count-1))
    {
        cellHeight = cellHeight+30+5;
    }
    else if(indexPath.row == self.dataArry.count)
    {
        cellHeight = 45;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.dataArry.count)
    {
        PersonVIPCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"PersonVIPCell"];
        if(!cell)
        {
            cell = [[PersonVIPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chognzhidongbicell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.imgH = YES;
        }
        
        [self configCellDataIndexPath:indexPath cell:cell];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"PersonVIPCellVIP"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonVIPCellVIP"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"会员特权";
        cell.textLabel.textColor = kBlackColor;
        cell.textLabel.font = kFont14;
        return cell;
    }
    return nil;
}

- (void)configCellDataIndexPath:(NSIndexPath *)indexPath cell:(PersonVIPCell *)aCell
{
    NSLog(@" self.dataArry====%@",  self.dataArry);
    
    if(indexPath.row < self.dataArry.count)
    {
        RechargeData *rData = [self.dataArry objectAtIndex:indexPath.row];
        BuyVIPData *data = [[BuyVIPData alloc] init];
        if(rData.isRec == 1)
        {
            data.isRecommend = YES;
        }
        if(indexPath.row == (self.dataArry.count-1))
        {
            data.isLasteCell = YES;
        }

        data.desc = rData.title;
        data.moneyCount = [NSString stringWithFormat:@"%.2f",rData.price];
        data.dataId = rData.dataID;
        data.appleProductId = rData.appleItemId;
        WeakSelf(self);
        [aCell setCellData:data buyItem:^(BuyVIPData *data) {
            [weakself buyButtonItem:data];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.dataArry.count)
    {
//        NSArray *titleArry = @[@"倒计时延长",@"视频连接特效",@"VIP特权身份",@"专属礼物",@"专属视频通道",@"优先匹配"];
//        actionsheet = [[SPActionSheet alloc] initWithTitle:@"特权详情" dismissMsg:@"知道了" delegate:self buttonTitles:titleArry];
//        actionsheet.titleColor = [UIColor blackColor];
//        actionsheet.dismissBtnColor = [UIColor whiteColor];
//        actionsheet.contentBtnColor = [UIColor grayColor];
//        actionsheet.dismissBackgroundBtnColor = kFcolorFontGreen;
//        [actionsheet show];
        
        NSArray *cellArr = @[@[@"特权",@"VIP",@"普通"], @[@"倒计时延长",@"180s",@"90s"], @[@"视频连接特效",@"gou",@"hui"], @[@"VIP特权身份",@"gou",@"hui"], @[@"VIP特权身份",@"gou",@"hui"], @[@"专属礼物",@"gou",@"hui"], @[@"专属视频通道",@"gou",@"hui"], @[@"优先匹配",@"gou",@"hui"]];
        
        tqView = [[TQActionSheet alloc] initWithTitle:@"特权详情" columnTitles:cellArr dismissMsg:@"知道了" delegate:self];
        
        [tqView show];
    }
}

- (void)didSelectActionSheetButton:(NSString *)title
{
    tqView.hidden = YES;
    [tqView removeFromSuperview];
    tqView = nil;
}

- (void)buyButtonItem:(BuyVIPData *)aData
{
    WeakSelf(self);
    if ([self.supportPayType isEqualToString:@"1"])//苹果支付
    {
        self.appleBuyData = aData;
        [self applePayOrder];
    }
    else if([self.supportPayType isEqualToString:@"2"])//微信支付+支付宝支付
    {
        self.orderview = [[BuyDBOrderView alloc] initWithFrame:self.view.bounds];
        [_orderview setBGColor:[UIColor blackColor] alpha:0.5];
        [_orderview createChongzhiView:aData.moneyCount clickBlock:^(int index) {
            if(index == buttonItem_aliPay)
            {
                [weakself.view makeToast:@"支付中"];
                [[ZFBPayService shareZFBPayService] requestAliPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(AlipayResultType ret) {
                    if(ret == alipay_fail)
                    {
                        [weakself.view makeToast:@"支付失败" duration:1 position:CSToastPositionCenter];
                    }
                    else
                    {
                        [[UserInfoData shareUserInfoData] setUserVip:1];
                        weakself.vipRechargeList.isvip = YES;
                        [weakself reloadview];
                        [weakself.view hideToastActivity];
                        [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
                        [weakself requestChargeList];;
                    }
                }];
            }
            else if(index == buttonItem_wxPay)
            {
                [weakself.view makeToast:@"支付中"];
                [[WXPayService shareWXPayService] requestWXPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(WXpayResultType ret) {
                    if(ret == WXPay_fail)
                    {
                        [weakself.view makeToast:@"支付失败" duration:1 position:CSToastPositionCenter];
                    }
                    else
                    {
                        [[UserInfoData shareUserInfoData] setUserVip:1];
                        weakself.vipRechargeList.isvip = YES;
                        [weakself reloadview];
                        [weakself.view hideToastActivity];
                        [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
                        [weakself requestChargeList];
                    }
                }];
            }
            weakself.orderview.hidden = YES;
            [weakself.orderview removeFromSuperview];
            weakself.orderview = nil;
        }];
        [self.view addSubview:_orderview];
    }
    else if ([self.supportPayType isEqualToString:@"3"])//苹果支付+微信支付+支付宝支付
    {
        self.orderview = [[BuyDBOrderView alloc] initWithFrame:self.view.bounds];
        [_orderview setBGColor:[UIColor blackColor] alpha:0.5];
        [_orderview createChongzhiView:aData.moneyCount containsApplePay:YES clickBlock:^(int index) {
            
                if(index == buttonItem_aliPay)
                {
                    [weakself.view makeToast:@"支付中"];
                    [[ZFBPayService shareZFBPayService] requestAliPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(AlipayResultType ret) {
                        if(ret == alipay_fail)
                        {
                            [weakself.view makeToast:@"支付失败" duration:1 position:CSToastPositionCenter];
                        }
                        else
                        {
                            [[UserInfoData shareUserInfoData] setUserVip:1];
                            weakself.vipRechargeList.isvip = YES;
                            [weakself reloadview];
                            [weakself.view hideToastActivity];
                            [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
                            [weakself requestChargeList];
                        }
                    }];
                }
                else if(index == buttonItem_wxPay)
                {
                    [weakself.view makeToast:@"支付中"];
                    [[WXPayService shareWXPayService] requestWXPayOrderItemId:aData.dataId amount:@"1" type:@"1" completeBlock:^(WXpayResultType ret) {
                        if(ret == WXPay_fail)
                        {
                            [weakself.view makeToast:@"支付失败" duration:1 position:CSToastPositionCenter];
                        }
                        else
                        {
                            [[UserInfoData shareUserInfoData] setUserVip:1];
                            weakself.vipRechargeList.isvip = YES;
                            [weakself reloadview];
                            [weakself.view hideToastActivity];
                            [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
                            [weakself requestChargeList];
                        }
                    }];
                }
                else if(index == buttonItem_applePay)
                {
                    self.appleBuyData = aData;
                    [self applePayOrder];
                }
                weakself.orderview.hidden = YES;
                [weakself.orderview removeFromSuperview];
                weakself.orderview = nil;
        }];
        [self.view addSubview:_orderview];

    }
    
}

- (void)reloadview
{
    self.tableview.tableHeaderView = [self getTableviewHeadView];
    [self.tableview reloadData];
}

- (UIView *)getTableviewFootView
{
    CGSize size = [self.vipRechargeList.strVipNotice sizeWithFont:kFont14];
    int line = size.width/(kMainScreenWidth-kLeftMragin*2) +1 ;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, line*(size.height+3))];
    view.backgroundColor = kcolorWhite;
    UILabel *textview = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMragin, 0, kMainScreenWidth-kLeftMragin*2, line*(size.height+3))];
    textview.font = kFont14;
    textview.textColor = [UIColor colorWithHexValue:0x999999];
    textview.text = self.vipRechargeList.strVipNotice;
    textview.numberOfLines = line;
    
    [view addSubview:textview];
    return view;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if([self isMovingFromParentViewController])
    {
        self.orderview.hidden = YES;
        [self.orderview removeFromSuperview];
        self.orderview = nil;
    }
}

#pragma mark applePay Method
- (void)applePayOrder
{
    if([RMStore canMakePayments])
    {
        if (self.isApplePaying == NO)
        {
            self.isApplePaying = YES;
            [SVProgressHUD showWithStatus:@"正在连接苹果商店"];
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
            [[UserInfoData shareUserInfoData] setUserVip:1];
            weakself.vipRechargeList.isvip = YES;
            [weakself reloadview];
            [weakself.view hideToastActivity];
            [weakself.view makeToast:@"支付成功" duration:1.f position:CSToastPositionCenter];
            [weakself requestChargeList];
        }
        else
        {
            [weakself.view makeToast:@"支付失败" duration:1.f position:CSToastPositionCenter];
        }
        
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
        [self.view makeToast:@"连接失败" duration:1.f position:CSToastPositionCenter];
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
            [self.view hideToastActivity];
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
