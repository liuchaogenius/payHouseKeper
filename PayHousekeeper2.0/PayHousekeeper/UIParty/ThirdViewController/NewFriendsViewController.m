//
//  NewFriendsViewController.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//  我的关注/我的粉丝控制器

#import "NewFriendsViewController.h"
#import "NewFriendsTableViewCell.h"
#import "NTESSessionViewController.h"
#import "PersonDetailView.h"
#import "SPActionSheet.h"

#define cellHeight 64.0
#define avatarTag 300

@interface NewFriendsViewController ()<UITableViewDelegate, UITableViewDataSource, SPActionSheetDelegate>
{
    SPActionSheet *actionsheet;
    NSString *userID;
    UILabel *tipLab;
}

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic,assign)  BOOL shouldMarkAsRead;
@property (nonatomic, strong) PersonDetailView *detailView;
@end

@implementation NewFriendsViewController

//不需要退出刷新
//- (void)firstMovingToParentvc
//{
//    [[DDFriendsInfoManager sharedInstance] getMyAttentionInfo];
//    [[DDFriendsInfoManager sharedInstance] getMyFansInfo];
//}

- (void)dealloc
{
    if (_shouldMarkAsRead)
    {
        [[YXManager sharedInstance] markAllNotificationsAsRead];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:_isFans?@"我的粉丝":@"我的关注"];
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView)
                                                 name:RosterInfoChangedNotification
                                               object:nil];
    
//    [self initYXBlock];
    
    [self initNewFriendsTableView];
    
    [self initTipLab];
}

//- (void)initYXBlock
//{
//    WeakSelf(self)
//    [YXManager sharedInstance].refreshSysMess = ^(){
//        [weakself.tableview reloadData];
//    };
//}

- (void)initTipLab
{
    tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 200-64, kMainScreenWidth, 15)];
    tipLab.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLab];
    tipLab.text = _isFans?@"还没有人关注你哦~":@"先关注喜欢的朋友吧~";
    tipLab.textColor = RGBCOLOR(153, 153, 153);
    tipLab.font = kFont14;
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.hidden = YES;
}

- (void)initNewFriendsTableView
{
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    _tableview.delegate   =  self;
    _tableview.dataSource = self;
    _tableview.rowHeight = cellHeight;
    _tableview.backgroundColor = self.view.backgroundColor;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableview];

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 3)];
    headView.backgroundColor = self.view.backgroundColor;
    _tableview.tableHeaderView = headView;
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _isFans?[DDFriendsInfoManager sharedInstance].myFansArr:[DDFriendsInfoManager sharedInstance].myAttentionsArr;
    tipLab.hidden = arr.count > 0;
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriendsTableViewCell"];
    if(!cell)
    {
        cell = [[NewFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewFriendsTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    NSArray *arr = _isFans?[DDFriendsInfoManager sharedInstance].myFansArr:[DDFriendsInfoManager sharedInstance].myAttentionsArr;
    FriendsModel *model = arr[indexPath.row];
    [cell.avatarImgView sd_setImageWithURL:URL(model.avatar) placeholderImage:DEFAULTAVATAR];
    cell.nameLab.text = model.remarks;
    
    cell.feelLab.text = model.userSign;
    
    if (cell.feelLab.text == nil || [cell.feelLab.text isEqualToString:@"(null)"] || [cell.feelLab.text isEqualToString:@""]) {
        cell.feelLab.text = @"这家伙很懒，什么都没留下~";
    }
    cell.vipImgView.hidden = !model.isVip;
    cell.line.hidden = indexPath.row == [arr count]-1;
//    [cell.avatarImgView addTarget:self action:@selector(clickAvatar:)];
    cell.avatarImgView.tag = avatarTag+indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = _isFans?[DDFriendsInfoManager sharedInstance].myFansArr:[DDFriendsInfoManager sharedInstance].myAttentionsArr;
    FriendsModel *user = arr[indexPath.row];
    NIMKitInfo *data = [[YXManager sharedInstance] getInfoByUserId:user.friendId];
    NIMSession *session = [NIMSession session:user.friendId type:NIMSessionTypeP2P];
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
    [vc settitleLabel:data.showName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadView
{
    
    [_tableview reloadData];
    if(!self.detailView)
        return;
    
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:userID])
    {
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"互相关注" forState:UIControlStateNormal];
    }
    else if([[DDFriendsInfoManager sharedInstance] isAttentioned:userID])
    {
        [self.detailView.bottomBtn setImage:IMG(@"gouxuan_pressed") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"gouxuan_pressed") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"已关注" forState:UIControlStateNormal];
    }
    else
    {
        [self.detailView.bottomBtn setImage:IMG(@"follow+normal") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"follow+normal") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"关注" forState:UIControlStateNormal];
    }
}

- (void)clickAvatar:(UITapGestureRecognizer *)sender
{
    UIImageView *view = (UIImageView *)sender.view;
    
    NSMutableArray *arr = _isFans?[DDFriendsInfoManager sharedInstance].myFansArr:[DDFriendsInfoManager sharedInstance].myAttentionsArr;
    FriendsModel *user = arr[view.tag-avatarTag];
    userID = user.friendId;
    WeakSelf(self)
    [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:userID completeBlock:^(NSDictionary *dataDic) {
        if(dataDic)
        {
            PersonDetailModel *user = [[PersonDetailModel alloc] init];
            [user unPackeDict:dataDic];
            PersonDetailView *view = [[PersonDetailView alloc] initWithDetailModel:user];
            [view.leftBtn addTarget:weakself action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            weakself.detailView = view;
            [view show];
            [weakself reloadView];
            [view.bottomBtn addTarget:weakself action:@selector(clickAttentionBtn) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    
}

- (void)report
{
    NSArray *titleArry = @[@"政治反动",@"色情暴力",@"人身攻击"];
    actionsheet = [[SPActionSheet alloc] initWithTitle:@"请选择举报类型" dismissMsg:@"取消" delegate:self buttonTitles:titleArry];
    actionsheet.titleColor = [UIColor blackColor];
    actionsheet.dismissBtnColor = [UIColor whiteColor];
    actionsheet.contentBtnColor = [UIColor grayColor];
    actionsheet.dismissBackgroundBtnColor = kFcolorFontGreen;
    [actionsheet show];
}

- (void)clickAttentionBtn
{
    if([[DDFriendsInfoManager sharedInstance] isAttentioned:userID])
    {
        [[DDFriendsInfoManager sharedInstance] requestRemoveAttentionID:userID accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
        }];
    }
    else
    {
        [[DDFriendsInfoManager sharedInstance] requestAddAttentionID:userID accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
        }];
    }
}

- (void)didSelectActionSheetButton:(NSString *)title
{
    actionsheet.hidden = YES;
    [actionsheet removeFromSuperview];
    actionsheet = nil;
    
    if(![title isEqualToString:@"取消"])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
        [dict setObject:userID forKey:@"targetId"];
        [dict setObject:title forKey:@"type"];
        
        [NetManager requestWith:dict apiName:kTipoffAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [DLAPPDELEGATE showToastView:@"举报成功" duration:1 position:CSToastPositionCenter];
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
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
