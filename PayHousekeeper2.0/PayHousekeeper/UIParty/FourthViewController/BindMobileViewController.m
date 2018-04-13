//
//  BandIMobileViewController.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BindMobileViewController.h"
#import "BindMobileCell.h"
#import "PersonInfoManager.h"
#import "BindNumViewController.h"
#import "WXLoginService.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "QQLoginService.h"
#import "AppDelegate.h"
#import "SPAlertView.h"
@interface BindMobileViewController ()<UITableViewDelegate, UITableViewDataSource,SPAlertViewDelegate>
{
    BOOL isHigSafe;
    PersonInfoManager *manager;
    
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) BindListData *datalist;
@property (nonatomic, strong) BindMobileCell *cellTmp;
@end

@implementation BindMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotifyListen];
    [self settitleLabel:@"账号与安全"];
    manager = [[PersonInfoManager alloc] init];
//    [self createTableview];
    [self requestBindList];
}

- (void)addNotifyListen
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindWXItem) name:kWXLoginSuccessNotifyName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindQQItem) name:kQQLoginSuccessNotifyName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindWeiboItem) name:kWEIBOLoginSuccessNotifyName object:nil];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self requestBindList];
//}

- (void)requestBindList
{
    WeakSelf(self);
    [self.view makeCenterToastActivity];
    [manager requestBindList:^(BindListData *datalist) {
        [weakself.view hideToastActivity];
        weakself.datalist = datalist;
        [weakself createTableview];
    }];
}

- (void)createTableview
{
    if(!self.tableview)
    {
        self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
        
        self.tableview.delegate   =  self;
        self.tableview.dataSource =  self;
        self.tableview.backgroundColor = [UIColor clearColor];
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableview.tableFooterView = [UIView new];
        self.tableview.tableHeaderView = [self getTableviewHeadview];
        [self.view addSubview:self.tableview];
    }
    else
    {
        self.tableview.tableHeaderView = [self getTableviewHeadview];
        [self.tableview reloadData];
    }
}

- (UIView *)getTableviewHeadview
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, (191+36))];
    view.backgroundColor = kcolorWhite;
    
    UIImage *safeImg = nil;
    NSString *safeTitle = @"安全等级低";
    isHigSafe = [self isBind:3];
    if(isHigSafe == YES)
    {
        safeImg = [UIImage imageNamed:@"safeLowhig"];
        safeTitle = @"安全等级高";
    }
    else
    {
        safeImg = [UIImage imageNamed:@"safeLowlev"];
    }
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width-97)/2, 24, 97, 97)];
    [imgview setImage:safeImg];
    [view addSubview:imgview];
    
    UILabel *safeLevLabel = [self.view labelWithFrame:CGRectMake(0, imgview.bottom+14, self.view.width, 15) text:safeTitle textFont:kFont13 textColor:RGBCOLOR(179,179,179)];
    safeLevLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:safeLevLabel];
    if(!isHigSafe)
    {
        UILabel *bindDesc = [self.view labelWithFrame:CGRectMake(0, safeLevLabel.bottom+11, self.view.width, 14) text:@"您尚未绑定手机号" textFont:kFont12 textColor:RGBCOLOR(153,153,153)];
        bindDesc.textAlignment = NSTextAlignmentCenter;
        [view addSubview:bindDesc];
    }
    
    UIView *btitle = [[UIView alloc] initWithFrame:CGRectMake(0, view.height-36, view.width, 36)];
    btitle.backgroundColor = RGBCOLOR(238, 238, 238);
    [view addSubview:btitle];
    
    UILabel *btlabel = [self.view labelWithFrame:CGRectMake(15, 0, btitle.width-30, btitle.height) text: @"账号与绑定" textFont:kFont14 textColor:RGBCOLOR(153,153,153)];
    [btitle addSubview:btlabel];
    
    return view;
}

#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
//0 是qq 1 微信 2 新浪微博 3手机用户
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BindMobileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BandIMobileViewControllercell"];

    if(!cell)
    {
        cell = [[BindMobileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BandIMobileViewControllercell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    WeakSelf(self);
    if(indexPath.row == 0)
    {
        self.cellTmp = cell;
        
        NSString *phoneStr = @"手机号";
        if ([self.datalist.phoneNO length]>0)
        {
            phoneStr = self.datalist.phoneNO;
        }
        [cell setCellDataIcon:[UIImage imageNamed:@"bind_mobile"] title:phoneStr isBind:[weakself isBind:3] index:(int)indexPath.row clickBlock:^(int index) {
            [weakself cellButtonItem:3];
        }];
    }
    if(indexPath.row == 1)
    {
        NSString *wechatStr = @"微信";
        if ([self.datalist.wechat length]>0)
        {
            wechatStr = self.datalist.wechat;
        }
        [cell setCellDataIcon:[UIImage imageNamed:@"weixin_mobile"] title:wechatStr isBind:[weakself isBind:1] index:(int)indexPath.row clickBlock:^(int index) {
            [weakself cellButtonItem:1];
        }];
    }
//    if(indexPath.row == 2)
//    {
//        NSString *weiboStr = @"新浪微博";
//        if ([self.datalist.weibo length]>0)
//        {
//            weiboStr = self.datalist.weibo;
//        }
//        [cell setCellDataIcon:[UIImage imageNamed:@"weibo_mobile"] title:weiboStr isBind:[self isBind:2] index:(int)indexPath.row clickBlock:^(int index) {
//            [weakself cellButtonItem:2];
//        }];
//    }
    if(indexPath.row == 2)
    {
        cell.line.hidden = YES;
        
        NSString *qqStr = @"QQ";
        if ([self.datalist.qq length]>0)
        {
            qqStr = self.datalist.qq;
        }
        [cell setCellDataIcon:[UIImage imageNamed:@"QQ_mobile"] title:qqStr isBind:[self isBind:0] index:(int)indexPath.row clickBlock:^(int index) {
            [weakself cellButtonItem:0];
        }];
    }
    return cell;
}
//0 是qq 1 微信 2 新浪微博 3手机用户
- (void)cellButtonItem:(int)aTye
{
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(aTye == 3)
    {
        
        if([self isBind:3])
        {
            [self showAlertView];
        }
        else
        {
            WeakSelf(self);
            BindNumViewController *vc = [[BindNumViewController alloc] init];
            [vc setBindCompleteBlock:^(NSString *number) {
                weakself.cellTmp.tLabel.text = number;
                [weakself requestBindList];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    if(aTye == 1)
    {
        
        if([WXApi isWXAppInstalled] && ![self isBind:1])
        {
            [del.window makeCenterToastActivity];
            del.isLogin = NO;
            del.loginType = bind_WXAccount;
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = @"snsapi_userinfo";
            req.state = @"com.intalk.moqu";
            [WXApi sendReq:req];
        }
        else
        {
            WeakSelf(self);
            [manager requestUnBindThirdLoginInfo:@"1" completeBlock:^(int ret) {
                if(ret)
                {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
    if(aTye == 0)
    {
        if([TencentOAuth iphoneQQInstalled] && ![self isBind:0])
        {
            [del.window makeCenterToastActivity];
            del.isLogin = NO;
            del.loginType = bind_QQAccount;
            NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
            
            //        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
            //        del.tOAuth.redirectURI = @"www.qq.com";
            [del.tOAuth authorize:permissions];
        }
        else
        {
            WeakSelf(self);
            [self.view makeCenterToastActivity];
            [manager requestUnBindThirdLoginInfo:@"0" completeBlock:^(int ret) {
                [weakself.view hideToastActivity];
                if(ret)
                {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
//    if(aTye == 2)
//    {
//        if([WeiboSDK isWeiboAppInstalled])
//        {
//            [self.view makeCenterToastActivity];
//            AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
//            del.isLogin = NO;
//            del.loginType = login_wb;
//            WBAuthorizeRequest *request = [WBAuthorizeRequest request];
//            request.redirectURI = @"http://www.sina.com";
//            request.scope = @"all";
//            request.userInfo = @{@"SSO_From": @"MQLoginViewController",
//                                 @"Other_Info_1": [NSNumber numberWithInt:123],
//                                 @"Other_Info_2": @[@"obj1", @"obj2"],
//                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
//            [WeiboSDK sendRequest:request];
//        }
//    }
}


- (void)bindWXItem
{
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    WeakSelf(self);
    [del.window hideToastActivity];
    [self.view makeCenterToastActivity];
    [manager requestThirdLoginInfo:[WXLoginService shareWXLoginData].nickName openid:[WXLoginService shareWXLoginData].openid type:@"1" completeBlock:^(int ret) {
        [weakself.view hideToastActivity];
        if(ret)
        {
//            [weakself.navigationController popViewControllerAnimated:YES];
            [weakself requestBindList];
        }
    }];
}
- (void)bindQQItem
{
    WeakSelf(self);
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del.window hideToastActivity];
    [self.view makeCenterToastActivity];
    [manager requestThirdLoginInfo:[QQLoginService shareQQLoginService].strNickname openid:[QQLoginService shareQQLoginService].openId type:@"0" completeBlock:^(int ret) {
        [weakself.view hideToastActivity];
        if(ret)
        {
//            [weakself.navigationController popViewControllerAnimated:YES];
            [weakself requestBindList];
        }
    }];
}
- (void)bindWeiboItem
{
}

- (BOOL)isBind:(int)aType
{
    BOOL isBind = NO;
    for(BindData *data in self.datalist.dataArry)
    {
        if(data.type == aType)
        {
            isBind = YES;
            break;
        }
    }
    return isBind;
}

- (void)showAlertView
{
    SPAlertView *alertView = [[SPAlertView alloc]initWithTitle:nil
                                                       message:@"是否更换手机号码"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                              otherButtonTitle:@"确定"];
    [alertView show];
}
#pragma mark - SPAlertViewDelegate
- (void)didSelectAlertButton:(NSString *)title
{
    if ([title isEqualToString:@"确定"])
    {
        WeakSelf(self);
        BindNumViewController *vc = [[BindNumViewController alloc] init];
        [vc setBindCompleteBlock:^(NSString *number) {
            weakself.cellTmp.tLabel.text = number;
            [weakself requestBindList];
        }];
        
        vc.isChanagePhonNum = YES;
        vc.phoneStr = self.datalist.phoneNO;
        [self.navigationController pushViewController:vc animated:YES];
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
