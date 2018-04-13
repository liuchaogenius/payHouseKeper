//
//  BindCashAccontViewController.m
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "BindCashAccontViewController.h"
#import "LoginTypeTextField.h"
#import "PersonInfoManager.h"
#import "AppDelegate.h"

@interface BindCashAccontViewController ()
{
    LoginTypeTextField *accountField;
    LoginTypeTextField *nameField;
    NSString *account;
    NSString *name;
    PersonInfoManager *manager;
}
@property (nonatomic, copy)void(^accountBlock)(NSString *account, NSString *name);
@end

@implementation BindCashAccontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"绑定提现账户"];
    manager = [[PersonInfoManager alloc] init];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    accountField = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, 3, self.view.width, 55)];
    [accountField createCustomTextfieldleftDesc:@"支付宝账号" ploc:@"请输入支付宝账号" isSecurity:NO];
    if(account && account.length > 0)
    {
        accountField.inputTextField.text = account;
    }
    [self.view addSubview:accountField];
    
    nameField = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, accountField.bottom, self.view.width, 55)];
    [nameField createCustomTextfieldleftDesc:@"姓名" ploc:@"请输入支付宝认证实名" isSecurity:NO];
    if(name && name.length > 0)
    {
        nameField.inputTextField.text = name;
    }
    [self.view addSubview:nameField];
    
    UIButton *completeBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-200)/2, nameField.bottom+37, 200, 44)];
    completeBt.titleLabel.font = kFont17;
    [completeBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [completeBt setTitle:@"绑定" forState:UIControlStateNormal];
    completeBt.layer.cornerRadius = 22.0f;
    completeBt.layer.masksToBounds = YES;
    completeBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    [completeBt addTarget:self action:@selector(completeButtonItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBt];
}

- (void)setAccount:(NSString *)aAccount name:(NSString *)aName
{
    account = aAccount;
    name = aName;
}

- (void)getAccount:(void(^)(NSString *account, NSString *name))aBlock
{
    self.accountBlock = aBlock;
}

- (void)completeButtonItem
{
    AppDelegate *del = (AppDelegate  *)[UIApplication sharedApplication].delegate;
    if(![accountField getInputText] || [accountField getInputText].length<=0)
    {
        [del showToastView:@"请输入账号"];
    }
    if(![nameField getInputText] || [nameField getInputText].length<=0)
    {
        [del showToastView:@"请输入名称"];
    }
    WeakSelf(self);
    [manager requestBindCrashAlipayAccount:[accountField getInputText] name:[nameField getInputText] completeBlock:^(BOOL isBind) {
        if(isBind)
        {
            if(weakself.accountBlock)
            {
                weakself.accountBlock([accountField getInputText],[nameField getInputText]);
            }
            [weakself.navigationController popViewControllerAnimated:YES];
        }
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
