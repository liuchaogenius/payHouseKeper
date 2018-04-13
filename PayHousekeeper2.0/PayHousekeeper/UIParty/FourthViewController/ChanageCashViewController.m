//
//  ChanageCashViewController.m
//  PayHousekeeper
//
//  Created by 1 on 2017/1/1.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "ChanageCashViewController.h"
#import "PersonInfoManager.h"
#import "BindCashAccontViewController.h"

@interface ChanageCashViewController ()
{
    UIScrollView *contentview;
    BOOL isBindCashAccount;
    int cashCount;
    UILabel *desLabel;
    UILabel *cashTitLabel;
    UIImageView *arrowImgview;
    UILabel *cashLabel;
    UITextField *inputTextfield;

}
@property (nonatomic, strong) PersonInfoManager *manager;
@property (nonatomic, strong) NSString *strAccount;
@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strPreferentialTip;

@end

@implementation ChanageCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"提现"];
    self.view.backgroundColor = kViewBackgroundHexColor;
    self.manager = [[PersonInfoManager alloc] init];
    
    _strPreferentialTip = @"";
    
    contentview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    contentview.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackView:)];
    
    [contentview addGestureRecognizer:tap];
    [self.view addSubview:contentview];
    
    UIView *tixianview = [[UIView alloc] initWithFrame:CGRectMake(0, 3, contentview.width, 45)];
    tixianview.backgroundColor = kcolorWhite;
    [contentview addSubview:tixianview];
    
    cashTitLabel = [self.view labelWithFrame:CGRectMake(17, 0, 65, 45) text:@"提现账户" textFont:kFont15 textColor:RGBCOLOR(51, 51, 51)];
    [tixianview addSubview:cashTitLabel];
    
    if(!isBindCashAccount)
    {
        
        UIImage *arrowImg = [UIImage imageNamed:@"personArrow"];
        CGSize dsize = [@"未绑定" sizeWithFont:kFont15];
        desLabel = [self.view labelWithFrame:CGRectMake(contentview.width-15-arrowImg.size.width-5-dsize.width, 0, dsize.width, tixianview.height) text:@"未绑定" textFont:kFont15 textColor:RGBCOLOR(199, 199, 204)];
        [tixianview addSubview:desLabel];
        
        arrowImgview = [[UIImageView alloc] initWithFrame:CGRectMake(contentview.width-15-arrowImg.size.width, (tixianview.height-arrowImg.size.height)/2, arrowImg.size.width, arrowImg.size.height)];
        [arrowImgview setImage:arrowImg];
        [tixianview addSubview:arrowImgview];
        [tixianview addTarget:self action:@selector(bindCashAccount)];
    }
    
    UIView *middeview = [[UIView alloc] initWithFrame:CGRectMake(0, tixianview.bottom+8, self.view.width, 154)];
    middeview.backgroundColor = kcolorWhite;
    [contentview addSubview:middeview];
    
//    CGSize dgSize = [@"未绑定" sizeWithFont:kFont15];
    UILabel *dgTitleLabel = [self.view labelWithFrame:CGRectMake(cashTitLabel.left, 18, middeview.width-cashTitLabel.left*2, 16) text:@"我要提现的咚果" textFont:kFont14 textColor:RGBCOLOR(51,51,51)];
    [middeview addSubview:dgTitleLabel];
    inputTextfield = [[UITextField alloc] initWithFrame:CGRectMake(cashTitLabel.left, dgTitleLabel.bottom+25, middeview.width-cashTitLabel.left*2, 33)];
    inputTextfield.textColor = RGBCOLOR(53, 234, 191);
    inputTextfield.placeholder = @"0";
    inputTextfield.keyboardType = UIKeyboardTypeNumberPad;
    inputTextfield.font = [UIFont boldSystemFontOfSize:30];
    inputTextfield.backgroundColor = kClearColor;
    [inputTextfield addTarget:self action:@selector(textfieldContentChanges:) forControlEvents:UIControlEventEditingChanged];
    [middeview addSubview:inputTextfield];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(cashTitLabel.left, inputTextfield.bottom+17, middeview.width-cashTitLabel.left*2, kLineWidth)];
    line.backgroundColor = RGBCOLOR(224, 224, 224);
    [middeview addSubview:line];
    
    UILabel *ruleDescLabel = [self.view labelWithFrame:CGRectMake(cashTitLabel.left, line.bottom+17, middeview.width-cashTitLabel.left*2, 14) text:@"100起提，按10倍数输入" textFont:kFont12 textColor:RGBCOLOR(204, 204, 204)];
    [middeview addSubview:ruleDescLabel];
    
    
    NSString *descCash = [NSString stringWithFormat:@"将获得金额%d元",cashCount];
    cashLabel = [self.view labelWithFrame:CGRectMake(cashTitLabel.left, middeview.bottom+15, middeview.width-cashTitLabel.left*2, 14) text:descCash textFont:kFont12 textColor:RGBCOLOR(102, 102, 102)];
    [contentview addSubview:cashLabel];
    
    UIButton *completeBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-200)/2, middeview.bottom+71, 200, 44)];
    completeBt.titleLabel.font = kFont17;
    [completeBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [completeBt setTitle:@"提现" forState:UIControlStateNormal];
    completeBt.layer.cornerRadius = 22.0f;
    completeBt.layer.masksToBounds = YES;
    completeBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    [completeBt addTarget:self action:@selector(tixianButtonItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBt];
}

- (void)bindCashAccount
{
    WeakSelf(self);
    BindCashAccontViewController *vc = [[BindCashAccontViewController alloc] init];
    [vc getAccount:^(NSString *account, NSString *name) {
        [weakself setAccount:account name:name];
    }];
    if(self.strName && self.strAccount)
    {
        [vc setAccount:self.strAccount name:self.strName];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setAccount:(NSString *)account name:(NSString *)aName
{
    if(account && account.length > 2)
    {
        CGSize size = [account sizeWithFont:kFont15];
        cashTitLabel.width = size.width;
        cashTitLabel.text = account;
        desLabel.text = @" ";
        arrowImgview.hidden = YES;
        self.strAccount = account;
        self.strName = aName;
    }
    else
    {
        account = @"提现账户";
        CGSize size = [account sizeWithFont:kFont15];
        cashTitLabel.width = size.width;
        cashTitLabel.text = account;
        desLabel.text = @"未绑定";
        arrowImgview.hidden = NO;
        self.strAccount = @"";
        self.strName = @"";
    }
}

- (void)textfieldContentChanges:(UITextField *)aTextfield
{
    int count = [aTextfield.text intValue];
    if(count%10 == 0)
    {
        NSString *tip =_strPreferentialTip.length>0?[NSString stringWithFormat:@"(%@)",_strPreferentialTip]:@"";
        NSString *descCash = [NSString stringWithFormat:@"将获得金额%d元%@",(int)(count*self.cashRate), tip];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:descCash];
        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(102, 102, 102) range:NSMakeRange(0,5)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,descCash.length-tip.length-1-5)];
        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(102, 102, 102) range:NSMakeRange(descCash.length-tip.length-1,1)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(descCash.length-tip.length,tip.length)];
        cashLabel.attributedText = str;
    }
}

- (void)tapBackView:(id)sender
{
    [inputTextfield resignFirstResponder];
}


- (void)tixianButtonItem
{
    [self.view endEditing:YES];
    if(!self.strAccount || self.strAccount.length == 0)
    {
        [DLAPPDELEGATE showToastView:@"请输入支付宝账号"];
        return;
    }
    
    if(!self.strName || self.strName.length == 0)
    {
        [DLAPPDELEGATE showToastView:@"请输入账号对应的姓名"];
        return;
    }
    int count = [inputTextfield.text intValue];
    if(count%10 != 0)
    {
        [DLAPPDELEGATE showToastView:@"请输入正确的咚果数量"];
        return;
    }
    WeakSelf(self);
    [self.view makeCenterToastActivity];
    [self.manager requestAlipayCashAccount:self.strAccount name:self.strName dgCount:[NSString stringWithFormat:@"%d", count] completeBlock:^(int ret) {
        [weakself.view hideToastActivity];
        if(ret == 0)
        {
            [DLAPPDELEGATE showToastView:@"提现成功，请注意查看支付宝账户"];
            [weakself.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [DLAPPDELEGATE showToastView:@"提现失败"];
        }
    }];
}

- (void)firstMovingToParentvc
{
    WeakSelf(self);
    __weak UILabel *weakLab = cashLabel;
    [self.manager requestGetBindCrashAccountInfo:^(BindCrashAccountData *aData) {
        weakself.strAccount = aData.strAccount;
        weakself.strName = aData.strAccountName;
        weakself.cashRate = aData.cashRate+aData.givePercent/10.0;
        if(aData.givePercent == 0)
            weakself.strPreferentialTip = @"";
        else
            weakself.strPreferentialTip = aData.strgivePercent;
        
        NSString *tip =_strPreferentialTip.length>0?[NSString stringWithFormat:@"(%@)",weakself.strPreferentialTip]:@"";
        NSString *descCash = [NSString stringWithFormat:@"将获得金额0元%@", tip];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:descCash];
        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(102, 102, 102) range:NSMakeRange(0,5)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5,1)];
        [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(102, 102, 102) range:NSMakeRange(6,1)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,tip.length)];
        weakLab.attributedText = str;
        
        [weakself setAccount:weakself.strAccount name:weakself.strName];
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
