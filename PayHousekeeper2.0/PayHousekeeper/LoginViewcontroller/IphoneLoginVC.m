//
//  IphoneLoginVC.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//  手机号登录控制器

#import "IphoneLoginVC.h"
#import "LoginTypeTextField.h"
#import "IphoneRegisterVC.h"
#import "DDLoginManager.h"
#import "AppDelegate.h"
#import "AdditionalPersonInfoVC.h"
#import "AppDelegate.h"

@interface IphoneLoginVC ()
{
    LoginTypeTextField *mobiletf;
    LoginTypeTextField *pwd;
    BOOL isPhone; // 是否为11位手机号码
    UIButton *loginBt;
}
@end

@implementation IphoneLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self settitleLabel:@"手机号登录"];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    mobiletf = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, 15, kMainScreenWidth, 56)];
    [mobiletf createCustomTextfieldleftDesc:@"+86" ploc:@"请输入手机号码" isSecurity:NO];
    [mobiletf viewAddBottomLine];
    mobiletf.type = TextFieldTypePhone;
    // 警告
//    [mobiletf setKeyType:TextFieldTypePhone];
    [self.view addSubview:mobiletf];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:mobiletf.inputTextField];
    
    pwd = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, mobiletf.bottom, kMainScreenWidth, mobiletf.height)];
    [pwd createCustomTextfieldleftDesc:@"密码" ploc:@"请输入6~12位密码" isSecurity:NO];
    [pwd viewAddBottomLine];
    pwd.type = TextFieldTypeMix;
    [self.view addSubview:pwd];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:pwd.inputTextField];
    
    UIButton *showpwd = [self.view buttonWithFrame:CGRectMake(kMainScreenWidth-16-24, (pwd.height-17)/2, 24, 17) titleFont:kFont10 titleStateNorColor:kBlackColor titleStateNor:nil];
    [showpwd setImage:[UIImage imageNamed:@"loginhpsw"] forState:UIControlStateNormal];
    [showpwd addTarget:self action:@selector(showPWDItem:) forControlEvents:UIControlEventTouchUpInside];
    [pwd addSubview:showpwd];
    
    UIButton *regBt = [[UIButton alloc] initWithFrame:CGRectMake(17, pwd.bottom+18, 30, 16)];
    regBt.titleLabel.font = kFont14;
    [regBt setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
    [regBt setTitle:@"注册" forState:UIControlStateNormal];
    [regBt addTarget:self action:@selector(registerUserButtomItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regBt];
    
    
    UIButton *getPWDBt = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth-17-58,regBt.top, 58, 16)];
    getPWDBt.titleLabel.font = kFont14;
    [getPWDBt setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
    [getPWDBt setTitle:@"忘记密码" forState:UIControlStateNormal];
    [getPWDBt addTarget:self action:@selector(resetPSWButtomItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getPWDBt];
    
    
    loginBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-200)/2, regBt.bottom+30, 200, 44)];
    loginBt.titleLabel.font = kFont17;
    [loginBt setTitle:@"登录" forState:UIControlStateNormal];
    loginBt.backgroundColor = [UIColor grayColor];
    loginBt.enabled = NO;
    loginBt.layer.cornerRadius = 22.0f;
    loginBt.layer.masksToBounds = YES;
    [loginBt addTarget:self action:@selector(loginBtItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBt];
}

- (void)showPWDItem:(UIButton *)aBt
{
    
    pwd.inputTextField.secureTextEntry = !pwd.inputTextField.secureTextEntry;
    if(pwd.inputTextField.secureTextEntry == NO)
    {
        [aBt setImage:[UIImage imageNamed:@"loginshpsw"] forState:UIControlStateNormal];
    }
    else
    {
        [aBt setImage:[UIImage imageNamed:@"loginhpsw"] forState:UIControlStateNormal];
    }
}


//- (void)pwdFieldChanged
//{
//    if (isPhone && pwd.inputTextField.text.length) {
//        
//        //        [loginBt setBackgroundColor:RGBCOLOR(33,235,190) forState:UIControlStateNormal];
//        loginBt.backgroundColor = RGBCOLOR(33,235,190);
//        loginBt.enabled = YES;
//    }
//    else
//    {
//        
//        loginBt.backgroundColor = [UIColor grayColor];
//        loginBt.enabled = NO;
//    }
//}

- (void)textFieldChanged
{
    
    if (mobiletf.inputTextField.text.length >= 11) {
        [mobiletf.inputTextField resignFirstResponder];
        NSString *subStr = [mobiletf.inputTextField.text substringWithRange:NSMakeRange(0, 11)];
        mobiletf.inputTextField.text = subStr;
        
        [pwd.inputTextField becomeFirstResponder];
    }
    isPhone = [DDLoginManager judgePhoneNumber:[mobiletf getInputText]];
    if (isPhone && pwd.inputTextField.text.length) {
        
        //        [loginBt setBackgroundColor:RGBCOLOR(33,235,190) forState:UIControlStateNormal];
        loginBt.backgroundColor = RGBCOLOR(33,235,190);
        loginBt.enabled = YES;
    }
    else
    {
        
        loginBt.backgroundColor = [UIColor grayColor];
        loginBt.enabled = NO;
    }
}

- (void)loginBtItem
{
    
    
    [mobiletf resignFirstResponder];
    [pwd resignFirstResponder];
    [self.view endEditing:YES];
    
    
    if(![mobiletf getInputText] || [mobiletf getInputText].length <= 2)
    {
        [self.view makeToast:@"请输入登录手机号码"];
        return;
    }
    if([pwd getInputText].length < 6 || [pwd getInputText].length > 12)
    {
        [self.view makeToast:@"请输入6~12位密码"];
        return;
    }
    [DLAPPDELEGATE showMakeToastCenter];
    
    [[DDLoginManager shareLoginManager] requestLoginPhoneNum:[mobiletf getInputText] psw:[pwd getInputText] completeBlock:^(BOOL ret) {
        if(ret)
        {
            if([self judgeUserNeedInfo])
            {
                [[YXManager sharedInstance] yxLogin:[UserInfoData shareUserInfoData]];
            }
            
        }
        else
        {
            [DLAPPDELEGATE.window hideToastActivity];

//            [DLAPPDELEGATE showToastView:@"登录失败"];
        }
    }];
}

- (BOOL)judgeUserNeedInfo
{
    NSString *strNick = [UserInfoData shareUserInfoData].strUserNick;
    NSString *strBirthday = [UserInfoData shareUserInfoData].strBirthday;
    NSString *strAge = [UserInfoData shareUserInfoData].strAge;
    NSString *strGender = [UserInfoData shareUserInfoData].strGender;
    if ([strNick isEqualToString:@"(null)"] || [strBirthday isEqualToString:@"(null)"] || [strAge isEqualToString:@"(null)"] || [strGender isEqualToString:@"(null)"]) {

        
        MLOG(@"后台有返回值为 (null) 了");
        
        [DLAPPDELEGATE.window hideToastActivity];
        AdditionalPersonInfoVC *vc = [[AdditionalPersonInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
        
    }
    
    if(![UserInfoData shareUserInfoData].strUserNick || [UserInfoData shareUserInfoData].strUserNick.length == 0 || ![UserInfoData shareUserInfoData].strBirthday || [UserInfoData shareUserInfoData].strUserNick.length == 0 || ![UserInfoData shareUserInfoData].strAge || [UserInfoData shareUserInfoData].strAge.length == 0 || ![UserInfoData shareUserInfoData].strGender || [UserInfoData shareUserInfoData].strGender.length == 0)
    {
        [DLAPPDELEGATE.window hideToastActivity];
        AdditionalPersonInfoVC *vc = [[AdditionalPersonInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}

- (void)registerUserButtomItem
{
    //AdditionalPersonInfoVC.h
//    AdditionalPersonInfoVC *vc = [[AdditionalPersonInfoVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    IphoneRegisterVC *vc = [[IphoneRegisterVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)resetPSWButtomItem
{
    IphoneRegisterVC *vc = [[IphoneRegisterVC alloc] init];
    [vc setviewType:1];
    [self.navigationController pushViewController:vc animated:YES];
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
