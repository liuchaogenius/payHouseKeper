//
//  BindNumViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BindNumViewController.h"
#import "LoginTypeTextField.h"
#import "DDLoginManager.h"
#import "PersonInfoManager.h"

@interface BindNumViewController ()
{
    LoginTypeTextField *regPWD;
    LoginTypeTextField *mobiletf;
    LoginTypeTextField *checkCode;
    LoginTypeTextField *againPSW;
    PersonInfoManager *manager;
    BOOL b;
    UIButton *registerBt;
}

@property (nonatomic)int resetCheckTime;
@property (nonatomic)dispatch_source_t time;
@end

@implementation BindNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _resetCheckTime = 59;
    if(self.isChanagePhonNum)
    {
        [self settitleLabel:@"更换手机号"];
    }
    else
    {
        [self settitleLabel:@"绑定手机"];
    }
    manager = [[PersonInfoManager alloc] init];
    self.view.backgroundColor = kViewBackgroundHexColor;
    
    int offsety = 15;
    if(self.isChanagePhonNum)
    {
        UILabel *desclabel = [self.view labelWithFrame:CGRectMake(15, 0, self.view.width-30, 60) text:[NSString stringWithFormat:@"更换手机号后：下次登录可以使用新的手机号码 \n当前手机号：%@", self.phoneStr] textFont:kFont14 textColor:RGBCOLOR(153, 153, 153)];
        desclabel.numberOfLines = 0;
        [self.view addSubview:desclabel];
        offsety = desclabel.bottom;
    }
    
    mobiletf = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, offsety, kMainScreenWidth, 56)];
    [mobiletf createCustomTextfieldleftDesc:@"+86" ploc:@"请输入手机号码" isSecurity:NO];
    [mobiletf viewAddBottomLine];
    mobiletf.type = TextFieldTypePhone;
    [self.view addSubview:mobiletf];
    

     [self addNotificationCenter:mobiletf.inputTextField];
    
    regPWD = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, mobiletf.bottom, kMainScreenWidth, 56)];
    [regPWD createCustomTextfieldleftDesc:@"登录密码" ploc:@"请输入6~12位密码" isSecurity:NO];
    [regPWD viewAddBottomLine];
    [self.view addSubview:regPWD];
    
 
    [self addNotificationCenter:regPWD.inputTextField];
    
    checkCode = [[LoginTypeTextField alloc] initWithFrame:CGRectMake(0, regPWD.bottom, kMainScreenWidth, 56)];
    checkCode.inputTextField.keyboardType = UIKeyboardTypePhonePad;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:checkCode.inputTextField];
    checkCode.tag = 10;
    [checkCode createCustomTextfieldleftDesc:@"验证码" ploc:@"请输入验证码" isSecurity:NO];
    [checkCode viewAddBottomLine];
    [self.view addSubview:checkCode];
    

    [self addNotificationCenter:checkCode.inputTextField];
    
    UIButton *checkBt = [self.view buttonWithFrame:CGRectMake(kMainScreenWidth-16-85, (checkCode.height-30)/2, 85, 30) titleFont:kFont14 titleStateNorColor:kcolorWhite titleStateNor:@"发验证码"];
    checkBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
    checkBt.layer.cornerRadius = 15.0f;
    checkBt.layer.masksToBounds = YES;
    [checkBt addTarget:self action:@selector(checkBtItem:) forControlEvents:UIControlEventTouchUpInside];
    checkCode.inputTextField.keyboardType = UIKeyboardTypePhonePad;
    [checkCode addSubview:checkBt];
    
    registerBt = [[UIButton alloc] initWithFrame:CGRectMake((kMainScreenWidth-200)/2, checkCode.bottom+30, 200, 44)];
    registerBt.enabled = NO;
    registerBt.titleLabel.font = kFont17;
    [registerBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [registerBt setTitle:@"完成" forState:UIControlStateNormal];
    registerBt.layer.cornerRadius = 22.0f;
    registerBt.layer.masksToBounds = YES;
    [registerBt addTarget:self action:@selector(bindButtonItem) forControlEvents:UIControlEventTouchUpInside];
    registerBt.backgroundColor = [UIColor grayColor];
    [self.view addSubview:registerBt];
    
    UIButton *showpwd = [self.view buttonWithFrame:CGRectMake(kMainScreenWidth-16-24, (regPWD.height-17)/2, 24, 17) titleFont:kFont10 titleStateNorColor:kBlackColor titleStateNor:nil];
    [showpwd setImage:[UIImage imageNamed:@"loginhpsw"] forState:UIControlStateNormal];
    [showpwd addTarget:self action:@selector(showPWDItem:) forControlEvents:UIControlEventTouchUpInside];
    [regPWD addSubview:showpwd];
    
}

- (void)addNotificationCenter:(UIView *)view
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:view];
    if (view.tag == 10) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCodeTextFieldChanged) name:UITextFieldTextDidChangeNotification object:view];
    }
}

- (void)textFieldChanged
{
    
    if (mobiletf.inputTextField.text.length >= 11) {
        [mobiletf.inputTextField resignFirstResponder];
        NSString *subStr = [mobiletf.inputTextField.text substringWithRange:NSMakeRange(0, 11)];
        mobiletf.inputTextField.text = subStr;
    }
    
    
    b = [DDLoginManager judgePhoneNumber:[mobiletf getInputText]];
    
    if (b && regPWD.inputTextField.text.length && checkCode.inputTextField.text.length) {
        
        registerBt.backgroundColor = RGBCOLOR(33,235,190);
        registerBt.enabled = YES;
    }
    else
    {
        
        registerBt.backgroundColor = [UIColor grayColor];
        registerBt.enabled = NO;
    }
}

- (void)checkCodeTextFieldChanged
{
    
    if (checkCode.inputTextField.text.length > 6) {
        NSString *subStr = [checkCode.inputTextField.text substringWithRange:NSMakeRange(0, 6)];
        checkCode.inputTextField.text = subStr;
    }
}

- (void)bindButtonItem
{
    [mobiletf resignFirstResponder];
    
    if(![mobiletf getInputText] || [mobiletf getInputText].length == 0)
    {
        [self.view makeToast:@"请输入手机号码" duration:0.6 position:CSToastPositionCenter];
        return;
    }
    else if(![DDLoginManager checkPhoneNum:[mobiletf getInputText]])
    {
        [self.view makeToast:@"请输入有效手机号码" duration:0.6 position:CSToastPositionCenter];
        return;
    }
    
    if([regPWD getInputText].length < 6 || [regPWD getInputText].length > 12)
    {
        [self.view makeToast:@"请输入6~12位密码"];
        return;
    }
    if(![checkCode getInputText] || [checkCode getInputText].length == 0)
    {
        [self.view makeToast:@"请输入验证码" duration:0.6 position:CSToastPositionCenter];
        return;
    }
    WeakSelf(self);
    [manager requestBindPhoneNum:[mobiletf getInputText] psw:[regPWD getInputText] checkCode:[checkCode getInputText] completeBlock:^(BOOL ret) {
        if(ret)
        {
            [weakself.view makeToast:@"绑定成功"];

            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                if(weakself.completeBlock)
                {
                    weakself.completeBlock(mobiletf.inputTextField.text);
                }
                
                [weakself back];
            });
            
        }
    }];
}

- (void)setBindCompleteBlock:(void(^)(NSString * number))aBlock
{
    self.completeBlock = aBlock;
}

- (void)showPWDItem:(UIButton *)aBt
{
    
    regPWD.inputTextField.secureTextEntry = !regPWD.inputTextField.secureTextEntry;
    if(regPWD.inputTextField.secureTextEntry == NO)
    {
        [aBt setImage:[UIImage imageNamed:@"loginshpsw"] forState:UIControlStateNormal];
    }
    else
    {
        [aBt setImage:[UIImage imageNamed:@"loginhpsw"] forState:UIControlStateNormal];
    }
}

- (void)checkBtItem:(UIButton *)aBt
{
    if(![mobiletf getInputText] || [mobiletf getInputText].length == 0)
    {
        [self.view makeToast:@"请输入手机号码" duration:0.6 position:CSToastPositionCenter];
        return;
    }
    else if(![DDLoginManager checkPhoneNum:[mobiletf getInputText]])
    {
        [self.view makeToast:@"请输入有效手机号码" duration:0.6 position:CSToastPositionCenter];
        return;
    }
    else
    {
        [[DDLoginManager shareLoginManager] requestVerCode:[mobiletf getInputText] codeType:10];
    }
    aBt.backgroundColor = [UIColor colorWithHexValue:0xd8d8d8];
    [aBt setTitle:[NSString stringWithFormat:@"%ds",self.resetCheckTime]forState:UIControlStateNormal];
    //获得队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //创建一个定时器
    self.time = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    //设置时间间隔
    uint64_t interval = (uint64_t)(1.0* NSEC_PER_SEC);
    //设置定时器
    dispatch_source_set_timer(self.time, start, interval, 0);
    //设置回调
    dispatch_source_set_event_handler(self.time, ^{
        //设置当执行五次是取消定时器
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resetCheckTime--;
            if(self.resetCheckTime <= 0){
                dispatch_cancel(self.time);
                [aBt setTitle:@"发验证码" forState:UIControlStateNormal];
                aBt.backgroundColor = [UIColor colorWithHexValue:0x00d898];
                aBt.userInteractionEnabled = YES;
                self.resetCheckTime = 59;
            }
            else
            {
                [aBt setTitle:[NSString stringWithFormat:@"%ds",self.resetCheckTime]forState:UIControlStateNormal];
                aBt.userInteractionEnabled = NO;
            }
        });
        
    });
    //由于定时器默认是暂停的所以我们启动一下
    //启动定时器
    dispatch_resume(self.time);
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
