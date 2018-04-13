//
//  NTESVideoChatViewController.m
//  NIM
//
//  Created by chris on 15/5/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESVideoChatViewController.h"
#import "UIView+Toast.h"
#import "NetCallChatInfo.h"
#import "NTESSessionUtil.h"
#import "NTESGLView.h"
#import "NTESBundleSetting.h"
#import "ToolsViewControl.h"
#import "GiftModel.h"
#import "GiftControl.h"
#import "NetManager.h"
#import "DongBiViewController.h"
#import "VideoChatBottomView.h"
#import "PersonHeaderView.h"
#import "BlurControlView.h"
#import "PersonDetailModel.h"
#import "PersonDetailView.h"
#import "SPActionSheet.h"
#import "SPAlertView.h"
#import "PersonInfoManager.h"
#import "WaveView.h"
#import "LikeImageView.h"

#define NTESUseGLView

#define CALLBTNWIDTH 66
#define CALLBTNHEIGHT 90

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypeGradient = 0,
    AnimationTypeReport,
    AnimationTypeBlur,
    AnimationTypeSwitch,
    AnimationTypeLike,
    AnimationTypeGift
};

@interface NTESVideoChatViewController ()<NIMSystemNotificationManagerDelegate,CAAnimationDelegate,SPActionSheetDelegate,SPAlertViewDelegate>
{
    BOOL isCaller,isGoRootVC;
//    NSTimer *countTimer;
    int likeTimes,byLikeTimes;
    SPActionSheet *actionsheet;
    UIView *preView;
    AnimationType animationType;
    int discType;
    
    CGPoint startLocation;
    BOOL needTransform;
    
//    NSTimer *timer4Blur;
    float currenBlurValue;
    
    dispatch_source_t timer4Blur;
    dispatch_source_t countTimer;
    dispatch_source_t netStatusTimer;
    
    BOOL isSwitchCamera;
    NIMNetCallVideoQuality videoQuality;
}
@property (nonatomic,strong) UIImageView    *remoteView;                  //远程预览
@property (nonatomic,strong) UIButton       *hungUpBtn;                   //挂断按钮
@property (nonatomic,strong) UIButton       *reportBtn;                   //举报按钮
@property (nonatomic,strong) UIButton       *acceptBtn;                   //接通按钮
@property (nonatomic,strong) UIButton       *refuseBtn;                   //拒接按钮
@property (strong,nonatomic) UIButton       *cancelConnectBtn;            //取消按钮
@property (strong,nonatomic) LocalView      *localBGView;                 //本地预览背景视图
@property (strong,nonatomic) UIImageView    *giftAnimationImgView;        //礼物动画特效视图
@property (strong,nonatomic) BroadcastView  *broadcastView;               //广播视图

@property (nonatomic,assign) NIMNetCallCamera cameraType;

@property (nonatomic,assign) BOOL isGotoRechargeVC, isSwithVideoQuality;

@property (nonatomic,assign) int  totalTime;

#if defined (NTESUseGLView)
@property (nonatomic,strong) NTESGLView *remoteGLView;
#endif

@property (nonatomic,strong) UIImageView *dressupImgView;
@property (nonatomic,strong) UIView *swipeGestureView;
@property (nonatomic,strong) VideoChatBottomView *bottomView;
@property (nonatomic,strong) PersonHeaderView *headView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) BlurControlView *blurView;
@property (nonatomic, strong) PersonDetailView *detailView;
@property (nonatomic, strong) UIButton *tipControl;
@property (nonatomic, strong) WaveView *waveView;
@property (nonatomic, strong) GiftControl *giftsView;
@property (nonatomic, strong) SPAlertView *alert;

@property (nonatomic, strong) UILabel  *likeTimeTipLab;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic,strong) NetCallChatInfo *callInfo;

@end

@implementation NTESVideoChatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    _isGotoRechargeVC = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    if(!_isGotoRechargeVC)
    {
        if([YXManager sharedInstance].connectBlock)
        {
            if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
            {
                [YXManager sharedInstance].connectBlock(ConnectState_HANGUP_BYUSER);
            }
            else
            {
                [YXManager sharedInstance].connectBlock(_totalTime<=2?ConnectState_HANGUP_BYTIMER:ConnectState_HANGUP_BYUSER);
            }
        }
        [[DDSystemInfoManager sharedInstance] stopBroadcastTimer];
        
        [self freeMemory];
    }
    
    if(self.giftsView)
        [self.giftsView dismiss];
    
    if(self.detailView)
        [self.detailView dismiss];
    
    if(self.alert)
        [self.alert dismiss];
    
    if(self.tipControl)
    {
        [self.tipControl removeFromSuperview];
        self.tipControl = nil;
    }
    if (actionsheet)
    {
        [actionsheet dismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YXManager sharedInstance] disableCammera:NO];
    [self initCaptureSession];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if(![YXManager sharedInstance].callInfo)
    {
        [self dismiss];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [GPUImageManager sharedInstance].flag = YES;
    
    videoQuality = NIMNetCallVideoQualityHigh;
        
    discType = 1;
    
    _totalTime = 90;
    if([UserInfoData shareUserInfoData].isVip || self.userInfo.isVip)
        _totalTime = 120;
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rosterInfoChanged)
                                                 name:RosterInfoChangedNotification
                                               object:nil];
}

- (void)setYXCallLifeBlocks
{
    WeakSelf(self)
    [YXManager sharedInstance].startByCallerBlock = ^(){
        [weakself startByCaller];
    };
    
    [YXManager sharedInstance].startByCalleeBlock = ^(){
        [weakself startByCallee];
    };
    
    [YXManager sharedInstance].onCallingBlock = ^(){
        [weakself onCalling];
    };
    
    [YXManager sharedInstance].waitForConnectiongBlock = ^(){
        [weakself waitForConnectiong];
    };
    
    [YXManager sharedInstance].dismissBlock = ^(){
        [weakself dismiss];
    };
    
    [YXManager sharedInstance].onRemoteYUVBlock = ^(NSData *yuvData, NSUInteger width, NSUInteger height, NSString *user){
        [weakself onRemoteYUVReady:yuvData width:width height:height from:user];
    };
    
    [YXManager sharedInstance].onLocalPreviewReadyBlock = ^(){
        [weakself onLocalPreviewReady];
    };
    
    [YXManager sharedInstance].onReceiveCustomSystemNotificationBlock = ^(NIMCustomSystemNotification *notification){
        [weakself onReceiveCustomSystemNotification:notification];
    };
    
    [YXManager sharedInstance].netStateBlock = ^(UInt64 callID, NIMNetCallNetStatus status){
        [weakself onCall:callID netStatus:status];
    };
}

- (void)rosterInfoChanged
{
    [self refreshDetailView];
    [self updateCountTimer];
}

- (void)refreshDetailView
{
    
    if(!self.detailView)
        return;
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
    {
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"互相关注" forState:UIControlStateNormal];
    }
    else if([[DDFriendsInfoManager sharedInstance] isAttentioned:self.userInfo.strUserId])
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

- (void)updateCountTimer
{
    if(![[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        [self initCountTimer];
    else
        [self stopCountTimer];
}

- (void)dealloc
{
    NSString *str = @"";
    int callTime = [self.durationDesc intValue];
    if(callTime < 0)
        return;
    else if(callTime < 90)
        str = @"90秒内手动切换";
    else if(callTime == 90)
        str = @"90秒自动切换换";
    else
        str = @"90秒后自动切换换";
    [MobClick event:MsgCallTime attributes:@{@"type" : str} counter:callTime];
}

#pragma mark - 懒加载
- (UIImageView *)remoteView
{
    if (!_remoteView)
    {
        _remoteView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _remoteView.image = DEFAULTCALLBG;
        _remoteView.contentMode = UIViewContentModeScaleAspectFill;
//        _remoteView.transform = CGAffineTransformScale(_remoteView.transform, -1.0, 1.0);
    }
    return _remoteView;
}

- (UIButton *)refuseBtn
{
    if(!_refuseBtn)
    {
        _refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refuseBtn.frame = CGRectMake(62, kMainScreenHeight-42-CALLBTNHEIGHT, CALLBTNWIDTH, CALLBTNHEIGHT);
        [_refuseBtn setImage:IMG(@"waitingrefuses") forState:UIControlStateNormal];
        [_refuseBtn addTarget:self action:@selector(acceptToCall:) forControlEvents:UIControlEventTouchUpInside];
        [_refuseBtn setTitle:@"忽略" forState:UIControlStateNormal];
        _refuseBtn.titleLabel.font = kFont15;
        [_refuseBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, CALLBTNHEIGHT-CALLBTNWIDTH, 0)];
        [_refuseBtn setTitleEdgeInsets:UIEdgeInsetsMake(CALLBTNWIDTH+15, -CALLBTNWIDTH, -15, 0)];
    }
    return _refuseBtn;
}

- (UIButton *)acceptBtn
{
    if(!_acceptBtn)
    {
        _acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _acceptBtn.frame = CGRectMake(kMainScreenWidth-62-CALLBTNWIDTH, kMainScreenHeight-42-CALLBTNHEIGHT, CALLBTNWIDTH, CALLBTNHEIGHT);
        [_acceptBtn setImage:IMG(@"waitingConnect") forState:UIControlStateNormal];
        [_acceptBtn addTarget:self action:@selector(acceptToCall:) forControlEvents:UIControlEventTouchUpInside];
        [_acceptBtn setTitle:@"接听" forState:UIControlStateNormal];
        _acceptBtn.titleLabel.font = kFont15;
        [_acceptBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, CALLBTNHEIGHT-CALLBTNWIDTH, 0)];
        [_acceptBtn setTitleEdgeInsets:UIEdgeInsetsMake(CALLBTNWIDTH+15, -CALLBTNWIDTH, -15, 0)];
    }
    return _acceptBtn;
}

- (UIButton *)cancelConnectBtn
{
    if(!_cancelConnectBtn)
    {
        _cancelConnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelConnectBtn.frame = CGRectMake((kMainScreenWidth-CALLBTNWIDTH)/2.0, kMainScreenHeight-42-CALLBTNHEIGHT, CALLBTNWIDTH, CALLBTNHEIGHT);
        [_cancelConnectBtn setImage:IMG(@"waitingrefuses") forState:UIControlStateNormal];
        [_cancelConnectBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        [_cancelConnectBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelConnectBtn.titleLabel.font = kFont15;
        [_cancelConnectBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, CALLBTNHEIGHT-CALLBTNWIDTH, 0)];
        [_cancelConnectBtn setTitleEdgeInsets:UIEdgeInsetsMake(CALLBTNWIDTH+15, -CALLBTNWIDTH, -15, 0)];
    }
    return _cancelConnectBtn;
}

- (VideoChatBottomView *)bottomView
{
    if(!_bottomView)
    {
        _bottomView = [[VideoChatBottomView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-60, kMainScreenWidth, 50)];
        
        WeakSelf(self)
        _bottomView.clickBlock = ^(int index){
            switch (index)
            {
                case 0://装扮
                    [weakself dressupBtnClick];
                    break;
                case 1://喜欢
                    [weakself likeBtnClick];
                    break;
                case 2://礼物
                    [weakself giftBtnClick];
                    break;
                case 3://换人
                    [weakself switchPerson];
                    break;
                case 4://切换摄像头
                    [weakself switchCamera];
                    break;
                default:
                    break;
            }
        };
    }
    return _bottomView;
}

- (UIButton *)hungUpBtn
{
    if(!_hungUpBtn)
    {
        _hungUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hungUpBtn.frame = CGRectMake(kMainScreenWidth-51+5, self.headView.y+5, 40, 40);
        [_hungUpBtn setImage:IMG(@"hungupBtn") forState:UIControlStateNormal];
        [_hungUpBtn addTarget:self action:@selector(goRootVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hungUpBtn;
}

- (UIButton *)reportBtn
{
    if(!_reportBtn)
    {
        _reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reportBtn.frame = CGRectMake(self.hungUpBtn.x-45, self.hungUpBtn.y, 40, 40);
        [_reportBtn setImage:IMG(@"reportBtn_normal") forState:UIControlStateNormal];
        [_reportBtn setImage:IMG(@"reportBtn_selected") forState:UIControlStateHighlighted];
        [_reportBtn addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reportBtn;
}

- (LocalView *)localBGView
{
    if(!_localBGView)
    {
        float width = 96*kScale;
        float height = 136*kScale;
        _localBGView = [[LocalView alloc] initWithFrame:CGRectMake(kMainScreenWidth-width-12, kMainScreenHeight-height-67.5, width, height)];
        _localBGView.backgroundColor = [UIColor whiteColor];
//        [_localBGView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

        preView = [[UIView alloc] initWithFrame:CGRectMake(1.5, 1.5, _localBGView.width-3, _localBGView.height-3)];
        [_localBGView addSubview:preView];
    }
    return _localBGView;
}

- (UIImageView *)giftAnimationImgView
{
    if(!_giftAnimationImgView)
    {
        _giftAnimationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _giftAnimationImgView.contentMode = UIViewContentModeScaleAspectFit;
        _giftAnimationImgView.userInteractionEnabled = YES;
    }
    return _giftAnimationImgView;
}

- (UIImageView *)dressupImgView
{
    if(!_dressupImgView)
    {
        _dressupImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dressupImgView.backgroundColor = [UIColor clearColor];
    }
    return _dressupImgView;
}

- (BroadcastView *)broadcastView
{
    if(!_broadcastView)
    {
        _broadcastView = [[BroadcastView alloc] initWithFrame:CGRectMake(kMainScreenWidth, self.headView.bottom+30, kMainScreenWidth-20, 35)];
        _broadcastView.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    }
    return _broadcastView;
}

- (PersonHeaderView *)headView
{
    if(!_headView)
    {
        PersonHeaderModel *model = [[PersonHeaderModel alloc] init];
        [model unPackeDictFromOtherUserInfo:self.userInfo];
        _headView = [[PersonHeaderView alloc] initWithFrame:CGRectMake(20, 30, 200, 80) headerModel:model];
        [_headView.attentionBtn setTitle:([[DDFriendsInfoManager sharedInstance] isAttentioned:self.userInfo.strUserId]?@"已关注":@"关注") forState:UIControlStateNormal];
        [_headView.attentionBtn addTarget:self action:@selector(clickAttentionBtn) forControlEvents:UIControlEventTouchUpInside];
        [_headView.headerBtn addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headView;
}

- (UIView *)swipeGestureView
{
    if(!_swipeGestureView)
    {
        _swipeGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, kMainScreenWidth, kMainScreenHeight-110-self.bottomView.height-30)];
        _swipeGestureView.backgroundColor = [UIColor clearColor];
    }
    return _swipeGestureView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if(!_panGestureRecognizer)
    {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    }
    return _panGestureRecognizer;
}

- (BlurControlView *)blurView
{
    if(!_blurView)
    {
        _blurView = [[BlurControlView alloc] initWithFrame:CGRectMake(self.localBGView.x-10, self.localBGView.y, self.localBGView.width+10, self.localBGView.height)];
        WeakSelf(self)
        _blurView.movingBlock = ^(BOOL isMoving)
        {
            if(!weakself.callInfo)
                return ;
            [weakself cleanBlurTimer];
            if(isMoving)
            {
                [weakself.view removeGestureRecognizer:weakself.tap];
                [weakself.swipeGestureView removeGestureRecognizer:weakself.panGestureRecognizer];
            }
            else
            {
                [weakself.swipeGestureView addGestureRecognizer:weakself.panGestureRecognizer];
                [weakself.view addGestureRecognizer:weakself.tap];
            }
        };
    }
    return _blurView;
}

- (UIButton *)tipControl
{
    if(!_tipControl)
    {
        _tipControl = [UIButton buttonWithType:UIButtonTypeCustom];
        _tipControl.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        [_tipControl addTarget:self action:@selector(hideTip) forControlEvents:UIControlEventTouchUpInside];
        _tipControl.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tipControl];
        _tipControl.hidden = YES;
        _tipControl.userInteractionEnabled = NO;
    }
    return _tipControl;
}

- (UIView *)waveView
{
    if(!_waveView)
    {
        _waveView = [[WaveView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 70)];
        _waveView.backgroundColor = [UIColor clearColor];
        _waveView.hidden = YES;
        _waveView.userInteractionEnabled = NO;
    }
    return _waveView;
}

- (UITapGestureRecognizer *)tap
{
    if(!_tap)
    {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAndhideBlurView)];
    }
    return _tap;
}


- (void)initCaptureSession
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.immediate)
        {
            [preView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:0];
            [[GPUImageManager sharedInstance] adjustBounds];
            
        }
        else
        {
            if(isCaller)
            {
                [self.remoteView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:0];
                [[GPUImageManager sharedInstance] adjustBounds];
            }
            else
            {
                [preView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:0];
                [[GPUImageManager sharedInstance] adjustBounds];
            }
        }
    });
}

- (void)initBtns
{
    //是否接听按钮
    [self.view addSubview:self.refuseBtn];
    [self.view addSubview:self.acceptBtn];
    [self.view addSubview:self.cancelConnectBtn];
    [self.view addSubview:self.hungUpBtn];
    [self.view addSubview:self.reportBtn];
}

- (void)initUI
{
    //远程预览
    [self.view addSubview:self.remoteView];
    WeakSelf(self)
    [self.remoteView sd_setImageWithURL:URL(self.userInfo.strHeadUrl) placeholderImage:DEFAULTCALLBG completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakself.remoteView performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[[GPUImageManager sharedInstance] getBlurImage:image] waitUntilDone:YES];
//        weakself.remoteView.image = [[GPUImageManager sharedInstance] getBlurImage:image];
    }];
    
//    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//    {
//        [self initRemoteGLView];
//    }
    
    [self initBtns];
    
    [self.view addSubview:self.swipeGestureView];
    self.swipeGestureView.hidden = YES;
    
    [self.view addSubview:self.bottomView];
    
    [self.view addSubview:self.headView];
    
    [self.view addSubview:self.localBGView];
    
    
    [self.view addSubview:self.giftAnimationImgView];
    self.giftAnimationImgView.hidden = YES;
    
    [self.view addSubview:self.dressupImgView];
    
    [self.view addSubview:self.broadcastView];
    [self.broadcastView setX:kMainScreenWidth];
    
    [self.swipeGestureView addGestureRecognizer:self.panGestureRecognizer];
    
    [self.view addSubview:self.blurView];
    self.blurView.hidden = YES;
    
    [self.view addSubview:self.waveView];
}

- (void)initRemoteGLView
{
    _remoteGLView = [[NTESGLView alloc] initWithFrame:_remoteView.bounds];
    [_remoteGLView setContentMode:UIViewContentModeScaleAspectFit];
    [_remoteGLView setBackgroundColor:[UIColor clearColor]];
    _remoteGLView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.remoteView addSubview:_remoteGLView];
}

#pragma mark - Call Life
- (void)startByCaller
{
    [self startInterface];
}

- (void)startByCallee
{
    if(self.immediate)
    {
        [self onCalling];
    }
//       [[YXManager sharedInstance] response:YES];
    else
        [self waitToCallInterface];
}

- (void)onCalling
{
    [self videoCallingInterface];
    
    if([GPUImageManager sharedInstance].dressupIndex >= 0)
    {
        [self sendDressUPNotification];
    }
}

- (void)waitForConnectiong
{
    [self connectingInterface];
}

- (void)freeMemory
{
    [self stopCountTimer];
    [self stopNetStatusTimer];
    if(self.waveView)
        [self.waveView stopAnimation];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBroadcastAnimation) object:nil];
    [self cleanBlurTimer];
    
    if(needTransform)
    {
        GPUImageView *imgView = [GPUImageManager sharedInstance].localPreviewView;
        imgView.transform = CGAffineTransformScale(imgView.transform, -1.0, 1.0);
    }
    
    [self uploadLikeTimes];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismiss
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:NO];
    if(_isCircleAnimation)
    {
        CGRect rect = CGRectMake((kMainScreenWidth-120)/2.0, kMainScreenHeight/2.0-100, 120, 120);
        UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:rect];
        
        CGPoint finalPoint = CGPointMake((kMainScreenWidth-120)/2.0+60 - 0, kMainScreenHeight/2.0-100+60 - CGRectGetMaxY(CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)));
        CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
        UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, -radius, -radius)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = maskFinalBP.CGPath; //将它的 path 指定为最终的 path 来避免在动画完成后会回弹
        self.view.layer.mask = maskLayer;
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.fromValue = (__bridge id)(maskFinalBP.CGPath);
        maskLayerAnimation.toValue = (__bridge id)((maskStartBP.CGPath));
        maskLayerAnimation.duration = 1;
        maskLayerAnimation.autoreverses = NO;

        [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
        
        WeakSelf(self)
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            if(weakself)
            {
                float width = 100 * kScale;
                float height = 140*kScale;
                GPUImageView *tmpImgView = [[GPUImageManager sharedInstance] localPreviewView];
                tmpImgView.frame = CGRectMake(0, 0, width-3, height-3);
                if(isGoRootVC)
                {
                    [[GPUImageManager sharedInstance] clearImg];
                    [DLAPPDELEGATE showRootviewController];
                }
                else
                    [weakself.navigationController popViewControllerAnimated:NO];
            }
        });
    }
    else
    {
        [[GPUImageManager sharedInstance] clearImg];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.type = kCATransitionPush;
        transition.subtype  = kCATransitionFromBottom;
        //    transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - Interface
//正在发起中界面
- (void)startInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.localBGView.hidden = YES;
    self.hungUpBtn.hidden   = YES;
    self.reportBtn.hidden   = YES;
    self.cancelConnectBtn.hidden = NO;
    self.bottomView.hidden = YES;
    [self.headView needToShowTipLab:YES andShowContent:@"正在等待对方接通视频..."];
}

//选择是否接听界面
- (void)waitToCallInterface{
    self.refuseBtn.exclusiveTouch = YES;
    self.acceptBtn.exclusiveTouch = YES;
    self.acceptBtn.hidden = NO;
    self.refuseBtn.hidden   = NO;
    self.localBGView.hidden = YES;
    self.hungUpBtn.hidden   = YES;
    self.reportBtn.hidden   = YES;
    self.cancelConnectBtn.hidden = YES;
    self.bottomView.hidden = YES;
    [self.headView needToShowTipLab:YES andShowContent:@"邀请你进行视频聊天..."];
}

//连接对方界面
- (void)connectingInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.reportBtn.hidden   = YES;
    self.localBGView.hidden = YES;
    self.bottomView.hidden = YES;
    self.cancelConnectBtn.hidden = YES;
    [self.headView needToShowTipLab:YES andShowContent:@"正在连接对方...请稍后..."];
}

//接听中界面(视频)
- (void)videoCallingInterface{
    needTransform = [GPUImageManager sharedInstance].isFront;
    if(needTransform)
    {
        GPUImageView *imgView = [GPUImageManager sharedInstance].localPreviewView;
        imgView.transform = CGAffineTransformScale(imgView.transform, -1.0, 1.0);
    }
    
    self.cameraType = needTransform?NIMNetCallCameraFront:NIMNetCallCameraBack;
    
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.reportBtn.hidden   = NO;
    self.bottomView.hidden = NO;
    self.localBGView.hidden = NO;
    self.cancelConnectBtn.hidden = YES;
    [self.headView needToShowTipLab:NO andShowContent:@""];
    
    self.swipeGestureView.hidden = NO;
    self.blurView.hidden = NO;
    
    [self startBroadcastAnimation];
    
    [[DDSystemInfoManager sharedInstance] startBroadcastTimer];
    
    if(![[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        [self initCountTimer];
    
    [self showTip];
    self.waveView.hidden = NO;
}

- (void)showTip
{
    //首次渐变Tip
    if([[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Gradient])
    {
        [self initGradientTipView];
    }
    
    if([[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Report] && self.tipControl.hidden)
    {
        [self initReportTipView];
    }
    
    if([[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Blur] && self.tipControl.hidden)
    {
        [self initBlurTipView];
    }
    
    if([[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Switch] && self.tipControl.hidden)
    {
        [self initSwitchTipView];
    }
    
//    NSString *key = @"gradientTip";
//    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:key];
//    key = @"firstBlurTip";
//    times = [[NSUserDefaults standardUserDefaults] integerForKey:key];
//    //首次模糊Tip
//    if(times < 4 && self.tipControl.hidden)
//    {
//        [self initBlurTipView];
//    }
//    
////    key = [NSString stringWithFormat:@"firstVideoChat_%@",[UserInfoData shareUserInfoData].strUserId];
//    key = @"firstVideoChat";
//    times = [[NSUserDefaults standardUserDefaults] integerForKey:key];
//    //换人Tip
//    if(times < 4 && self.tipControl.hidden)
//    {
//        [self initSwitchTipView];
//    }
    
//    key = [NSString stringWithFormat:@"firstLikeTip_%@",[UserInfoData shareUserInfoData].strUserId];
//    //Like Tip
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:key])
//    {
//        if(self.tipControl.hidden)
//        {
//            [self initLikeTipView];
//        }
//        else
//            [self performSelector:@selector(initLikeTipView) withObject:nil afterDelay:15];
//    }
//    
//    key = [NSString stringWithFormat:@"firstGiftTip_%@",[UserInfoData shareUserInfoData].strUserId];
//    //礼物 Tip
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:key])
//    {
//        if(self.tipControl.hidden)
//        {
//            animationType = AnimationTypeLike;
//            [self initGiftTipView];
//        }
//        else
//            [self performSelector:@selector(initGiftTipView) withObject:nil afterDelay:20];
//    }
}

- (void)initGradientTipView
{
    [self.tipControl removeSubviews];

    self.tipControl.hidden = NO;
    
    animationType = AnimationTypeGradient;
    
    [[DDSystemInfoManager sharedInstance] setShowTipValue:YES key:Tip4Gradient];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"gradientTip")];
    [img sizeToFit];
    img.center = self.tipControl.center;
    
    [self.tipControl addSubview:img];
    img.alpha = 0;
    WeakSelf(self)
    
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         img.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              img.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [img removeFromSuperview];
                                              if(weakself.tipControl)
                                                  [weakself initReportTipView];
                                          }];
                     }
     ];
}

- (void)initReportTipView
{
    [self.tipControl removeSubviews];

    self.tipControl.hidden = NO;
    
    animationType = AnimationTypeReport;
    
    [[DDSystemInfoManager sharedInstance] setShowTipValue:YES key:Tip4Report];
    
    UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"reportTip")];
    [img sizeToFit];
    [img setY:self.reportBtn.bottom+5];
    [img setRight:self.reportBtn.centerX];
    
    [self.tipControl addSubview:img];
    img.alpha = 0;
    WeakSelf(self)
    
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         img.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              img.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [img removeFromSuperview];
                                              if(weakself.tipControl && [[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Blur])
                                                  [weakself initBlurTipView];
                                          }];
                     }
     ];
}

- (void)initBlurTipView
{
    [self.tipControl removeSubviews];

    self.tipControl.hidden = NO;
    
    animationType = AnimationTypeBlur;
    
    [[DDSystemInfoManager sharedInstance] setShowTipValue:YES key:Tip4Blur];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.localBGView.y, 0, self.localBGView.height)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *word = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.localBGView.height-70)/2.0, 155, 70)];
    word.image = IMG(@"blurWord");
    [bgView addSubview:word];
    
    UIImage *img = IMG(@"blurHand");
    UIImageView *blurTipBG = [[UIImageView alloc] initWithImage:img];
    blurTipBG.frame = CGRectMake(word.right+10, 0, self.localBGView.width, self.localBGView.height);
    [bgView addSubview:blurTipBG];
    blurTipBG.contentMode = UIViewContentModeScaleAspectFit;
    [bgView setWidth:blurTipBG.right];
    [bgView setRight:self.localBGView.right];
    
    [self.tipControl addSubview:bgView];
    bgView.alpha = 0;
    
    WeakSelf(self)
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         bgView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              bgView.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [bgView removeFromSuperview];
                                              if(weakself.tipControl && [[DDSystemInfoManager sharedInstance] shouldShowTip:Tip4Switch])
                                                  [weakself initSwitchTipView];
                                          }];
                     }
     ];
}

- (void)initSwitchTipView
{
    [self.tipControl removeSubviews];

    self.tipControl.hidden = NO;
    
    animationType = AnimationTypeSwitch;
    
    [[DDSystemInfoManager sharedInstance] setShowTipValue:YES key:Tip4Switch];
    
    UIImageView *switchTipBG = [[UIImageView alloc] initWithImage:IMG(@"switchTip")];
    [switchTipBG sizeToFit];
    [switchTipBG setBottom:self.bottomView.y];
    [switchTipBG setRight:self.bottomView.countBtn.centerX];
    [self.tipControl addSubview:switchTipBG];
    switchTipBG.alpha = 0;
    WeakSelf(self)
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         switchTipBG.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              switchTipBG.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [switchTipBG removeFromSuperview];
                                              weakself.tipControl.hidden = YES;
                                          }];
                     }
     ];
}

- (void)initLikeTipView
{
    NSString *key = [NSString stringWithFormat:@"firstLikeTip_%@",[UserInfoData shareUserInfoData].strUserId];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.tipControl.hidden = NO;
    animationType = AnimationTypeLike;
    
    UIImageView *giftTipBG = [[UIImageView alloc] initWithImage:IMG(@"sendLikeTipBG")];
    giftTipBG.frame = CGRectMake(0, self.bottomView.y-53, 156, 53);
    [giftTipBG setCenterX:kMainScreenWidth/2-self.bottomView.countBtn.centerX+kMainScreenWidth/2];
    [self.tipControl addSubview:giftTipBG];
    giftTipBG.alpha = 0;
    
//    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 156, 40)];
//    [giftTipBG addSubview:lab];
//    lab.backgroundColor = [UIColor clearColor];
//    lab.text = @"连击喜欢可延长时间哦";
//    lab.textColor = kcolorWhite;
//    lab.font = kFont14;
//    lab.textAlignment = NSTextAlignmentCenter;
    
    WeakSelf(self)
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         giftTipBG.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              giftTipBG.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [weakself.tipControl removeSubviews];
                                              [weakself initGiftTipView];
                                          }];
                     }];

}

- (void)initGiftTipView
{
    if(animationType == AnimationTypeLike)
    {
        NSString *key = [NSString stringWithFormat:@"firstGiftTip_%@",[UserInfoData shareUserInfoData].strUserId];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        animationType = AnimationTypeGift;
        
        UIImageView *giftTipBG = [[UIImageView alloc] initWithImage:IMG(@"sendGiftTipBG")];
        giftTipBG.frame = CGRectMake((kMainScreenWidth-156)/2.0, self.bottomView.y-53, 156, 53);
        [self.tipControl addSubview:giftTipBG];
        giftTipBG.alpha = 0;
        
//        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 156, 40)];
//        [giftTipBG addSubview:lab];
//        lab.backgroundColor = [UIColor clearColor];
//        lab.text = @"送礼可延长更多时间哦";
//        lab.textColor = kcolorWhite;
//        lab.font = kFont14;
//        lab.textAlignment = NSTextAlignmentCenter;
        
        WeakSelf(self)
        [UIView animateWithDuration:1
                              delay:0.0
                            options:0
                         animations:^{
                             giftTipBG.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:1
                                                   delay:3
                                                 options:0
                                              animations:^{
                                                  giftTipBG.alpha = 0;
                                              }
                                              completion:^(BOOL finished) {
                                                  [weakself hideTip];
                                              }];
                         }];
    }
}

#pragma mark - Action
- (void)acceptToCall:(id)sender{
    BOOL accept = (sender == self.acceptBtn);
    //防止用户在点了接收后又点拒绝的情况
    [[YXManager sharedInstance] response:accept];
}

- (void)dressupBtnClick
{
    ToolsViewControl *toolsView = [[ToolsViewControl alloc] init];
    [toolsView show];
    WeakSelf(self)
    toolsView.selectValue = ^(NSInteger index){
        if(index == [GPUImageManager sharedInstance].dressupIndex)
            [GPUImageManager sharedInstance].dressupIndex = -1;
        else
            [GPUImageManager sharedInstance].dressupIndex = index;
        [weakself sendDressUPNotification];
    };
}

- (void)switchCamera
{
    if(isSwitchCamera)
        return;
    isSwitchCamera = YES;
    
    if (self.cameraType == NIMNetCallCameraFront)
    {
        self.cameraType = NIMNetCallCameraBack;
    }
    else
    {
        self.cameraType = NIMNetCallCameraFront;
    }
    [[NIMSDK sharedSDK].netCallManager switchCamera:self.cameraType];
    
    needTransform = !needTransform;
    [[GPUImageManager sharedInstance] switchCamera];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GPUImageView *imgView = [GPUImageManager sharedInstance].localPreviewView;
        imgView.transform = CGAffineTransformScale(imgView.transform, -1.0, 1.0);
        isSwitchCamera = NO;
    });
}


- (void)giftBtnClick
{
    WeakSelf(self)
    GiftControl *giftsView = [[GiftControl alloc] init];
    [giftsView initGiftssView:[DDSystemInfoManager sharedInstance].giftsArr];
    self.giftsView = giftsView;
    [giftsView show];
    
    giftsView.presentGiftBlock = ^(GiftModel *gift){
        [weakself presentGift:gift];
        [MobClick event:MsgSendPresent];
    };
    
    giftsView.gotoVCBlock = ^(){
        [MobClick event:MsgEnterRechargeFP];
        [[YXManager sharedInstance] disableCammera:YES];
        weakself.isGotoRechargeVC = YES;
        DongBiViewController *vc = [[DongBiViewController alloc] init];
        [weakself.navigationController pushViewController:vc animated:YES];
    };
}

- (void)likeBtnClick
{
    [self praiseAnimation:YES];
    
//    if(![[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
//    {
        likeTimes++;
        if(likeTimes < 31)
        {
            _totalTime += 2;
            [self startAntiClockwiseAnimation];
        }
    
    NSDictionary *dic = @{NTESNotifyID : @(NTESSendLike),
                          NTESCustomData:@(2)};
    [[YXManager sharedInstance] sendCustomSystemNotification:dic toSessionID:self.userInfo.strUserId sendToOnlineUsersOnly:YES];
//    }
}

- (void)switchPerson
{
    if(self.immediate)
    {
        discType = 2;
        [self stopCountTimer];
        [YXManager sharedInstance].isUserHangup = YES;
        [[YXManager sharedInstance] hangup];
    }
}

- (void)clickAttentionBtn
{
    WeakSelf(self)
    if([[DDFriendsInfoManager sharedInstance] isAttentioned:self.userInfo.strUserId])
    {
        [[DDFriendsInfoManager sharedInstance] requestRemoveAttentionID:self.userInfo.strUserId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself.headView.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
            [weakself.view makeToast:@"已取消关注" duration:1 position:CSToastPositionCenter];
        }];
    }
    else
    {
        [[DDFriendsInfoManager sharedInstance] requestAddAttentionID:self.userInfo.strUserId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself.headView.attentionBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [weakself.view makeToast:@"已关注" duration:1 position:CSToastPositionCenter];
        }];
    }
}

- (void)goRootVC
{
    isGoRootVC = YES;
    [[YXManager sharedInstance] hangup];

    if(_immediate)
    {
        [YXManager sharedInstance].isUserHangup = YES;
        [[GPUImageManager sharedInstance] clearImg];
    }
}

- (void)hangup
{
    [[YXManager sharedInstance] hangup];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        startLocation = [sender locationInView:sender.view];
    }
    
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint stopLocation = [sender locationInView:sender.view];
        CGFloat dy = stopLocation.y - startLocation.y;
        CGFloat distance = fabs(dy);
        
        if (distance > 250)
        {
            [YXManager sharedInstance].isUserHangup = YES;
            [[YXManager sharedInstance] hangup];
        }
    }
}

- (void)showAndhideBlurView
{
    [self.blurView showAndHideSlider];
    //    self.blurView.center = CGPointMake(self.localBGView.x, self.localBGView.centerY);
}

- (void)showDetail
{
    if(!self.userInfo)
    {
        return;
    }
    
    WeakSelf(self)
    [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:self.userInfo.strUserId completeBlock:^(NSDictionary *dataDic) {
        if(dataDic)
        {
            PersonDetailModel *user = [[PersonDetailModel alloc] init];
            [user unPackeDict:dataDic];
            PersonDetailView *view = [[PersonDetailView alloc] initWithDetailModel:user];
            [view.leftBtn addTarget:weakself action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            weakself.detailView = view;
            [weakself refreshDetailView];
            [view show];
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

- (void)hideTip
{
    [self.tipControl removeSubviews];
    self.tipControl.hidden = YES;
    
    switch (animationType) {
        case AnimationTypeGradient:
            [self initBlurTipView];
            break;
        case AnimationTypeBlur:
            [self initSwitchTipView];
            break;
        default:
            break;
    }
    
//    if(animationType == AnimationTypeBlur)
//    {
//        [self initSwitchTipView];
//        return;
//    }
//    else if(animationType == AnimationTypeLike)
//    {
//        [self initGiftTipView];
//        return;
//    }
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
        [dict setObject:self.userInfo.strUserId forKey:@"targetId"];
        [dict setObject:title forKey:@"type"];
        
        [NetManager requestWith:dict apiName:kTipoffAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [DLAPPDELEGATE showToastView:@"举报成功" duration:1 position:CSToastPositionCenter];
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if([keyPath isEqualToString:@"frame"])
//    {
//        self.blurView.center = CGPointMake(self.localBGView.x, self.localBGView.centerY);
//    }
//}

- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    NSData *data = [[notification content] dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([[dict objectForKey:NTESNotifyID] intValue] == NTESPresentGift && [notification.sender isEqualToString:self.userInfo.strUserId])
        {
            _totalTime += [[[dict objectForKey:@"data"] objectForKey:@"seconds"] intValue];
            
            GiftModel *model = [[GiftModel alloc] init];
            [model unPakceGiftInfoDict:[dict objectForKey:@"data"]];
            [self configMainImageView:model];
            [self startAntiClockwiseAnimation];
            
            PersonInfoManager *manager = [[PersonInfoManager alloc] init];
            [manager requestMyWallet:^(MyWalletData *data) {
                
            }];
        }
        else if ([[dict objectForKey:NTESNotifyID] intValue] == NTESPresentDressup && [notification.sender isEqualToString:self.userInfo.strUserId])
        {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@_dressup%ld",self.userInfo.sexType == 0?@"man":@"female",[[dict objectForKey:@"data"] integerValue]]];
            self.dressupImgView.image = img;
            [self.dressupImgView sizeToFit];
            if(self.userInfo.sexType == 0)
                [self.dressupImgView setX:10];
            else
                [self.dressupImgView setRight:kMainScreenWidth-10];
            [self.dressupImgView setY:self.headView.bottom+10];
        }
        else if ([[dict objectForKey:NTESNotifyID] intValue] == NTESSendLike && [notification.sender isEqualToString:self.userInfo.strUserId])
        {
            byLikeTimes++;
            if(byLikeTimes < 31)
            {
                _totalTime += 2;
                [self startAntiClockwiseAnimation];
            }
            
            [self praiseAnimation:NO];
            
        }
        else if ([[dict objectForKey:NTESNotifyID] intValue] == NTESRoserChange && [notification.sender isEqualToString:self.userInfo.strUserId])
        {
            if([[dict objectForKey:@"data"] isEqualToString:CONCERN_MSG_ADD])
            {
                [self.view makeToast:@"对方已关注你" duration:1.5 position:CSToastPositionCenter];
            }
        }
    }
}

- (void)onLocalPreviewReady
{
    _callInfo = [[NetCallChatInfo alloc] init];
    _callInfo.callee = [YXManager sharedInstance].callInfo.callee;
    _callInfo.caller = [YXManager sharedInstance].callInfo.caller;
    _callInfo.startTime = [YXManager sharedInstance].callInfo.startTime;

    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        currenBlurValue = 0;
    else
        currenBlurValue = 1;
    self.blurView.blurSliderView.hidden = YES;
    [self.blurView setProcessValue:currenBlurValue];
    [self startBlurTimer];
        
    [preView insertSubview:[GPUImageManager sharedInstance].localPreviewView atIndex:0];
    [[GPUImageManager sharedInstance] adjustBounds];
    
    UIImageView *maskImg = [[UIImageView alloc] initWithFrame:[GPUImageManager sharedInstance].localPreviewView.bounds];
    maskImg.image = DEFAULTCALLBG;
    maskImg.contentMode = UIViewContentModeScaleAspectFill;
    [[GPUImageManager sharedInstance].localPreviewView addSubview:maskImg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [maskImg removeFromSuperview];
    });
}

- (void)startBlurTimer
{
//    if (!timer4Blur)
//    {
//        timer4Blur = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(blurTimerFired:) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:timer4Blur forMode:NSDefaultRunLoopMode];
//    }
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    timer4Blur = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(0.5 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer4Blur, start, interval, 0);
    WeakSelf(self)
    // 设置回调
    dispatch_source_set_event_handler(timer4Blur, ^{
        [weakself blurTimerFired];
    });
    // 启动定时器
    dispatch_resume(timer4Blur);
}

- (void)blurTimerFired
{
    NSLog(@"currenBlurValue = %f",currenBlurValue);
    currenBlurValue -= 0.01;
    
    if(currenBlurValue <= 0)
    {
        [self cleanBlurTimer];
    }
    
    [self.blurView setProcessValue:currenBlurValue];
}

- (void)cleanBlurTimer
{
//    if (timer4Blur)
//    {
//        [timer4Blur invalidate];
//        timer4Blur = nil;
//    }
    if(timer4Blur)
    {
        dispatch_cancel(timer4Blur);
        timer4Blur = nil;
    }
}

- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
{
    if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive))
    {
        if (!_remoteGLView)
        {
            [self initRemoteGLView];
            [self.view addGestureRecognizer:self.tap];
            
            UIImageView *maskImg = [[UIImageView alloc] initWithFrame:_remoteView.bounds];
            maskImg.image = DEFAULTCALLBG;
            maskImg.contentMode = UIViewContentModeScaleAspectFill;
            [_remoteView addSubview:maskImg];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [maskImg removeFromSuperview];
            });
        }
        [_remoteGLView render:yuvData width:width height:height];
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hangup) object:nil];
//        [self performSelector:@selector(hangup) withObject:nil afterDelay:5];
    }
}

- (void)onCall:(UInt64)callID netStatus:(NIMNetCallNetStatus)status
{
    if(status == NIMNetCallNetStatusVeryBad || status == NIMNetCallNetStatusBad)
    {
        self.waveView.hidden = NO;
        [self.waveView startAnimation];
    }
    else
    {
        self.waveView.hidden = YES;
        [self.waveView stopAnimation];
    }
    
//    NSLog(@"status ========= %d",status);
//    
//    if(status == NIMNetCallNetStatusVeryBad && !netStatusTimer && (videoQuality != NIMNetCallVideoQualityLow) && !_isSwithVideoQuality)
//    {
//        [self initNetStatusTimer];
//    }
//    
//    if(status < NIMNetCallNetStatusBad)
//    {
//        [self stopNetStatusTimer];
//    }
}

- (void)initCountTimer
{
//    if (!countTimer)
//    {
//        countTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(conutTime) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:countTimer forMode:NSDefaultRunLoopMode];
        // 获得队列
        dispatch_queue_t queue = dispatch_get_main_queue();
        countTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        uint64_t interval = (uint64_t)(1 * NSEC_PER_SEC);
        dispatch_source_set_timer(countTimer, start, interval, 0);
        WeakSelf(self)
        // 设置回调
        dispatch_source_set_event_handler(countTimer, ^{
            [weakself conutTime];
        });
        
        // 启动定时器
        dispatch_resume(countTimer);
//    }
}

- (void)stopCountTimer
{
//    if (countTimer)
//    {
//        [countTimer invalidate];
//        countTimer = nil;
//    }
    
    if(countTimer)
    {
        dispatch_cancel(countTimer);
        countTimer = nil;
    }
    
    [self.bottomView.countImg setImage:[UIImage imageNamed:@"clockwise"]];
    [self.bottomView.countBtn setBackgroundImage:[UIImage imageNamed:@"countBtn"] forState:UIControlStateNormal];
    self.bottomView.durationLabel.hidden = YES;
    [self.bottomView.countImg.layer removeAllAnimations];
}

- (void)conutTime
{
    self.bottomView.durationLabel.text = [NSString stringWithFormat:@"%d", _totalTime];
    self.bottomView.durationLabel.hidden = _totalTime > 999;
    NSLog(@"_totalTime= %d",_totalTime);

    _totalTime--;
    
    if(_totalTime <= 0)
    {
        [self stopCountTimer];
        [[YXManager sharedInstance] hangup];
    }
    
    if(_totalTime == 15 || _totalTime == 30)
    {
        [self showLikeTip:_totalTime == 15];
    }
    
    if(_likeTimeTipLab)
    {
        _likeTimeTipLab.text = [NSString stringWithFormat:@"%ds", _totalTime];
    }
    
    [self startClockwiseAnimation];
}

- (void)initNetStatusTimer
{
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    netStatusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(10 * NSEC_PER_SEC);
    dispatch_source_set_timer(netStatusTimer, start, interval, 0);
    WeakSelf(self)
    // 设置回调
    dispatch_source_set_event_handler(netStatusTimer, ^{
        [weakself monitorNetStatue];
    });
    
    // 启动定时器
    dispatch_resume(netStatusTimer);
}

- (void)stopNetStatusTimer
{
    if(netStatusTimer)
    {
        dispatch_cancel(netStatusTimer);
        netStatusTimer = nil;
    }
}

- (void)monitorNetStatue
{
    if(videoQuality == NIMNetCallVideoQualityHigh)
    {
        videoQuality = NIMNetCallVideoQualityMedium;
    }
    else if (videoQuality == NIMNetCallVideoQualityMedium)
    {
        videoQuality = NIMNetCallVideoQualityLow;
    }
    [[YXManager sharedInstance] switchVideoQuality:videoQuality];
    [self stopNetStatusTimer];
    
    WeakSelf(self);
    
    _isSwithVideoQuality = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakself)
            weakself.isSwithVideoQuality = NO;
    });
}


- (void)showLikeTip:(BOOL)isRed
{
    UIImageView *tipBG = [[UIImageView alloc] initWithImage:IMG(@"likeTipBG")];
    tipBG.center = self.view.center;
    
    _likeTimeTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, tipBG.width, 60)];
    [tipBG addSubview:_likeTimeTipLab];
    _likeTimeTipLab.backgroundColor = [UIColor clearColor];
    _likeTimeTipLab.text = [NSString stringWithFormat:@"%ds", _totalTime];
    _likeTimeTipLab.textColor = isRed?[UIColor redColor]:RGBCOLOR(251, 237, 62);
    _likeTimeTipLab.font = [UIFont boldSystemFontOfSize:24];
    _likeTimeTipLab.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:tipBG];
    WeakSelf(self)
    tipBG.alpha = 0;
    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         tipBG.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:3
                                             options:0
                                          animations:^{
                                              tipBG.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [weakself.likeTimeTipLab removeFromSuperview];
                                              weakself.likeTimeTipLab = nil;
                                              [tipBG removeFromSuperview];
                                          }];
                     }
     ];
}

- (void)startClockwiseAnimation
{
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        return;
    
    if([self.bottomView.countImg.layer animationForKey:@"Anticlockwise"])
    {
        return;
    }
    
    [self.bottomView.countBtn setBackgroundImage:_totalTime>=999?[UIImage imageNamed:@"countBtn"]:[UIImage imageNamed:@"countBtnBG"] forState:UIControlStateNormal];
    self.bottomView.durationLabel.hidden = _totalTime>=999;
    self.bottomView.countImg.hidden = NO;
    [self.bottomView.countImg setImage:[UIImage imageNamed:@"clockwise"]];
    if(![self.bottomView.countImg.layer animationForKey:@"Clockwise"])
    {
        [self.bottomView.countImg.layer addAnimation:[self rotate360DegreeAnimation:2 isClockwise:YES] forKey:@"Clockwise"];
    }
}

- (void)startAntiClockwiseAnimation
{
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        return;
    
    if(![self.bottomView.countImg.layer animationForKey:@"Anticlockwise"])
    {
        self.bottomView.countImg.hidden = NO;
        [self.bottomView.countBtn setBackgroundImage:_totalTime>=999?[UIImage imageNamed:@"countBtn"]:[UIImage imageNamed:@"countBtnBG"] forState:UIControlStateNormal];
        self.bottomView.durationLabel.hidden = _totalTime>=999;
        CABasicAnimation *animation = [self rotate360DegreeAnimation:0.5 isClockwise:NO];
        animation.delegate = self;
        [self.bottomView.countImg setImage:[UIImage imageNamed:@"anticlockwise"]];
        [self.bottomView.countImg.layer removeAllAnimations];
        [self.bottomView.countImg.layer addAnimation:animation forKey:@"Anticlockwise"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId])
        {
            self.bottomView.durationLabel.hidden = YES;
            [self.bottomView.countImg setImage:[UIImage imageNamed:@"clockwise"]];
            [self.bottomView.countBtn setBackgroundImage:[UIImage imageNamed:@"countBtn"] forState:UIControlStateNormal];
        }
        else
        {
            [self startClockwiseAnimation];
        }
    }
}

- (void)setAlphaLight:(CALayer *)layer isOn:(BOOL)isOn
{
    if(isOn)
    {
        if(![layer animationForKey:@"aAlpha"])
            [layer addAnimation:[self alphaLightAnimation:0.58] forKey:@"aAlpha"];
    }
    else
    {
        [layer removeAllAnimations];
    }
}

- (NSString*)durationDesc
{
    if (!self.callInfo) {
        return @"-1";
    }

    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    return [NSString stringWithFormat:@"%02ds",(int)duration];
}


- (void)resetRemoteImage{
#if defined (NTESUseGLView)
    [self.remoteGLView render:nil width:0 height:0];
#endif

    self.remoteView.image = DEFAULTCALLBG;
}

#pragma mark Animation
- (CABasicAnimation *)rotate360DegreeAnimation:(float)time isClockwise:(BOOL)isClockwise
{
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = isClockwise?[NSNumber numberWithFloat:0.f]:[NSNumber numberWithFloat: M_PI *2];
    animation.toValue =  isClockwise?[NSNumber numberWithFloat: M_PI *2]:[NSNumber numberWithFloat:0.f];
    animation.duration  = time;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = isClockwise?MAXFLOAT:1;
    return animation;
}

- (CABasicAnimation *)alphaLightAnimation:(float)time
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

- (CAAnimationGroup *)strongAlphaLightAnimation:(float)time toValue:(float)toValue
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(1);
    animation.toValue = @(0);
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *transformAnima = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnima.fromValue = @(1);
    transformAnima.toValue = @(toValue);
    transformAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animaGroup = [CAAnimationGroup animation];
    animaGroup.duration = time;
    animaGroup.autoreverses = YES;
    animaGroup.repeatCount = MAXFLOAT;
    animaGroup.fillMode = kCAFillModeForwards;
    animaGroup.removedOnCompletion = NO;
    animaGroup.animations = @[animation,transformAnima];
    
    return animaGroup;
}

- (void)startBroadcastAnimation
{
    if([DDSystemInfoManager sharedInstance].broadcastArr.count == 0)
        return;
    
    [self.broadcastView initViewWithBroadcast:[DDSystemInfoManager sharedInstance].broadcastArr.firstObject];
    WeakSelf(self)
    [UIView animateWithDuration:5
                          delay:0
                        options:0
                     animations:^{
                         [weakself.broadcastView setX:10];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:5
                                               delay:3
                                             options:0
                                          animations:^{
                                              [weakself.broadcastView setX:-weakself.broadcastView.width-10];
                                          }
                                          completion:^(BOOL finished) {
                                              if([DDSystemInfoManager sharedInstance].broadcastArr.count)
                                                  [[DDSystemInfoManager sharedInstance].broadcastArr removeObjectAtIndex:0];
                                              [weakself.broadcastView setX:kMainScreenWidth];
                                              [weakself performSelector:@selector(startBroadcastAnimation) withObject:nil afterDelay:120];
                                          }
                          
                          ];
                     }
     ];
}

- (void)presentGift:(GiftModel *)gift
{
    WeakSelf(self)
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:self.userInfo.strUserId forKey:@"targetId"];
    [dict setObject:gift.strID forKey:@"itemId"];
    
    [NetManager requestWith:dict apiName:kGiveGiftAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if([[successDict objectForKey:@"state"] intValue] != 200)
        {
            SPAlertView *alert = [[SPAlertView alloc] initWithTitle:nil message:@"余额不足，是否充值?" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"支付"];
            self.alert = alert;
            [alert show];
            return;
        }
        weakself.totalTime += [gift.seconds intValue];
        NSDictionary *dic = @{NTESNotifyID : @(NTESPresentGift),
                               NTESCustomData:[gift pakceGiftInfoDict]};
        [[YXManager sharedInstance] sendCustomSystemNotification:dic toSessionID:weakself.userInfo.strUserId sendToOnlineUsersOnly:YES];
        [weakself configMainImageView:gift];
        
        PersonInfoManager *manager = [[PersonInfoManager alloc] init];
        [manager requestMyWallet:^(MyWalletData *data) {
            
        }];
        
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)sendDressUPNotification
{
    NSDictionary *dict = @{NTESNotifyID : @(NTESPresentDressup),
                           NTESCustomData:@([GPUImageManager sharedInstance].dressupIndex)};
    [[YXManager sharedInstance] sendCustomSystemNotification:dict toSessionID:self.userInfo.strUserId sendToOnlineUsersOnly:YES];
}

#pragma mark - 点赞动画
- (void)praiseAnimation:(BOOL)isSelf
{
    float fx = (kMainScreenWidth-40-40*5)/4.0;
    float x = 20+fx+40+10;
    
    LikeImageView *imageView = [[LikeImageView alloc] init];
    imageView.showTime = isSelf?likeTimes<31:byLikeTimes<31;
    CGRect frame = self.view.frame;
    //  初始frame，即设置了动画的起点
    imageView.frame = CGRectMake(x, frame.size.height - 70, 30, 28);
    //  初始化imageView透明度为0
    imageView.alpha = 0;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    //  用0.2秒的时间将imageView的透明度变成1.0，同时将其放大1.3倍，再缩放至1.1倍，这里参数根据需求设置
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 1.0;
        imageView.frame = CGRectMake(x, frame.size.height - 90, 30, 30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.2, 1.2);
        imageView.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    [self.view addSubview:imageView];
    //  随机产生一个动画结束点的X值
    CGFloat finishX = x + 50 - round(random() % 100);
    //  动画结束点的Y值
    CGFloat finishY = self.localBGView.y + round(random() % 50);
    //  imageView在运动过程中的缩放比例
    CGFloat scale = round(random() % 40)/100.0 + 0.7;
    // 生成一个作为速度参数的随机数
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    //  动画执行时间
    NSTimeInterval duration = speed;
    //  如果得到的时间是无穷大，就重新附一个值（这里要特别注意，请看下面的特别提醒）
    if (duration == INFINITY) duration = 1.412346;
    // 随机生成一个0~7的数，以便下面拼接图片名
    int imageName = round(random() % 9);
    
    //  开始动画
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    //  设置动画时间
    [UIView setAnimationDuration:duration];
    
    //  拼接图片名字
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"heart%d",imageName]];
    
    //  设置imageView的结束frame
    imageView.frame = CGRectMake( finishX, finishY, 30 * scale, 30 * scale);
    
    //  设置渐渐消失的效果，这里的时间最好和动画时间一致
    [UIView animateWithDuration:duration animations:^{
        imageView.alpha = 0.2;
    }];
    
    //  结束动画，调用onAnimationComplete:finished:context:函数
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    //  设置动画代理
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

/// 动画完后销毁iamgeView
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    LikeImageView *imageView = (__bridge LikeImageView *)(context);
    UIImageView *timeImg = [[UIImageView alloc] initWithImage:IMG(@"+2s")];
    if(![[DDFriendsInfoManager sharedInstance] isMyFriend:self.userInfo.strUserId] && imageView.showTime)
    {
        timeImg.frame = imageView.frame;
        [timeImg setWidth:imageView.width*0.8];
        [timeImg setHeight:imageView.height*0.8];
        
        timeImg.center = imageView.center;
        timeImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:timeImg];
    }

    [UIView animateWithDuration:1
                          delay:0.0
                        options:0
                     animations:^{
                         imageView.alpha = 0;
                         timeImg.alpha = 0.2;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
                         [timeImg removeFromSuperview];
//                         imageView = nil;
                     }];
}

- (void)uploadLikeTimes
{
    int callTime = [self.durationDesc intValue];
    if(likeTimes > 0 && callTime > 0)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
        [dict setObject:self.userInfo.strUserId forKey:@"targetId"];
        [dict setObject:@"vedio" forKey:@"act"];
        [dict setObject:@(callTime) forKey:@"len"];
        [dict setObject:@(likeTimes) forKey:@"likes"];
        if(self.immediate)
            [dict setObject:@(discType) forKey:@"discType"];
        
        [NetManager requestWith:dict apiName:kRepertAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

#pragma mark 礼物
- (NSArray *)initialImageArray:(GiftModel *)model
{
    NSArray *tmpArr = [model.effect componentsSeparatedByString:@"/"];
    if([[tmpArr lastObject] length] <= 0)
        return nil;
    
    NSString *docName = [[tmpArr lastObject] substringToIndex:[[tmpArr lastObject] length]-4];
    NSString *giftDocument = [[GiftDocumentPath stringByAppendingPathComponent:docName] stringByAppendingPathComponent:docName];
    NSString *giftZip = [GiftDocumentPath stringByAppendingPathComponent:[tmpArr lastObject]];
    
    if ([[DDSystemInfoManager sharedInstance] checkPath:giftZip isCreaet:NO])
    {
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:giftDocument];
        
        NSMutableArray *files = [NSMutableArray array];
        NSString *filename ;
        while (filename = [direnum nextObject]) {
            if ([[filename pathExtension] isEqualToString:@"png"]) {
                [files addObject:filename];
            }
        }
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for (int i = 1; i <= files.count; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"%04d.png", i];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", giftDocument, imageName];
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            
            [imageArray addObject:image];
        }
        
        return imageArray;
    }
    else
    {
        WeakSelf(self)
        [[DDSystemInfoManager sharedInstance] downloadGiftZip:model];
        [DDSystemInfoManager sharedInstance].downloadFinishBlock = ^(){
                [weakself configMainImageView:model];
        };
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [DDSystemInfoManager sharedInstance].downloadFinishBlock = nil;
        });

    }
    
    return nil;
}

// 配置imageview的序列帧动画属性
- (void)configMainImageView:(GiftModel *)model
{
    NSArray *imgArr = [self initialImageArray:model];
    if(imgArr.count <= 0)
        return;
    
    NSTimeInterval animationDuration = 0.1*imgArr.count;
    self.giftAnimationImgView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    self.giftAnimationImgView.hidden = NO;
    self.giftAnimationImgView.animationImages = imgArr;
    self.giftAnimationImgView.animationDuration = animationDuration;
    self.giftAnimationImgView.animationRepeatCount = 1;
    [self.giftAnimationImgView startAnimating];
    WeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself clearAinimationImageMemory];
    });
}

// 清除animationImages所占用内存
- (void)clearAinimationImageMemory
{
    if(self.giftAnimationImgView)
    {
        [self.giftAnimationImgView stopAnimating];
        self.giftAnimationImgView.animationImages = nil;
        self.giftAnimationImgView.hidden = YES;
    }
}

- (void)didSelectAlertButton:(NSString *)title
{
    if(![title isEqualToString:@"取消"])
    {
        _isGotoRechargeVC = YES;
        [MobClick event:MsgEnterRechargeFP];
        [[YXManager sharedInstance] disableCammera:YES];
        DongBiViewController *vc = [[DongBiViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
