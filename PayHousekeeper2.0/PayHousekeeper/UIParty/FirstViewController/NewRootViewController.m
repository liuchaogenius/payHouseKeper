//
//  NewRootViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "NewRootViewController.h"
#import "FourthViewController.h"
#import "ThirdViewController.h"
#import "MatchingViewController.h"
#import "NetManager.h"
#import "ToolsViewControl.h"
#import "EditMoodsControl.h"
#import "DDLoginManager.h"
#import "UIButton+WebCache.h"
#import "GoMatchVCTransition.h"
#import "PersonHeaderView.h"
#import "PersonDetailView.h"
#import "MyWalletViewController.h"
#import "LocationManager.h"
#import "PersonInfoManager.h"
#import "IQKeyboardManager.h"

#define TipViewTag 200

@interface NewRootViewController ()<UINavigationControllerDelegate>
{
    UIButton *topLeftBt,*topRightBt;
    UISwitch *topMiddleSwitch;
    UIButton *bottomLeftBt,*bottomMiddleBt,*bottomRightBt;
    CGFloat magrinX;
    NSTimer *timer;
    UIImageView *dressupImgView;
    PersonHeaderView *headView;
    PersonHeaderModel *headModel;
    
    UIImageView *redDot;
    UIView   *clearView;
    
    UILabel *timeTipLab;
    BOOL isClicked;
}
@property (nonatomic, strong)PersonDetailView *detailView;
@end

@implementation NewRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.delegate = self;
    
    [[GPUImageManager sharedInstance] clearImg];
    isClicked = NO;
    [self initTimer];
    redDot.hidden = [[YXManager sharedInstance] getAllUnreadCount] == 0;
    __weak UIImageView *weakImg = redDot;
    [YXManager sharedInstance].refreshConList = ^(){
        weakImg.hidden = [[YXManager sharedInstance] getAllUnreadCount] == 0;
    };
    
//    WeakSelf(self)
    __weak UIButton *weakBtn = bottomMiddleBt;
    [NetManager shareInstance].changeStatusBlock = ^(BOOL isConnect){
        weakBtn.enabled = isConnect;
//        if(isConnect)
//        {
//            [weakself initTimer];
//        }
//        else
//        {
//            [weakself stopTimer];
//        }
    };
    
//    NSString *name = [UserInfoData shareUserInfoData].strUserNick;
//    headView.nameLabel.text = name;
    if (headView)
    {
        [headView removeFromSuperview];
        [self initHeadView];
    }
    
    dressupImgView.hidden = [GPUImageManager sharedInstance].dressupIndex == -1;
    if(!dressupImgView.hidden)
    {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_dressup%ld",[UserInfoData shareUserInfoData].sexType == 0?@"man":@"female",(long)[GPUImageManager sharedInstance].dressupIndex]];
        dressupImgView.image = img;
        [dressupImgView sizeToFit];
        if([UserInfoData shareUserInfoData].sexType == 0)
            [dressupImgView setX:headView.x];
        else
            [dressupImgView setRight:kMainScreenWidth-headView.x];
        [dressupImgView setY:headView.bottom+10];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [DLAPPDELEGATE.newtabr hiddenMatchBtns];
    [[GPUImageManager sharedInstance] stop];
//    [[IQKeyboardManager sharedManager] setEnable:YES];
    if(self.detailView)
    {
        [self.detailView dismiss];
    }
//    [self stopTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick event:MsgHomeEnter];
//    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    NSString *key = [NSString stringWithFormat:@"firstEnterHomePage_%@",[UserInfoData shareUserInfoData].strUserId];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:key])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showSetBlurTipView];
    }
    else
    {
        [self showClickStartTip:YES];
    }
    
    [self checkCameraService];
    
    bottomMiddleBt.enabled = [NetManager shareInstance].isNetConnected;
}

- (void)checkCameraService
{
    WeakSelf(self)
    [[GPUImageManager sharedInstance] checkCameraService:^(BOOL result) {
        if (result)
        {
            [weakself initCaptureSession];
            [weakself removeImageView:8888];
        }
        else
        {
            [weakself initNoCameraView];
        }
    }];
}

- (void)removeImageView:(NSInteger)tag
{
    for(UIImageView *view in clearView.subviews)
    {
        if(view.tag == tag)
        {
            [view removeFromSuperview];
            return;
        }
    }
}

- (void)initNoCameraView
{
    
    [self removeImageView:8888];

    UIImageView *imgView = [[UIImageView alloc] initWithFrame:clearView.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [imgView sd_setImageWithURL:URL([UserInfoData shareUserInfoData].strHeadUrl) placeholderImage:[[GPUImageManager sharedInstance] getBlurImage:DEFAULTCALLBG] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error && image)
            imgView.image = [[GPUImageManager sharedInstance] getBlurImage:image];
    }];
    imgView.tag = 8888;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 232, kMainScreenWidth, 15)];
    lab.text = @"视频前需要打开相机权限";
    lab.textColor = kcolorWhite;
    lab.textAlignment = NSTextAlignmentCenter;
    [imgView addSubview:lab];
    lab.font = kFont15;
    [clearView insertSubview:imgView atIndex:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    magrinX = 12;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    clearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    clearView.backgroundColor = [UIColor lightGrayColor];
    
    UIImageView *tmpImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    tmpImg.image = DEFAULTCALLBG;
    tmpImg.contentMode = UIViewContentModeScaleAspectFill;
    [clearView insertSubview:tmpImg atIndex:0];

    [self.view addSubview:clearView];
    [[LocationManager sharedInstance] start];
    
    timeTipLab = [[UILabel alloc] initWithFrame:clearView.bounds];
    [clearView addSubview:timeTipLab];
    timeTipLab.text = @"公测期 晚上9~11点\n人多热闹，记得来噢~";
    timeTipLab.numberOfLines = 0;
    timeTipLab.textAlignment = NSTextAlignmentCenter;
    timeTipLab.font = [UIFont boldSystemFontOfSize:17];
    timeTipLab.textColor = kcolorWhite;
    timeTipLab.hidden = YES;
    
    [self setNavgationBarClear];
    [self initHeadView];
//    [self createButtonView];
    
//    NSString *key = [NSString stringWithFormat:@"firstEnterHomePage_%@",[UserInfoData shareUserInfoData].strUserId];
//    if([[NSUserDefaults standardUserDefaults] boolForKey:key])
//        [self showClickStartTip:YES];
    
    PersonInfoManager *manager = [[PersonInfoManager alloc] init];
    [manager requestMyWallet:^(MyWalletData *data) {
        
    }];
}

- (void)initHeadView
{
    PersonHeaderModel *model = [[PersonHeaderModel alloc] init];
    OtherUserInfoData *user = [[OtherUserInfoData alloc] init];
    [user unPakceUserInfo:[UserInfoData shareUserInfoData]];
    [model unPackeDictFromOtherUserInfo:user];
    headView = [[PersonHeaderView alloc] initWithFrame:CGRectMake(12, 30, 200, 80) headerModel:model];
    [headView.attentionBtn addTarget:self action:@selector(headButtonTapItem:) forControlEvents:UIControlEventTouchUpInside];
    [headView.headerBtn addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
    [headView.bottomView addTarget:self action:@selector(writeMsgButtonItem)];
    [clearView addSubview:headView];

}

- (void)refreshHeadView
{
    PersonHeaderModel *model = [[PersonHeaderModel alloc] init];
    [model unPackeDictFromUserInfo:[UserInfoData shareUserInfoData]];
    [headView refresh:model];
}

- (void)showSetBlurTipView
{
    UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake(-2, -2, kMainScreenWidth+4, kMainScreenHeight+4)];
    tipView.contentMode = UIViewContentModeScaleAspectFill;
    tipView.image = IMG(@"blurTip");
    [clearView addSubview:tipView];
    tipView.tag = TipViewTag;
    [tipView addTarget:self action:@selector(hideTipView)];
//    [self performSelector:@selector(hideTipView) withObject:nil afterDelay:2];
}

- (void)createButtonView
{
//    topLeftBt = [self.view buttonWithFrame:CGRectMake(magrinX, 64, 40, 40) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
////    [topLeftBt setImage:[UIImage imageNamed:@"frist_headimg"] forState:UIControlStateNormal];
//    [topLeftBt sd_setImageWithURL:URL([UserInfoData shareUserInfoData].strHeadUrl) forState:UIControlStateNormal placeholderImage:IMG(@"frist_headimg")];
//    [topLeftBt addTarget:self action:@selector(headButtonTapItem:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:topLeftBt];
//    topLeftBt.clipsToBounds = YES;
//    topLeftBt.layer.cornerRadius = topLeftBt.height/2.0;
    
    topRightBt = [clearView buttonWithFrame:CGRectMake(kMainScreenWidth-12-40, headView.top+5, 40, 40) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [topRightBt setImage:[UIImage imageNamed:@"first_contact"] forState:UIControlStateNormal];
    [topRightBt addTarget:self action:@selector(friendButtonTapItem:) forControlEvents:UIControlEventTouchUpInside];
    [clearView addSubview:topRightBt];
    redDot = [[UIImageView alloc] initWithFrame:CGRectMake(topRightBt.width-10, 2, 8, 8)];
    redDot.clipsToBounds = YES;
    redDot.layer.cornerRadius = 4;
    redDot.backgroundColor = [UIColor redColor];
    [topRightBt addSubview:redDot];
    redDot.hidden = [[YXManager sharedInstance] getAllUnreadCount] == 0;
    
    bottomLeftBt = [clearView buttonWithFrame:CGRectMake(headView.left, clearView.height-10-40, 40, 40) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [bottomLeftBt setImage:[UIImage imageNamed:@"first_dressup"] forState:UIControlStateNormal];
    [bottomLeftBt addTarget:self action:@selector(meiyanButtonTapItem:) forControlEvents:UIControlEventTouchUpInside];
    [clearView addSubview:bottomLeftBt];
    
    bottomMiddleBt = [clearView buttonWithFrame:CGRectMake((kMainScreenWidth-65)/2, clearView.height-10-66, 65,65) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [bottomMiddleBt setImage:[UIImage imageNamed:@"first_start"] forState:UIControlStateNormal];
    [bottomMiddleBt setImage:[UIImage imageNamed:@"first_startPressed"] forState:UIControlStateHighlighted];
    [bottomMiddleBt setImage:[UIImage imageNamed:@"first_disableStart"] forState:UIControlStateDisabled];
    [bottomMiddleBt addTarget:self action:@selector(shipinButtonTapItem:) forControlEvents:UIControlEventTouchUpInside];
//    bottomMiddleBt.enabled = [self isOKTime];
    [clearView addSubview:bottomMiddleBt];
    
    bottomRightBt = [clearView buttonWithFrame:CGRectMake(kMainScreenWidth-12-40, clearView.height-10-40, 40, 40) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [bottomRightBt setImage:[UIImage imageNamed:@"first_seaitchCamera"] forState:UIControlStateNormal];
    [bottomRightBt addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [clearView addSubview:bottomRightBt];
    
    dressupImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    dressupImgView.backgroundColor = [UIColor clearColor];
    [clearView addSubview:dressupImgView];
}

- (void)initCaptureSession
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [clearView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:1];
        [[GPUImageManager sharedInstance] start:NO];
    });
}

#pragma mark 头像按钮button事件
- (void)headButtonTapItem:(UIButton *)aBt
{
    FourthViewController *vc = [[FourthViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 收益按钮button事件
- (void)walletButtonTapItem:(UIButton *)aBt
{
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    self.statusBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.statusBarView];
    
    MyWalletViewController *vc = [[MyWalletViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 进好友列表button事件
- (void)friendButtonTapItem:(UIButton *)aBt
{
    self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    self.statusBarView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:self.statusBarView];
    
    [MobClick event:MsgClickFriend];
    ThirdViewController *vc = [[ThirdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 美颜效果button事件
- (void)meiyanButtonTapItem:(UIButton *)aBt
{
    ToolsViewControl *toolsView = [[ToolsViewControl alloc] init];
    [toolsView show];
    __weak UIImageView *weakImgView = dressupImgView;
    __weak PersonHeaderView *weakHeadView = headView;
    toolsView.selectValue = ^(NSInteger index){
        if(index == [GPUImageManager sharedInstance].dressupIndex)
        {
            [GPUImageManager sharedInstance].dressupIndex = -1;
            weakImgView.hidden = YES;
        }
        else
        {
            weakImgView.hidden = NO;
            [GPUImageManager sharedInstance].dressupIndex = index;
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_dressup%ld",[UserInfoData shareUserInfoData].sexType == 0?@"man":@"female",(long)index]];
            weakImgView.image = img;
            [weakImgView sizeToFit];
            if([UserInfoData shareUserInfoData].sexType == 0)
                [weakImgView setX:weakHeadView.x];
            else
                [weakImgView setRight:kMainScreenWidth-weakHeadView.x];
            [weakImgView setY:weakHeadView.bottom+10];
        }
    };
}

#pragma mark 底部中间视频button事件
- (void)shipinButtonTapItem:(UIButton *)aBt
{
    if(isClicked)
        return;
    
    if ([GPUImageManager sharedInstance].isOpenCameraService)
    {
        isClicked = YES;
        [MobClick event:MsgClickStart];
        MatchingViewController *vc = [[MatchingViewController alloc] init];
        vc.isOkTime = [[DDSystemInfoManager sharedInstance] isOKTime];
//            if([DDSystemInfoManager sharedInstance].isOn)
//            {
//                vc.isOkTime = [weakself isOKTime];
//            }
//            else
//            {
//                vc.isOkTime = YES;
//            }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"视频前需要打开相机权限"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark 写心情button事件
- (void)writeMsgButtonItem
{
//    WeakSelf(self)
    [[EditMoodsControl sharedInstance] show];
    __weak PersonHeaderView *weakHeadView = headView;
    [[EditMoodsControl sharedInstance]setMood:headView.feeling];
    [EditMoodsControl sharedInstance].endEditMoods = ^(NSString *string){

        [[DDLoginManager shareLoginManager] requestMood:string completeBlock:^(BOOL ret) {
            if(ret)
            {
                weakHeadView.feeling = string;
            }
        }];
    
    };
}

#pragma mark 切换摄像头
- (void)switchCamera:(UIButton *)aBt
{
    if(aBt.selected)
        return;
    aBt.selected = YES;
    [[GPUImageManager sharedInstance] switchCamera];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        aBt.selected = NO;
    });
}

- (void)hideTipView
{
    UIImageView *tipView = (UIImageView *)[clearView viewWithTag:TipViewTag];
    if(tipView)
    {
        WeakSelf(self)
        [UIView animateWithDuration:1
                              delay:0
                            options:0
                         animations:^{
                             tipView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [tipView removeFromSuperview];
                             [weakself showClickStartTip:YES];
                         }];
    }
}

- (void)showClickStartTip:(BOOL)isTimeOK
{
    [self removeImageView:999];

    UIImageView *tipView = [[UIImageView alloc] initWithImage:(isTimeOK?IMG(@"startTipBG"):IMG(@"timeTipBG"))];
    tipView.center = clearView.center;
    [tipView setBottom:clearView.height-10-66-10];
    [clearView addSubview:tipView];
    tipView.tag = 999;
    tipView.alpha = 0;
    
//    NSString *timeStr = @"";
//    for(NSDictionary *dic in [DDSystemInfoManager sharedInstance].timeArr)
//    {
//        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%@-%@\n",[dic objectForKey:@"startTime"],[dic objectForKey:@"endTime"]]];
//    }
//    timeStr = [timeStr stringByAppendingString:@"每天不见不散"];
//    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tipView.width, tipView.height-10)];
//    [tipView addSubview:lab];
//    lab.backgroundColor = [UIColor clearColor];
//    lab.text = isTimeOK?@"":timeStr;
//    lab.textColor = kcolorWhite;
//    lab.font = kFont14;
//    lab.textAlignment = NSTextAlignmentCenter;
//    lab.numberOfLines = 0;
    
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         tipView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
//                         [UIView animateWithDuration:1
//                                               delay:1
//                                             options:0
//                                          animations:^{
//                                              tipView.alpha = 0;
//                                          }
//                                          completion:^(BOOL finished) {
//                                              [tipView removeFromSuperview];
//                                          }];
                     }];
}



- (void)showDetail
{
    WeakSelf(self)
    [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(NSDictionary *dataDic) {
        if(dataDic)
        {
            PersonDetailModel *user = [[PersonDetailModel alloc] init];
            [user unPackeDict:dataDic];
            user.profitValue = [NSString stringWithFormat:@"%lld",[UserInfoData shareUserInfoData].shellCount];
            PersonDetailView *view = [[PersonDetailView alloc] initWithDetailModel:user];
            [view showInView:self.view];
            weakself.detailView = view;
            [view.bottomBtn addTarget:weakself action:@selector(goToDetailView:) forControlEvents:UIControlEventTouchUpInside];
            [view.profitBtn addTarget:weakself action:@selector(goToMyWalletView:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

- (void)goToDetailView:(UIButton *)btn
{
    [self performSelector:@selector(headButtonTapItem:) withObject:headView.attentionBtn afterDelay:0.1];
}

- (void)goToMyWalletView:(UIButton *)btn
{
    PersonDetailView *view = (PersonDetailView *)btn.superview;
    [self performSelector:@selector(walletButtonTapItem:) withObject:view.profitBtn afterDelay:0.1];


}

- (void)initTimer
{
    [self stopTimer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
}

- (void)checkTime
{
    timeTipLab.hidden = [[DDSystemInfoManager sharedInstance] isOKTime4Lab];
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

//#pragma mark 毛玻璃按钮事件
//- (void)switchAction:(UISwitch *)aIsOn
//{
//    effectview.hidden = !aIsOn.isOn;
//}

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

#pragma mark - UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[MatchingViewController class]])
    {
        GoMatchVCTransition *transition = [[GoMatchVCTransition alloc] init];
        transition.isPush = YES;
        return transition;
    }
    else{
        return nil;
    }
}
@end
