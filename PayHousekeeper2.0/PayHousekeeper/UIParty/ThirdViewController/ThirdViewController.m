//
//  ThirdViewController.m
//  YHB_Prj
//
//  Created by  striveliu on 14-11-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "ThirdViewController.h"
#import "MessageTableViewCell.h"
#import "NewFriendsViewController.h"
#import "NIMKit.h"
#import "NIMRecentSession.h"
#import "NSDateDeal.h"
#import "NIMMessage.h"
#import "TitleSegmentView.h"
#import "NTESSessionViewController.h"
#import "ContactTableViewCell.h"
#import "NetManager.h"
#import "AddFriendViewController.h"
#import "DDBearViewController.h"
#import "PersonDetailView.h"
#import "SPActionSheet.h"

#define cellHeight 64.0
#define avatarTag 300

@interface ThirdViewController ()<UITableViewDelegate, UITableViewDataSource, SPActionSheetDelegate>
{
    UILabel *fansLab, *attentionsLab;
    SPActionSheet *actionsheet;
    NSString *userID;
    UILabel *tipLab,*tipLab2;
//    UIView *statusBarView;
}
@property (nonatomic, strong) UITableView *messTableview;
@property (nonatomic, strong) UITableView *contactsTableview;
@property (nonatomic, strong) PersonDetailView *detailView;
@end

@implementation ThirdViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initYXBlocks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    self.navigationController.view.backgroundColor = kcolorWhite;
    
//    statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 20)];
//    statusBarView.backgroundColor = [UIColor whiteColor];
//    [self.navigationController.view addSubview:statusBarView];
//    [self.navigationController setNavigationBarHidden:NO];
//    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView)
                                                 name:RosterInfoChangedNotification
                                               object:nil];
    
    [self initTipLab];
    
    [self initTitleView];
//    [[DDFriendsInfoManager sharedInstance] requestRemoveAttentionID:@"a5155f2f80294927b161add4ae3e77e5" accid:[UserInfoData shareUserInfoData].strUserId completeBlock:nil];
    
//    [self setLeftButton:IMG(@"goBackToVideo") title:nil target:self action:@selector(goBackToVideo)];
//    [self setRightButton:IMG(@"searchFriend_green") title:nil titlecolor:nil target:self action:@selector(gotoSearchFriendVC)];
    
    [self setupTableView];
    
//    [self setupCustomCellView:YES];
    
    [self.view bringSubviewToFront:tipLab];
    [self.view bringSubviewToFront:tipLab2];
}

- (void)back
{
    [super back];
    
//    [statusBarView removeFromSuperview];
    
}

- (void)initTipLab
{
    tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 200-64, kMainScreenWidth, 15)];
    tipLab.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLab];
    tipLab.text = @"去找个好友聊聊吧~";
    tipLab.textColor = RGBCOLOR(153, 153, 153);
    tipLab.font = kFont14;
    tipLab.textAlignment = NSTextAlignmentCenter;
    
    tipLab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight*5, kMainScreenWidth, 15)];
    tipLab2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLab2];
    tipLab2.text = @"咦，一个好友都没有啊~";
    tipLab2.textColor = RGBCOLOR(153, 153, 153);
    tipLab2.font = kFont14;
    tipLab2.textAlignment = NSTextAlignmentCenter;
    tipLab2.hidden = YES;
}

- (void)reloadView
{
    
    attentionsLab.text = [NSString stringWithFormat:@"%lu", (unsigned long)[DDFriendsInfoManager sharedInstance].myAttentionsArr.count];
    
    fansLab.text = [NSString stringWithFormat:@"%lu", (unsigned long)[DDFriendsInfoManager sharedInstance].myFansArr.count];
    
    [_contactsTableview reloadData];
    
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

- (void)initTitleView
{
    WeakSelf(self)
    __weak UILabel *weakLab = tipLab;
    __weak UILabel *weakLab2 = tipLab2;

    TitleSegmentView *tv = [[TitleSegmentView alloc] initWithTitleArr:@[@"消息",@"通讯录"] normalImage:IMG(@"titleSegmentView1") selectedImage:IMG(@"titleSegmentView12")];
    tv.clickTitle = ^(int index)
    {
        if(index == 0)
        {
            weakself.messTableview.hidden = NO;
            weakself.contactsTableview.hidden = YES;
            [weakself.messTableview reloadData];
            weakLab2.hidden = YES;
        }
        else
        {
            weakself.messTableview.hidden = YES;
            weakself.contactsTableview.hidden = NO;
            [weakself.contactsTableview reloadData];
            weakLab.hidden = YES;
        }
    };
    self.navigationItem.titleView = tv;
}

- (void)goBackToVideo
{
    [self back];
}

- (void)gotoSearchFriendVC
{
    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)gotoAttentionView
{
    NewFriendsViewController *vc = [[NewFriendsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoFansView
{
    NewFriendsViewController *vc = [[NewFriendsViewController alloc] init];
    vc.isFans = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)gotoDDHelperView
{
    DDBearViewController *vc = [[DDBearViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark  create tableview
- (void)setupTableView
{
    _messTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    _messTableview.delegate   =  self;
    _messTableview.dataSource = self;
    _messTableview.rowHeight = cellHeight;
    _messTableview.backgroundColor = self.view.backgroundColor;
    _messTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_messTableview];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 3)];
    headView.backgroundColor = self.view.backgroundColor;
    _messTableview.tableHeaderView = headView;
    
    _contactsTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    _contactsTableview.delegate   =  self;
    _contactsTableview.dataSource = self;
    _contactsTableview.rowHeight = cellHeight;
    _contactsTableview.backgroundColor = self.view.backgroundColor;
    _contactsTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _contactsTableview.hidden = YES;
    [self.view addSubview:_contactsTableview];
    
    WeakSelf(self)
    [NetManager shareInstance].changeStatusBlock = ^(BOOL isConnect){
        [weakself setMessTabHeaderView:isConnect];
    };
    
    [self setMessTabHeaderView:[NetManager shareInstance].isNetConnected];
}

- (void)setMessTabHeaderView:(BOOL)isConnect
{
    if(!isConnect)
    {
        _messTableview.tableHeaderView = [self getNoNetHeaderView];
    }
    else
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 3)];
        headView.backgroundColor = self.view.backgroundColor;
        _messTableview.tableHeaderView = headView;
    }
    
    [self setupCustomCellView:isConnect];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _messTableview)
    {
        if(!_messTableview.hidden)
            tipLab.hidden = [YXManager sharedInstance].recentSessions.count>0;
        return [YXManager sharedInstance].recentSessions.count;
    }
    else
    {
        if(!_contactsTableview.hidden)
            tipLab2.hidden = [DDFriendsInfoManager sharedInstance].myFriendsArr.count>0;
        return [DDFriendsInfoManager sharedInstance].myFriendsArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _messTableview)
    {
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageListTableviewCell"];
        if(!cell)
        {
            cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageListTableviewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NIMRecentSession *recent = [YXManager sharedInstance].recentSessions[indexPath.row];
        NIMKitInfo *data = [[YXManager sharedInstance] getInfoBySession:recent];
        
        [cell.avatarImgView sd_setImageWithURL:URL(data.avatarUrlString) placeholderImage:DEFAULTAVATAR];
        cell.nameLab.text = data.showName;
        cell.timeLab.text = [NSDateDeal showTime:recent.lastMessage.timestamp showDetail:NO];
        cell.messLab.text = [[YXManager sharedInstance] getContentForRecentSession:recent];
        cell.line.hidden = indexPath.row == [YXManager sharedInstance].recentSessions.count-1;
        cell.redDot.hidden = recent.unreadCount == 0;
//        [cell.avatarImgView addTarget:self action:@selector(clickAvatar:)];
        cell.avatarImgView.tag = avatarTag+indexPath.row;
        
        FriendsModel *model = [[DDFriendsInfoManager sharedInstance] getFriendInfo:data.infoId];
        cell.vipImgView.hidden = model?!model.isVip:YES;
        return cell;
    }
    else
    {
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell"];
        if(!cell)
        {
            cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactsTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        FriendsModel *data = [DDFriendsInfoManager sharedInstance].myFriendsArr[indexPath.row];

        [cell.avatarImgView sd_setImageWithURL:URL(data.avatar) placeholderImage:DEFAULTAVATAR];
        cell.nameLab.text = data.remarks;
        [cell.nameLab setHeight:cellHeight-cell.nameLab.y*2];
        cell.line.hidden = indexPath.row == [DDFriendsInfoManager sharedInstance].myFriendsArr.count-1;
        [cell.avatarImgView addTarget:self action:@selector(clickAvatar:)];
        cell.avatarImgView.tag = avatarTag+indexPath.row;
        cell.vipImgView.hidden = !data.isVip;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _messTableview)
    {
        NIMRecentSession *recent = [YXManager sharedInstance].recentSessions[indexPath.row];
        NIMKitInfo *data = [[YXManager sharedInstance] getInfoBySession:recent];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:recent.session];
        [self.navigationController pushViewController:vc animated:YES];
        [vc settitleLabel:data.showName];
    }
    else
    {
        FriendsModel *user = [DDFriendsInfoManager sharedInstance].myFriendsArr[indexPath.row];
        NIMKitInfo *data = [[YXManager sharedInstance] getInfoByUserId:user.friendId];
        NIMSession *session = [NIMSession session:user.friendId type:NIMSessionTypeP2P];
        NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:vc animated:YES];
        [vc settitleLabel:data.showName];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return tableView == _messTableview;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NIMRecentSession *recentSession = [YXManager sharedInstance].recentSessions[indexPath.row];
        [[YXManager sharedInstance] deleteRecentSession:recentSession];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)clickAvatar:(UITapGestureRecognizer *)sender
{
    UIImageView *view = (UIImageView *)sender.view;
    if(_contactsTableview.hidden)
    {
        NIMRecentSession *recent = [YXManager sharedInstance].recentSessions[view.tag-avatarTag];
        NIMKitInfo *data = [[YXManager sharedInstance] getInfoBySession:recent];
        userID = data.infoId;
    }
    else
    {
        FriendsModel *user = [DDFriendsInfoManager sharedInstance].myFriendsArr[view.tag-avatarTag];
        userID = user.friendId;
    }
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

- (void)initYXBlocks
{
    WeakSelf(self)
    [YXManager sharedInstance].refreshConList = ^(){
        [weakself.messTableview reloadData];
    };
    
    [YXManager sharedInstance].refreshContact = ^(){
        [weakself.contactsTableview reloadData];
    };
}

- (UIView *)getNoNetHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 48)];
    view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(27.5, 9.5, 29, 29)];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.image = IMG(@"exclamationMark");
    [view addSubview:imgView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(77, 0, kMainScreenWidth-197, view.height)];
    lab.textColor = RGBCOLOR(153, 153, 153);
    lab.font = kFont16;
    lab.backgroundColor = kClearColor;
    [view addSubview:lab];
    lab.text = @"网络连接不可用";
    
    return view;
}

- (void)setupCustomCellView:(BOOL)isConnect
{
    int fy = isConnect?0:48;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, cellHeight*3+54+40+fy)];
    headerView.backgroundColor = kcolorWhite;
    
    if(!isConnect)
    {
        [headerView addSubview:[self getNoNetHeaderView]];
    }
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, fy, kMainScreenWidth, 54)];
    searchView.backgroundColor = RGBCOLOR(238, 238, 238);
    [headerView addSubview:searchView];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(20, 9, kMainScreenWidth-40, 36);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 5;
    searchBtn.backgroundColor = kcolorWhite;
    [searchView addSubview:searchBtn];
    [searchBtn setImage:[UIImage imageNamed:@"searchFriends"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 10, 8, searchBtn.width-10-20)];
    [searchBtn setTitle:@"搜索咚咚号/手机号" forState:UIControlStateNormal];
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    searchBtn.titleLabel.font = kFont15;
    [searchBtn setTitleColor:RGBCOLOR(186, 186, 186) forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(gotoSearchFriendVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *myAttentionView = [self createCustomCellView:[UIImage imageNamed:@"newFriend"] title:@"我的关注" rect:CGRectMake(0, searchView.bottom, kMainScreenWidth, cellHeight)];
    [myAttentionView addTarget:self action:@selector(gotoAttentionView)];
    [headerView addSubview:myAttentionView];
    [myAttentionView viewAddBottomLine];
    attentionsLab = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth-100, 0, 80, cellHeight)];
    attentionsLab.backgroundColor = kClearColor;
    attentionsLab.textColor = RGBCOLOR(153, 153, 153);
    attentionsLab.text = [NSString stringWithFormat:@"%lu", (unsigned long)[DDFriendsInfoManager sharedInstance].myAttentionsArr.count];
    attentionsLab.textAlignment = NSTextAlignmentRight;
    attentionsLab.font = kFont14;
    [myAttentionView addSubview:attentionsLab];
    
    UIView *myFansView = [self createCustomCellView:[UIImage imageNamed:@"myFans"] title:@"我的粉丝" rect:CGRectMake(0, myAttentionView.bottom, kMainScreenWidth, cellHeight)];
    [myFansView addTarget:self action:@selector(gotoFansView)];
    [headerView addSubview:myFansView];
    [myFansView viewAddBottomLine];
    fansLab = [[UILabel alloc] initWithFrame:CGRectMake(attentionsLab.x, attentionsLab.y, attentionsLab.width, attentionsLab.height)];
    fansLab.backgroundColor = kClearColor;
    fansLab.textColor = RGBCOLOR(153, 153, 153);
    fansLab.text = [NSString stringWithFormat:@"%lu", (unsigned long)[DDFriendsInfoManager sharedInstance].myFansArr.count];
    fansLab.textAlignment = NSTextAlignmentRight;
    fansLab.font = kFont14;
    [myFansView addSubview:fansLab];
    
    UIView *ddHelperView = [self createCustomCellView:[UIImage imageNamed:@"DDBear"] title:@"咚咚熊" rect:CGRectMake(0, myFansView.bottom, kMainScreenWidth, cellHeight)];
    [ddHelperView addTarget:self action:@selector(gotoDDHelperView)];
    [headerView addSubview:ddHelperView];
    
    UIView *myFriendsView = [[UIView alloc] initWithFrame:CGRectMake(0, ddHelperView.bottom, kMainScreenWidth, 40)];
    myFriendsView.backgroundColor = searchView.backgroundColor;
    [headerView addSubview:myFriendsView];
    NSString *str = @"我的好友";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, myFriendsView.width-20, myFriendsView.height)];
    label.backgroundColor = kClearColor;
    label.textColor = RGBCOLOR(153, 153, 153);
    label.text = str;
    label.font = kFont16;
    [myFriendsView addSubview:label];
    
    _contactsTableview.tableHeaderView = headerView;
}

- (UIView *)createCustomCellView:(UIImage *)aBtImg title:(NSString *)aTitle rect:(CGRect)aRect
{
    UIView *customBtView = [[UIView alloc] initWithFrame:aRect];
    customBtView.backgroundColor = kcolorWhite;
    CGSize tsize = [aTitle sizeWithFont:kFont18];
    int offsetx = aBtImg.size.width==aBtImg.size.height?15:19;
    int imgoffsety = 10;
    int toffsety = (customBtView.height-tsize.height)/2;
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(offsetx, imgoffsety, aBtImg.size.width/aBtImg.size.height*(cellHeight-imgoffsety*2), cellHeight-imgoffsety*2)];
    [imgview setImage:aBtImg];
    [customBtView addSubview:imgview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgview.right+10, toffsety, tsize.width, tsize.height)];
    label.backgroundColor = kClearColor;
    label.textColor = kColorBlack;
    label.text = aTitle;
    label.font = kFont16;
    [customBtView addSubview:label];
    return customBtView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
