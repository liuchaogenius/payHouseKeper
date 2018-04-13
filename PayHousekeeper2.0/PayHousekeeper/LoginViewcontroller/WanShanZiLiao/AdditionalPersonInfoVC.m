//
//  AdditionalPersonInfoVC.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//  完善资料控制器

#import "AdditionalPersonInfoVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LoginTypeTextField.h"
#import "WXCamerasViewViewController.h"
#import "DDLoginManager.h"
#import "NSDateDeal.h"
#import "AppDelegate.h"
#import "STPickerDate.h"

@interface AdditionalPersonInfoVC ()<STPickerDateDelegate>
{
    UIButton *manBt;
    UIButton *girlBt;
    UILabel *glabel;
    UILabel *mlabel;
    UIView *pickBgview;
    UITextField *ltfNick;
    UITextField *autograph;
    LoginTypeTextField *ltfBirthday;
    LoginTypeTextField *yaoqingmaLabel;
    NSString *gender;
    NSString *nickName;
    NSData *avatarImgData;
    NSString *birthday;
    UIView *manBtView;
    UIView *girlBtView;
    STPickerDate *pickerDate;
    UIButton *dateBtn;
//    BOOL b; // 判断是否有选择性别
    UIButton *completeBt;
}
@property (nonatomic, strong) STPickerDate *myDatePicker;
@property (nonatomic, strong)UIImageView *headImgview;
@property (nonatomic, strong)UIImage *headImg;

@end

@implementation AdditionalPersonInfoVC
@synthesize headImgview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBCOLOR(255, 255, 255);
    [self settitleLabel:@"完善个人资料"];
    
    [self setRightButton:nil title:@"完成" titlecolor:RGBCOLOR(99, 235, 177) target:self action:@selector(completeButtomItem)];
    
//    gender = @"M";
    gender = nil;
    headImgview = [[UIImageView alloc] init];
    headImgview.frame = CGRectMake((kMainScreenWidth - 80.5) / 2, 30, 81, 81);
    [headImgview addTarget:self action:@selector(selectHeadImg)];
    headImgview.layer.cornerRadius = 40.5f;
    headImgview.layer.masksToBounds = YES;
//    if([UserInfoData shareUserInfoData].strHeadUrl)
    {
        WeakSelf(self)
        self.headImg = [UIImage imageNamed:@"def_sel"];
        [headImgview sd_setImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] placeholderImage:self.headImg completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(!error && image)
                weakself.headImg = image;
        }];
        
    }
    [self.view addSubview:headImgview];
    
    UILabel *deslabel = [self.view labelWithFrame:CGRectMake(0, 133, kMainScreenWidth, 12) text:@"完善用户资料，可更准确的为您匹配用户" textFont:kFont12 textColor:[UIColor colorWithHexValue:0xbbbbbb]];
    deslabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:deslabel];
    
    ltfNick = [[UITextField alloc] initWithFrame:CGRectMake(70, 25 + CGRectGetMaxY(deslabel.frame), kMainScreenWidth - 140, 50)];
    ltfNick.font = [UIFont systemFontOfSize:17];
//    ltfNick.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    ltfNick.textColor = RGBCOLOR(51, 51, 51);
    if([UserInfoData shareUserInfoData].strUserNick && [UserInfoData shareUserInfoData].strUserNick.length > 0)
    {

        ltfNick.text = [UserInfoData shareUserInfoData].strUserNick;
        
        if ([ltfNick.text isEqualToString:@"(null)"]) {
            ltfNick.text = nil;
            NSLog(@"ltfNick.text为null");
        }
    }
    ltfNick.textAlignment = NSTextAlignmentCenter;
    [ltfNick viewAddBottomLine];
    [self.view addSubview:ltfNick];
    [ltfNick addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    ltfNick.attributedPlaceholder = [NSAttributedString.alloc initWithString:@"昵称"
                                            
                                                                         attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    
    
    
    dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(ltfNick.frame), kMainScreenWidth - 140, 50)];
    [dateBtn setTitleColor:RGBCOLOR(217, 217, 221) forState:UIControlStateNormal];
    [dateBtn setTitle:@"生日" forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(dateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dateBtn];
    [dateBtn viewAddBottomLine];
    
    
    autograph = [[UITextField alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(dateBtn.frame), kMainScreenWidth - 140, 50)];
    [autograph setTextColor:RGBCOLOR(51, 51, 51)];
    autograph.font = [UIFont systemFontOfSize:17];
    autograph.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    autograph.keyboardType = UIKeyboardTypePhonePad;
    autograph.textAlignment = NSTextAlignmentCenter;
    [autograph viewAddBottomLine];
    [self.view addSubview:autograph];
    
    NSMutableParagraphStyle *paragraphStyle2 = NSMutableParagraphStyle.new;
    
    paragraphStyle2.alignment = NSTextAlignmentCenter;
    
    autograph.attributedPlaceholder = [NSAttributedString.alloc initWithString:@"邀请码（选填）"
                                     
                                                                  attributes:@{NSParagraphStyleAttributeName:paragraphStyle2}];
    
    
    completeBt = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 52, 20, 52, 44)];
    completeBt.titleLabel.font = kFont17;
    [completeBt setTitleColor:[UIColor colorWithHexValue:0xf0eff5] forState:UIControlStateNormal];
    [completeBt setTitle:@"完成" forState:UIControlStateNormal];
    [completeBt setTitleColor:[UIColor colorWithHexValue:0x00d898] forState:UIControlStateNormal];
        [completeBt addTarget:self action:@selector(completeButtomItem) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.view addSubview:completeBt];
 
    
        girlBt = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth / 2 - 70, CGRectGetMaxY(autograph.frame) + 30, 44, 44)];
    
        [girlBt setImage:[UIImage imageNamed:@"girl_Icon"] forState:UIControlStateNormal];
//        [girlBt setTitle:@"女生" forState:UIControlStateNormal];
//        [girlBt setTitleColor:[UIColor colorWithHexValue:0xc94254] forState:UIControlStateNormal];
        [girlBt addTarget:self action:@selector(seletSexItem:) forControlEvents:UIControlEventTouchUpInside];
        girlBt.tag = 1;
        [self.view addSubview:girlBt];
    
    
        glabel = [self.view labelWithFrame:CGRectMake(girlBt.left, girlBt.bottom+10, 44, 16) text:@"女生" textFont:kFont14 textColor:RGBCOLOR(220, 218, 218)];
        glabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:glabel];
    
        manBt = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth / 2 + 26, CGRectGetMaxY(autograph.frame) + 30, 44, 44)];
    
        [manBt setImage:[UIImage imageNamed:@"boy_icon"] forState:UIControlStateNormal];
//        [manBt setTitle:@"男生" forState:UIControlStateNormal];
//        [manBt setTitleColor:[UIColor colorWithHexValue:0xc94254] forState:UIControlStateNormal];
        [manBt addTarget:self action:@selector(seletSexItem:) forControlEvents:UIControlEventTouchUpInside];
        manBt.tag = 0;
        [self.view addSubview:manBt];
    

        mlabel = [self.view labelWithFrame:CGRectMake(manBt.left, manBt.bottom+10, 44, 16) text:@"男生" textFont:kFont14 textColor:RGBCOLOR(220, 218, 218)];
        mlabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:mlabel];
    
    NSLog(@"self.phoneDone====%d", self.phoneDone);
//===================这里应该做个判断，只有第三方登录的时候才进来============================
    if (self.phoneDone == NO) { // 如果不是第三方登录才进来做处理

        if([UserInfoData shareUserInfoData].sexType == 0 || [[UserInfoData shareUserInfoData].strSex isEqualToString:@"男"])
        {
    //        b = YES;
            gender = @"M";
            [girlBt setImage:[UIImage imageNamed:@"girl_Icon"] forState:UIControlStateNormal];
            glabel.textColor = RGBCOLOR(220, 218, 218);
            
            [manBt setImage:[UIImage imageNamed:@"p_boy_icon_slet"] forState:UIControlStateNormal];
            mlabel.textColor = RGBCOLOR(53, 138, 218);
        }

        if([UserInfoData shareUserInfoData].sexType == 1 || [[UserInfoData shareUserInfoData].strSex isEqualToString:@"女"])
        {
    //        b = YES;
            gender = @"F";
            [girlBt setImage:[UIImage imageNamed:@"p_girl_Icon_slet"] forState:UIControlStateNormal];
            glabel.textColor = RGBCOLOR(233, 120, 125);
            
            [manBt setImage:[UIImage imageNamed:@"boy_icon"] forState:UIControlStateNormal];
            mlabel.textColor = RGBCOLOR(220, 218, 218);
        }
    }
//==============================================================

}

- (void)seletSexItem:(UIButton *)btn
{
//    b = YES;
    
    if (btn.tag == 1) { // 女
        [girlBt setImage:[UIImage imageNamed:@"p_girl_Icon_slet"] forState:UIControlStateNormal];
        glabel.textColor = RGBCOLOR(233, 120, 125);
        
        [manBt setImage:[UIImage imageNamed:@"boy_icon"] forState:UIControlStateNormal];
        mlabel.textColor = RGBCOLOR(220, 218, 218);
        
        gender = @"F";
    }
    else // 男
    {
        [girlBt setImage:[UIImage imageNamed:@"girl_Icon"] forState:UIControlStateNormal];
        glabel.textColor = RGBCOLOR(220, 218, 218);
        
        [manBt setImage:[UIImage imageNamed:@"p_boy_icon_slet"] forState:UIControlStateNormal];
        mlabel.textColor = RGBCOLOR(53, 138, 218);
        
        gender = @"M";
    }
}

- (void)dateBtnClicked
{
    [ltfNick resignFirstResponder];
    [autograph resignFirstResponder];
    pickerDate = [[STPickerDate alloc]init];
    [pickerDate setDelegate:self];
    [pickerDate show];
    
}

- (void)pickerDate:(STPickerDate *)pickerDate year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{

    [dateBtn setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
    birthday = [NSString stringWithFormat:@"%ld-%ld-%ld",year,month,day];
    [dateBtn setTitle:birthday forState:UIControlStateNormal];
}


- (void)createSexview:(CGRect)aRect
{
    UIView *view = [[UIView alloc] initWithFrame:aRect];
    [view viewAddBottomLine];
    [self.view addSubview:view];
    UILabel *leftLabel = [self.view labelWithFrame:CGRectMake(0, (aRect.size.height-18)/2, 50, 18) text:@"性别" textFont:kFont16 textColor:kBlackColor];
    [view addSubview:leftLabel];
    
    UIImage *img = [UIImage imageNamed:@"addPersonSelSex_nor"];
    UIImage *img_sel = [UIImage imageNamed:@"addPersonSelSex_sel"];
    UIImage *manImg = nil;
    UIImage *girlImg = nil;
    CGSize size = [@"男" sizeWithFont:kFont16];
    int sexViewWidth = size.width+2+img.size.width;
    if([UserInfoData shareUserInfoData].strSex && [[UserInfoData shareUserInfoData].strSex compare:@"男"] == 0)
    {
        manImg = img_sel;
        girlImg = img;
        gender = @"M";
    }
    else
    {
        girlImg = img_sel;
        manImg = img;
        gender = @"F";
    }
    manBtView = [self selBttonView:CGRectMake(view.width-sexViewWidth*2-20, (view.height-img.size.height)/2, sexViewWidth, img.size.height) labelConten:@"男" img:manImg];
    [manBtView addTarget:self action:@selector(selectMan)];
    [view addSubview:manBtView];
    
    girlBtView = [self selBttonView:CGRectMake(manBtView.right+20, (view.height-img.size.height)/2, sexViewWidth, img.size.height) labelConten:@"女" img:girlImg];
    [girlBtView addTarget:self action:@selector(selectGirl)];
    [view addSubview:girlBtView];
    
}

- (UIView *)selBttonView:(CGRect)aRect
             labelConten:(NSString *)aLabeConten img:(UIImage*)aImg
{
    UIView *view = [[UIView alloc] initWithFrame:aRect];
    CGSize size = [aLabeConten sizeWithFont:kFont16];
    UILabel *label = [self.view labelWithFrame:CGRectMake(0, 0, size.width, view.height) text:aLabeConten textFont:kFont16 textColor:kGrayColor];
    [view addSubview:label];
    
//    UIImage *img = [UIImage imageNamed:@""];
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(label.right+2, 0, aImg.size.width, aImg.size.height)];
    [imgview setImage:aImg];
    imgview.tag = 100;
    [view addSubview:imgview];
    return view;
}

- (void)back
{
    [completeBt removeFromSuperview];
    [[UserInfoData shareUserInfoData] clearMemoryData];
    [super back];
//    if(!gender || gender.length == 0)
//    {
//        [self.view makeToast:@"请完善用户资料"];
//        return;
//    }
//    if(!birthday || birthday.length == 0)
//    {
//        [self.view makeToast:@"请完善用户资料"];
//        return;
//    }
//    if(![ltfNick getInputText] || [ltfNick getInputText].length == 0)
//    {
//        [self.view makeToast:@"请完善用户资料"];
//        return;
//    }
//    if(!avatarImgData)
//    {
//        [self.view makeToast:@"请完善用户资料"];
//        return;
//    }
//    [self completeButtomItem];
//    [DLAPPDELEGATE showRootviewController];
}

#pragma mark 选择男女
- (void)selectMan
{
    UIImage *img = [UIImage imageNamed:@"addPersonSelSex_nor"];
    UIImage *img_sel = [UIImage imageNamed:@"addPersonSelSex_sel"];
    UIImageView *mImgview = [manBtView viewWithTag:100];
    UIImageView *gImgview = [girlBtView viewWithTag:100];
    [mImgview setImage:img_sel];
    [gImgview setImage:img];
    gender = @"M";
}
-(void)selectGirl
{
    UIImage *img = [UIImage imageNamed:@"addPersonSelSex_nor"];
    UIImage *img_sel = [UIImage imageNamed:@"addPersonSelSex_sel"];
    UIImageView *mImgview = [manBtView viewWithTag:100];
    UIImageView *gImgview = [girlBtView viewWithTag:100];
    [mImgview setImage:img];
    [gImgview setImage:img_sel];
    gender = @"F";
}

#pragma mark 从拍照 或者 相册选择头像
- (void)selectHeadImg
{
    [ltfNick resignFirstResponder];
    [yaoqingmaLabel.inputTextField resignFirstResponder];
    WXCamerasViewViewController * cameraVC = [[WXCamerasViewViewController alloc]init];
    [self.navigationController pushViewController:cameraVC animated:YES];
    WeakSelf(self);
    [cameraVC setUserImgCallBack:^(UIImage *aBackImg) {
        if(aBackImg)
        {
            [weakself.headImgview setImage:aBackImg];
            weakself.headImg = aBackImg;
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [ltfNick resignFirstResponder];
    [autograph resignFirstResponder];
}

#pragma mark 完善用户资料请求
- (void)completeButtomItem
{
    avatarImgData = UIImageJPEGRepresentation(self.headImg, 0.5);
    if(!gender)
    {
        [self.view makeToast:@"请完善用户资料"];
        return;
    }
    if(!birthday || birthday.length == 0)
    {
        [self.view makeToast:@"请完善用户资料"];
        return;
    }
    if(!ltfNick.text || ltfNick.text.length == 0)
    {
        [self.view makeToast:@"请完善用户资料"];
        return;
    }
    if(!avatarImgData)
    {
        [self.view makeToast:@"请完善用户资料"];
        return;
    }
    
    [DLAPPDELEGATE showMakeToastCenter];
    WeakSelf(self);
    [[DDLoginManager shareLoginManager] reqestComInfoGender:gender nickName:ltfNick.text imgData:avatarImgData birthday:birthday inviteCode:autograph.text place:nil completeBlock:^(BOOL ret) {

        if(ret)
        {

            [self.view makeToast:@"绑定成功"];
            
            
            [[YXManager sharedInstance] yxLogin:[UserInfoData shareUserInfoData]];

            [weakself updateUserInfo];

        }
//        else
//        {
//            [DLAPPDELEGATE.window hideToastActivity];
//            [DLAPPDELEGATE showToastView:@"网络不好，请重新试"];
//        }
    }];
}

- (void)updateUserInfo
{
    [[DDLoginManager shareLoginManager] requesUpdateUserInfo:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
        [[YXManager sharedInstance] yxLogin:[UserInfoData shareUserInfoData]];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChange
{
    NSString *toBeString = ltfNick.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [ltfNick markedTextRange];
    UITextPosition *position = [ltfNick positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 12)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:12];
            if (rangeIndex.length == 1)
            {
                ltfNick.text = [toBeString substringToIndex:12];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 12)];
                ltfNick.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
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
