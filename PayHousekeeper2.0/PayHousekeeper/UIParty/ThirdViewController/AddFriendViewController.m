
//
//  AddFriendViewController.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "AddFriendViewController.h"
#import "SearchFriendsTableViewCell.h"
#import "DDLoginManager.h"

#define cellHeight 64.0
#define TagIndex 1000

@interface AddFriendViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UIControl *control;
}
@property (nonatomic, strong) UITextField *searchTF;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *friendArr;

@end

@implementation AddFriendViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self settitleLabel:@"添加好友"];
    self.view.backgroundColor = kcolorWhite;
    _friendArr = [NSMutableArray array];
    
    [self initSearchView];
    
    [self initAddFriendsTableView];
    
    [self initControlView];
}

- (void)initControlView
{
    control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    control.backgroundColor = [UIColor clearColor];
    [self.view addSubview:control];
    [control addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    control.hidden = YES;
}

- (void)hideKeyBoard
{
    [_searchTF resignFirstResponder];
    control.hidden = YES;
}

- (void)initSearchView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 54)];
    view.backgroundColor = kcolorWhite;
    [self.view addSubview:view];
    
    _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 9, kMainScreenWidth-80, 36)];
    [view addSubview:_searchTF];
    _searchTF.clipsToBounds = YES;
    _searchTF.layer.cornerRadius = 5;
    _searchTF.backgroundColor = RGBCOLOR(245, 245, 245);
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchFriends"]];
    img.backgroundColor = [UIColor clearColor];
    [img setX:5];
    [img setWidth:img.width+15];
    img.contentMode = UIViewContentModeCenter;
    _searchTF.leftView = img;
    _searchTF.leftViewMode = UITextFieldViewModeAlways;
    _searchTF.placeholder = @"搜索咚咚号/手机号";
    _searchTF.delegate = self;
    _searchTF.font = kFont15;
    _searchTF.keyboardType = UIKeyboardTypeNumberPad;
    [_searchTF becomeFirstResponder];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(_searchTF.right, 0, 60, view.height);
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
    btn.titleLabel.font = kFont15;
    [view addSubview:btn];
    [btn addTarget:self action:@selector(goBackView) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_searchTF];
}

- (void)goBackView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initAddFriendsTableView
{
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchTF.superview.bottom, kMainScreenWidth, kMainScreenHeight-64-_searchTF.superview.bottom) style:UITableViewStylePlain];
    _tableview.delegate   =  self;
    _tableview.dataSource = self;
    _tableview.rowHeight = cellHeight;
    _tableview.backgroundColor = self.view.backgroundColor;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableview];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchFriendsTableViewCell"];
    if(!cell)
    {
        cell = [[SearchFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchFriendsTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UserInfoData *data = _friendArr[indexPath.row];
    [cell.avatarImgView sd_setImageWithURL:URL(data.strHeadUrl) placeholderImage:DEFAULTAVATAR];
    cell.nameLab.text = data.strUserNick;
    cell.feelLab.text = data.strUserSign;
    
    BOOL isAttentioned = [[DDFriendsInfoManager sharedInstance] isAttentioned:data.strUserId];
    [cell.stateBtn setTitle:(isAttentioned?@"已关注":@"关注") forState:UIControlStateNormal];
    cell.stateBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    cell.stateBtn.enabled = !isAttentioned;
    cell.stateBtn.tag = indexPath.row + TagIndex;
    [cell.stateBtn addTarget:self action:@selector(addAttentionFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.stateBtn.hidden = [data.strUserId isEqualToString:[UserInfoData shareUserInfoData].strUserId];
    cell.line.hidden = indexPath.row == _friendArr.count-1;
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    control.hidden = NO;
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    
    if(text.length>11)
    {
        textField.text = [text substringToIndex:11];
    }
    return [text length] <= 11;
}

- (void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    UITextField *textfield = [notification object];
//    NSLog(@"%@",textfield.text);
    [self searchFriend:textfield.text];
}

- (void)searchFriend:(NSString *)str
{
    if(str.length > 0)
    {
        WeakSelf(self)
        [[DDLoginManager shareLoginManager] requestSearchFriend:str accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(NSMutableArray *userArr)
        {
            [weakself.friendArr removeAllObjects];
            if(userArr.count)
            {
                weakself.tableview.tableFooterView = nil;
                [weakself.friendArr addObjectsFromArray:userArr];
            }
            else
            {
                if(!weakself.tableview.tableFooterView)
                    [weakself showNoResult];
            }
            [weakself.tableview reloadData];
        }];
    }
}

- (void)showNoResult
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 120)];
    lab.font = kFont15;
    lab.backgroundColor = kcolorWhite;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"该用户不存在";
    lab.textColor = RGBCOLOR(153, 153, 153);
    _tableview.tableFooterView = lab;
}

- (void)addAttentionFriend:(UIButton *)btn
{
    WeakSelf(self)
    UserInfoData *data = _friendArr[btn.tag-TagIndex];
    
    if([btn.titleLabel.text isEqualToString:@"关注"])
    {
        [[DDFriendsInfoManager sharedInstance] requestAddAttentionID:data.strUserId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself.view makeToast:@"已关注" duration:1 position:CSToastPositionCenter];
            [btn setTitle:@"已关注" forState:UIControlStateNormal];
        }];
    }
    else
    {
        [[DDFriendsInfoManager sharedInstance] requestRemoveAttentionID:data.strUserId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself.view makeToast:@"已取消关注" duration:1 position:CSToastPositionCenter];
            [btn setTitle:@"关注" forState:UIControlStateNormal];
        }];
    }
//    [[YXManager sharedInstance] addFriend:data.strUserId isForced:NO];
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
