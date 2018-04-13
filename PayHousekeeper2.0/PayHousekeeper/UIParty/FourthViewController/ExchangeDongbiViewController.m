//
//  ExchangeDongbiViewController.m
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "ExchangeDongbiViewController.h"
#import "PersonInfoManager.h"
#import "PersonInfoDongBiCell.h"
#import "SPAlertView.h"


@interface ExchangeDongbiViewController ()<UITableViewDelegate, UITableViewDataSource, SPAlertViewDelegate>
{
    
}
@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ExchangeDBDataList *dbList;
@property (nonatomic, strong) ChongzhiDBData *currentChongzhiData;
@property (nonatomic, strong) UILabel *dgLabel;
@property (nonatomic, strong) NSString *dgCount;
@end

@implementation ExchangeDongbiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"兑换咚币"];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    self.manager = [[PersonInfoManager alloc] init];
    self.dgCount = [NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].shellCount];
    [self createTableview];
}

- (void)createTableview
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kView_Height) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource =  self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableview.tableHeaderView = [self getTableviewHeadview];
    self.tableview.tableFooterView = [UIView new];
    [self.view addSubview:self.tableview];
}

- (UIView *)getTableviewHeadview
{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 118)];
    headview.backgroundColor = kFcolorFontGreen;
    [self.view addSubview:headview];
    
    
    int offsetY = (headview.height-38-15-20)/2;
    
    if(self.dgLabel)
    {
        self.dgLabel = nil;
    }
    self.dgLabel = [self.view labelWithFrame:CGRectMake(0, offsetY, kMainScreenWidth, 38) text:self.dgCount textFont:[UIFont systemFontOfSize:36] textColor:kcolorWhite];
    self.dgLabel.textAlignment = NSTextAlignmentCenter;
    [headview addSubview:self.dgLabel];
    
    UILabel *titleLabel = [self.view labelWithFrame:CGRectMake(0, self.dgLabel.bottom+15, kMainScreenWidth, 20) text:@"我的咚果" textFont:kFont18 textColor:kcolorWhite];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headview addSubview:titleLabel];
    
    return headview;
}

- (UIView *)getTableviewNoDataview
{
    UILabel *tipLabel = [self.view labelWithFrame:CGRectMake(0, 60, kMainScreenWidth, 20) text:@"请先收礼物赚咚果，再来兑换咚币吧~" textFont:kFont16 textColor:kGrayColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    return tipLabel;
}
- (void)firstMovingToParentvc
{
    [self.view makeCenterToastActivity];
    WeakSelf(self);
    [self.manager requestExchangeDBList:^(ExchangeDBDataList *datalist) {
        [weakself.view hideToastActivity];
        if(datalist && datalist.dataList)
        {
            weakself.dbList = datalist;
            [weakself.tableview reloadData];
        }
    }];
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.dgCount floatValue]<=0)
    {
        return 1;
    }
    return self.dbList.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 60.0f;
    if([self.dgCount floatValue]<=0)
    {
        cellHeight = kView_Height-118;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.dgCount floatValue]<=0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chognzhinodatacell"];
        cell.userInteractionEnabled = NO;
        [cell.contentView addSubview:[self getTableviewNoDataview]];
        return cell;
    }
    else
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
}

- (void)configCell:(PersonInfoDongBiCell *)aCell cellForRowAtIndexPath:(NSIndexPath *)aIndexPath
{
    if(aIndexPath.row < self.dbList.dataList.count)
    {
        ExchangeDBData *rData = [self.dbList.dataList objectAtIndex:aIndexPath.row];
        ChongzhiDBData *data = [[ChongzhiDBData alloc] init];
        data.isExchangeView = YES;
        data.RMBCount = [NSString stringWithFormat:@"%@",rData.shellCount];
        data.dataId = rData.dataId;
        data.czdbNum = [NSString stringWithFormat:@"%@",rData.moneyCount];
        [aCell setCellData:data];
        WeakSelf(self);
        [aCell setBuyButtonClickBlock:^(ChongzhiDBData *data) {
//            [weakself requestCov:data.RMBCount];
            weakself.currentChongzhiData = data;
            [self showAlertView];
        }];
    }
}

- (void)requestCov:(NSString *)aShellCount
{
    [self.view makeCenterToastActivity];
 
    WeakSelf(self);
    [self.manager requestMyConversion:[aShellCount intValue] completeBlock:^(int moneyCount, int shellCount) {
        [weakself.view hideToastActivity];
        if(moneyCount>-1)
        {
            [[UserInfoData shareUserInfoData] setCurrentMoneyCount:moneyCount];
        }
        if(shellCount>-1)
        {
            [[UserInfoData shareUserInfoData] setCurrentShellCount:shellCount];
            NSString *dgCount = [NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].shellCount];
            weakself.dgLabel.text = dgCount;
        }
        if(moneyCount != -1 && shellCount!= -1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (void)showAlertView
{
    SPAlertView *alertView = [[SPAlertView alloc]initWithTitle:nil
                                                       message:@"确定兑换吗？"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                              otherButtonTitle:@"确定"];
    [alertView show];
}

- (void)didSelectAlertButton:(NSString *)title
{
    if ([title isEqualToString:@"确定"])
    {
        [self requestCov:self.currentChongzhiData.RMBCount];
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
