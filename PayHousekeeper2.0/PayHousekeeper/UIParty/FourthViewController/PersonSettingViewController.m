//
//  PersonSettingViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/10.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonSettingViewController.h"
#import "PersonSettingCell.h"
#import "AppDelegate.h"
#import "SCach.h"
#import "BindMobileViewController.h"
#import "PersonHelpViewController.h"
#import "AboutAppViewController.h"
#import "SPAlertView.h"


@interface PersonSettingViewController ()<UITableViewDelegate, UITableViewDataSource,SPAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation PersonSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"设置"];
    [self createTableview];
}

- (void)createTableview
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource =  self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableview];
}
- (UIView *)getTableviewHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    view.backgroundColor = kClearColor;
    return view;
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    view.backgroundColor = kClearColor;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(section == 0)
    {
        count = 1;
    }
    else if(section == 1)
    {
        count = 2;
    }
    else if(section == 2)
    {
        count = 1;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personsettingvcCell"];
    if(!cell)
    {
        cell = [[PersonSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personsettingvcCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            [cell setCellData:@"账号与安全" righcontent:nil];
        }
    }
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [cell setCellData:@"帮助与反馈" righcontent:nil];
            [cell viewAddBottomLine];
        }
        if(indexPath.row == 1)
        {
            [cell setCellData:@"关于" righcontent:nil];
        }
    }
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell.islogout = YES;
            [cell setCellData:@"退出登录" righcontent:nil];
        }
//        if(indexPath.row == 1)
//        {
//            [cell setCellData:@"常见问题" righcontent:nil];
//        }
//        if(indexPath.row == 2)
//        {
//            [cell setCellData:@"关于" righcontent:nil];
//        }
    }
//    if(indexPath.section == 3)
//    {
//        cell.textLabel.text = @"推出登陆";
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        cell.textLabel.textColor = [UIColor colorWithHexValue:0xff3b3b];
//        cell.textLabel.font = kFont17;
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        [self showAlertView];
    }
    else if(indexPath.section == 0)
    {
        BindMobileViewController *bindVC = [[BindMobileViewController alloc] init];
        [self.navigationController pushViewController:bindVC animated:YES];
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            PersonHelpViewController *vc = [[PersonHelpViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 1)
        {
            AboutAppViewController *vc = [[AboutAppViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)logOut
{
    [[YXManager sharedInstance] yxLogout:^(NSError *err) {
        [[SCach shareInstance] removeFileData:kStoreUserDataKey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_WBkey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_QQkey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_WXKey filePath:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDDLoginType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [DLAPPDELEGATE showLoginWindow];
        DLAPPDELEGATE.currentLoginType = 0;
        DLAPPDELEGATE.loginType = 0;
        [[UserInfoData shareUserInfoData] clearMemoryData];
    }];
}
- (void)showAlertView
{
    SPAlertView *alertView = [[SPAlertView alloc]initWithTitle:@"退出账号"
                                                       message:@"退出后你将无法收到别人的信息，别人也无法找到你，是否继续？"
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
        [self logOut];
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
