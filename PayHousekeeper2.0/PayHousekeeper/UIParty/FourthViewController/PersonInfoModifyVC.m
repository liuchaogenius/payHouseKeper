//
//  PersonInfoModifyVC.m
//  PayHousekeeper
//
//  Created by 1 on 2016/11/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//  编辑资料控制器

#import "PersonInfoModifyVC.h"
#import "PersonInfoModifyCell.h"
#import "UserInfoData.h"
#import "WXCamerasViewViewController.h"
#import "STPickerDate.h"
#import "PersonInfoEditViewController.h"
#import "DDLoginManager.h"
#import "STPickerSingle.h"
#import "NSDateDeal.h"
#import "AlterNicknameVC.h"
#import "AppDelegate.h"

@interface PersonInfoModifyVC ()<UITableViewDelegate, UITableViewDataSource,STPickerDateDelegate,STPickerSingleDelegate, STPickerDateDelegate>
{
    
    NSString *sexType;
    
    NSString *strXZ;
    NSString *strTempBirthday;
}
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSString *strTempNick;
@property (nonatomic, strong) UIImage *tempHeadImg;
@property (nonatomic, strong) NSString *strTempAge;
@property (nonatomic, strong) NSString *userMood;
@property (nonatomic, strong) PersonInfoModifyCell *birthdayCell;
@property (nonatomic, strong) PersonInfoModifyCell *xingzuoCell;
@end

@implementation PersonInfoModifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    sexType = [UserInfoData shareUserInfoData].strGender;
    strXZ = [UserInfoData shareUserInfoData].strConstellation;
    [self settitleLabel:@"编辑资料"];
    [self setupTableView];
    //    [self setRightButton:nil title:@"完成" titlecolor:kFcolorFontGreen target:self action:@selector(commitModifyInfo)];
}

- (void)commitModifyInfo:(PersonModifyType)aType succBlock:(void(^)(BOOL isSucc))aBlock
{
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [del showMakeToastCenter];
    if(aType == personUpdate_heaeUrl)
    {
        float kCompressionQuality = 0.5;
        NSData *avatarImgData = UIImageJPEGRepresentation(self.tempHeadImg, kCompressionQuality);
        
        [[DDLoginManager shareLoginManager] reqestComInfoGender:nil nickName:nil imgData:avatarImgData birthday:nil inviteCode:nil place:nil completeBlock:^(BOOL ret) {
            [del hiddenWindowToast];
            if(ret)
            {
                
                [del showToastView:@"更新成功"];
                aBlock(YES);
            }
        }];
    }
    else if(aType == personUpdate_Nick)
    {
        [[DDLoginManager shareLoginManager] reqestComInfoGender:nil nickName:_strTempNick imgData:nil birthday:nil inviteCode:nil place:nil completeBlock:^(BOOL ret) {
            [del hiddenWindowToast];
            if(ret)
            {
                
                [del showToastView:@"更新成功"];
                aBlock(YES);
            }
        }];
    }
    else if(aType == personUpdate_birthday)
    {
        [[DDLoginManager shareLoginManager] reqestComInfoGender:nil nickName:_strTempNick imgData:nil birthday:strTempBirthday inviteCode:nil place:nil completeBlock:^(BOOL ret) {
            [del hiddenWindowToast];
            if(ret)
            {
                [del showToastView:@"更新成功"];
                aBlock(YES);
            }
        }];
    }
    else if(aType == personUpdate_sex)
    {
        [[DDLoginManager shareLoginManager] reqestComInfoGender:sexType nickName:_strTempNick imgData:nil birthday:nil inviteCode:nil place:nil completeBlock:^(BOOL ret) {
            [del hiddenWindowToast];
            if(ret)
            {
                
                [del showToastView:@"更新成功"];
                aBlock(YES);
            }
        }];
    }
    else if(aType == personUpdate_mood)
    {
//        if(self.userMood && self.userMood.length > 0)
//        {
            [[DDLoginManager shareLoginManager] requestUserSig:self.userMood completeBlock:^(BOOL ret) {
                [del hiddenWindowToast];
                if(ret)
                {
                    
                    [del showToastView:@"更新成功"];
                    aBlock(YES);
                }
            }];
//        }
    }
}
#pragma mark 添加tableview
- (void)setupTableView
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-0) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.backgroundColor = kFTableViewColor;
    self.tableview.separatorColor = kLineColor;
    self.tableview.tableHeaderView = [self tableviewHeadview];
    [self.view addSubview:self.tableview];
    [self setExtraCellLineHidden:self.tableview];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
}
- (UIView *)tableviewHeadview
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 15)];
    view.backgroundColor = RGBCOLOR(238, 238, 238);
    return view;
}

#pragma mark tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 61;
    }
    else
    {
        return 56;
    }
}

// 返回每组尾部控件
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    
    return view;
}

// 每组头部距离
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.5;
}

//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [[UIView alloc] init];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonInfoModifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmViewControllerCell"];
    if(!cell)
    {
        cell = [[PersonInfoModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlarmViewControllerCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UserInfoData *udata = [UserInfoData shareUserInfoData];
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        [cell setCellLeftContent:@"头像" isHeadImgCell:YES rightContent:nil isArrow:YES isHeadView:YES headImgUrl:udata.strHeadUrl];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        [cell setCellLeftContent:@"昵称" isHeadImgCell:NO rightContent:udata.strUserNick?udata.strUserNick:@" " isArrow:YES isHeadView:NO headImgUrl:nil];
    }
    
    else if(indexPath.section == 0 && indexPath.row == 2)
    {
        cell.lineView.hidden = YES;
        
        [cell setCellLeftContent:@"咚咚号" isHeadImgCell:NO rightContent:udata.strUserCode isArrow:NO isHeadView:NO headImgUrl:nil];
    }
    //    else if(indexPath.row == 4)
    //    {
    //        [cell setCellLeftContent:@"生日" isHeadImgCell:NO rightContent:udata.strBirthday?udata.strBirthday:@" " isArrow:NO headImgUrl:nil];
    //    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        
        [cell setCellLeftContent:@"生日" isHeadImgCell:NO rightContent:udata.strBirthday isArrow:YES isHeadView:YES headImgUrl:nil];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
        [cell setCellLeftContent:@"星座" isHeadImgCell:NO rightContent:udata.strConstellation isArrow:NO isHeadView:NO headImgUrl:nil];
        self.xingzuoCell = cell;
    }
    //    else if(indexPath.row == 5)
    //    {
    //        [cell setCellLeftContent:@"性别" isHeadImgCell:NO rightContent:udata.strSex?udata.strSex:@" " isArrow:YES isHeadView:NO headImgUrl:nil];
    //    }
    else if(indexPath.section == 1 && indexPath.row == 2)
    {
        cell.lineView.hidden = YES;
        
        NSString *strSingContent = udata.strUserSign;
        if ([strSingContent isEqualToString:@"(null)"]) {
            strSingContent = nil;
        }
        [cell setCellLeftContent:@"个性签名" isHeadImgCell:NO rightContent:strSingContent?strSingContent:@" " isArrow:YES isHeadView:NO headImgUrl:nil];
    }
    
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoData *data = [UserInfoData shareUserInfoData];
    PersonInfoModifyCell *cell = (PersonInfoModifyCell*)[tableView cellForRowAtIndexPath:indexPath];
    WeakSelf(self);
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        [self selectHeadImg:cell];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        AlterNicknameVC *vc = [[AlterNicknameVC alloc] init];
        [vc setVCTitle:@"修改昵称" source:data.strUserNick block:^(NSString *aContent) {
            if(aContent && aContent.length > 0)
            {
                weakself.strTempNick = aContent;
                [weakself commitModifyInfo:personUpdate_Nick succBlock:^(BOOL isSucc) {
                    if(isSucc)
                        [cell updateNick:aContent];
                }];
            }
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 1 &&  indexPath.row == 0)
    {
        [self pickerDate:cell];
    }
    else if(indexPath.section == 1 &&  indexPath.row == 2)
    {
        //        [self pickSex:cell];
        PersonInfoEditViewController *vc = [[PersonInfoEditViewController alloc] init];
        NSString *strSingContent = data.strUserSign;
        if ([strSingContent isEqualToString:@"(null)"]) {
            strSingContent = nil;
        }
        [vc setVCTitle:@"个性签名" source:strSingContent block:^(NSString *aContent) {
//            if(aContent && aContent.length > 0)
//            {
                weakself.userMood = aContent;
                [weakself commitModifyInfo:personUpdate_mood succBlock:^(BOOL isSucc) {
                    if(isSucc)
                        [cell updateNick:aContent];
                }];
//            }
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 6)
    {
        
    }
}

- (void)pickSex:(PersonInfoModifyCell *)aCell
{
    self.birthdayCell = aCell;
    STPickerSingle *singview = [[STPickerSingle alloc] init];
    singview.delegate = self;
    singview.arrayData = [NSMutableArray arrayWithCapacity:0];
    [singview.arrayData addObject:@"男"];
    [singview.arrayData addObject:@"女"];
    [singview show];
}

- (void)pickerSingle:(STPickerSingle *)pickerSingle selectedTitle:(NSString *)selectedTitle
{
    if([selectedTitle compare:@"男"] == 0)
    {
        sexType = @"M";
    }
    else
    {
        sexType = @"F";
    }

    if([selectedTitle compare:[UserInfoData shareUserInfoData].strSex] != 0 || ![UserInfoData shareUserInfoData].strSex || [UserInfoData shareUserInfoData].strSex.length == 0)
    {
        WeakSelf(self);
        [self commitModifyInfo:personUpdate_sex succBlock:^(BOOL isSucc) {
            if(weakself.birthdayCell)
            {
                [weakself.birthdayCell updateNick:selectedTitle];
            }
        }];
    }
}
#pragma mark 选择生日
- (void)pickerDate:(PersonInfoModifyCell *)aCell
{
    NSString *birthday = [UserInfoData shareUserInfoData].strBirthday;
    NSArray *tmpArr = [birthday componentsSeparatedByString:@"-"];
    self.birthdayCell = aCell;
    STPickerDate *pickerDate = [[STPickerDate alloc] init];
    if(birthday && birthday.length > 0 && tmpArr && tmpArr.count == 3)
    {
        [pickerDate setDate:[tmpArr[0] integerValue] month:[tmpArr[1] integerValue] day:[tmpArr[2] integerValue]];
    }
    [pickerDate setDelegate:self];
    [pickerDate show];
    
    
}

- (void)pickerDate:(STPickerDate *)pickerDate year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    
    //    int age = (int)([NSDateDeal getCurrentYear] - year);
    //    NSString *tempAge = [NSString stringWithFormat:@"%d", age];
    
    // 修改 tempAge 的值
    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld", year, month, day];
    
    self.strTempAge = dateStr;
    
    WeakSelf(self);
    
    strTempBirthday = [NSString stringWithFormat:@"%d-%d-%d",(int)year,(int)(month),(int)(day)];
    [self commitModifyInfo:personUpdate_birthday succBlock:^(BOOL isSucc) {
        if(weakself.birthdayCell)
        {
            [weakself.birthdayCell updateNick:dateStr];
        }
        if(weakself.xingzuoCell)
        {
            NSString *str = [NSString stringWithFormat:@"%@座",[weakself getAstroWithMonth:(int)month day:(int)day]];
            [weakself.xingzuoCell updateNick:str];
        }
    }];
}

-(NSString *)getAstroWithMonth:(int)m day:(int)d{
    
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    
    
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    
    
    return result;
}

#pragma mark 从拍照 或者 相册选择头像
- (void)selectHeadImg:(PersonInfoModifyCell *)aCell
{
    WXCamerasViewViewController * cameraVC = [[WXCamerasViewViewController alloc]init];
    [self.navigationController pushViewController:cameraVC animated:YES];
    WeakSelf(self);
    [cameraVC setUserImgCallBack:^(UIImage *aBackImg) {
        if(aBackImg)
        {
            weakself.tempHeadImg = aBackImg;
            [weakself commitModifyInfo:personUpdate_heaeUrl succBlock:^(BOOL isSucc) {
                if(isSucc)
                    [aCell updateHeadImg:aBackImg];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //    [super dealloc];
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
