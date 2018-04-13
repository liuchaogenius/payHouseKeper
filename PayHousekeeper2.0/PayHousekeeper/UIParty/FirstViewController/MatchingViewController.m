//
//  MatchingViewController.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MatchingViewController.h"
#import "NetManager.h"
#import "NoticsMoodsModel.h"
#import "AppDelegate.h"
#import "NTESVideoChatViewController.h"
#import "DDLoginManager.h"
#import "NewRootViewController.h"
#import "GoMatchVCTransition.h"
#import "LocationManager.h"
#import "OtherUserInfoData.h"
#import "VideoRobotViewController.h"
#import "FMDBManager.h"
#import "PersonDetailView.h"
#import "SPActionSheet.h"
//#import "GenderView.h"
#import "NTESTimerHolder.h"

@interface MatchingViewController ()<UINavigationControllerDelegate,CAAnimationDelegate,SPActionSheetDelegate,NTESTimerHolderDelegate>
{
//    NSTimer *_tipsTimer, *_infoTimer;
    NSArray *tipsArr;
    int     tipIndex, infoIndex;
    UIView  *preView;
    NSMutableArray *robotArr;
    UIButton *switchBtn;
    NSArray *_colors;
    
    SPActionSheet *actionsheet;
//    GenderView *genderView;
    UIImageView *videoImg;
    UIImageView *love;
    
    dispatch_source_t _tipsTimer;
    dispatch_source_t _infoTimer;
    
    NSInteger _count;
    BOOL b;
    /**
     *  定时器
     */
    NSTimer *timer;
}
@property(nonatomic, strong) NSMutableArray *moodsArr;
@property(nonatomic, strong) UIImageView    *sexImgView, *vipImgView, *bgImgView;
@property(nonatomic, strong) UILabel        *nameLab, *tipLab;

@property(nonatomic, strong) OtherUserInfoData   *calleeData;
@property(nonatomic, strong) PersonDetailView *detailView;
@property(assign) BOOL isMatching;
@property (nonatomic, strong) NTESTimerHolder *wait4CallTimer; 

@end

@implementation MatchingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.delegate = self;
    _localBGView.hidden = YES;
//    _tipLab.text = tipsArr[tipIndex%5];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.detailView)
        [self.detailView dismiss];
    
    [_wait4CallTimer stopTimer];
    
    [self cancelMatch];
    
    [self stopTimer];
    
    [self cancelPreviousPerformRequests];

    [self.navigationController setNavigationBarHidden:NO];
    

    //    self.navigationController.delegate = nil;
    _localBGView.hidden = YES;
    _bgImgView.backgroundColor = RGBCOLOR(37, 143, 127);
    //    [_bgImgView pauseLighting];
    [_bgImgView.layer removeAnimationForKey:@"aAlpha"];
//    [love.layer removeAnimationForKey:@"aScale"];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)cancelPreviousPerformRequests
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gotoVideoVC) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectTimeOut) object:nil];
}

- (void)dealloc
{
    self.navigationController.view.backgroundColor = kcolorWhite;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    _localBGView.hidden = NO;
    
    timer = [NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    [_bgImgView.layer addAnimation:[self AlphaLight:1.5] forKey:@"aAlpha"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshDetailView)
                                                 name:RosterInfoChangedNotification
                                               object:nil];
    
    WeakSelf(self)
    [YXManager sharedInstance].connectBlock = ^(ConnectState state){
        [weakself connectRes:state];
    };
    
    [YXManager sharedInstance].immediateBlock = ^(OtherUserInfoData *userInfo){
        [weakself gotoVideoChat:userInfo];
    };
    
    self.view.backgroundColor = [UIColor clearColor];
    tipsArr = @[@"正在匹配...",@"匹配成功可聊90秒，越聊越清晰",@"送礼可延长聊天时间",@"不喜欢可以滑动换人",@"开通VIP享有120秒特权",@"晚上9-11点最热闹，记得来哦"];
    
//    [self initCaptureSession];

    [self initView];
    [self startMatch];

    if(!_isOkTime)
    {
        robotArr = [NSMutableArray array];
        NSArray *nameArr = nil;
        if([UserInfoData shareUserInfoData].sexType == 0)
        {
            nameArr = @[@"豆小豆"];//,@"三月",@"欣儿",@"饭饭",@"Ria.Xue"];
        }
        else
        {
            nameArr = @[@"Vacant"];//@[@"帅帅",@"Vacant"];
        }
        for(int i = 0; i < nameArr.count; i++)
        {
            NSDictionary *dic = @{@"nickName":[nameArr objectAtIndex:i],
                                  @"avatar":[nameArr objectAtIndex:i],
                                  @"mood":@"每天晚上，我在咚咚等你哦",
                                  @"wealthLevel":@"1",
                                  @"charmLevel":@"1",
                                  };
            OtherUserInfoData *userInfo = [[OtherUserInfoData alloc] init];
            [userInfo unPakceUserInfoDict:dic];
            [robotArr addObject:userInfo];
        }
    }
//    else
//    {
        [NetManager shareInstance].changeStatusBlock = ^(BOOL isConnect){
//            if(weakself.isOkTime)
//            {
                if(isConnect)
                {
                    [weakself startMatch];
                }
                else
                    [weakself showNoNetView];
//            }
        };
//    }
}

- (void)initTimer
{
    //    if(![DDSystemInfoManager sharedInstance].isOn)
    //    {
    //        return;
    //    }
    
    if(!self)
        return;
    
    [self stopTimer];
    _vipImgView.hidden = YES;
    
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    _tipsTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(3 * NSEC_PER_SEC);
    dispatch_source_set_timer(_tipsTimer, start, interval, 0);
    WeakSelf(self)
    // 设置回调
    dispatch_source_set_event_handler(_tipsTimer, ^{
        [weakself changeTip];
    });
    // 启动定时器
    dispatch_resume(_tipsTimer);
    
    NSInteger count = 0;
    if([self.currentGender isEqualToString:@"A"])
    {
        count = [DDSystemInfoManager sharedInstance].allAvaterArr.count;
    }
    else if([self.currentGender isEqualToString:@"F"])
    {
        count = [DDSystemInfoManager sharedInstance].femalAvaterArr.count;
    }
    else if([self.currentGender isEqualToString:@"M"])
    {
        count = [DDSystemInfoManager sharedInstance].manAvaterArr.count;
    }

    if(count <= 0)
    {
        [[DDSystemInfoManager sharedInstance] getRandAvatarInfo];
    }
    
    // 获得队列
    dispatch_queue_t queue2 = dispatch_get_main_queue();
    _infoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue2);
    dispatch_time_t start2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    uint64_t interval2 = (uint64_t)(1.5 * NSEC_PER_SEC);
    dispatch_source_set_timer(_infoTimer, start2, interval2, 0);
    // 设置回调
    dispatch_source_set_event_handler(_infoTimer, ^{
        [weakself changeInfo];
    });
    // 启动定时器
    dispatch_resume(_infoTimer);
}

- (void)stopTimer
{
    if(_tipsTimer)
    {
        dispatch_cancel(_tipsTimer);
        _tipsTimer = nil;
    }
    if(_infoTimer)
    {
        dispatch_cancel(_infoTimer);
        _infoTimer = nil;
    }
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
}

- (void)changeTip
{
    tipIndex++;
    NSString *str = tipsArr[tipIndex%tipsArr.count];
    _tipLab.text = str;
}

- (void)changeInfo
{
    NSInteger count = 0;
    NSDictionary *dic = nil;
    if([self.currentGender isEqualToString:@"A"])
    {
        count = [DDSystemInfoManager sharedInstance].allAvaterArr.count;
        dic = [DDSystemInfoManager sharedInstance].allAvaterArr[infoIndex];
    }
    else if([self.currentGender isEqualToString:@"F"])
    {
        count = [DDSystemInfoManager sharedInstance].femalAvaterArr.count;
        dic = [DDSystemInfoManager sharedInstance].femalAvaterArr[infoIndex];
    }
    else if([self.currentGender isEqualToString:@"M"])
    {
        count = [DDSystemInfoManager sharedInstance].manAvaterArr.count;
        dic = [DDSystemInfoManager sharedInstance].manAvaterArr[infoIndex];
    }
    if(count <= 0)
        return;
    
    infoIndex++;
    if(infoIndex == count)
        infoIndex = 0;
    
    NSString *str = [dic objectForKey:@"avatar"];
    UIImage *image = [[DDSystemInfoManager sharedInstance].picUrlDic objectForKey:str];
    if(image)
    {
        _avatarImgView.image = image;
        _nameLab.text = [dic objectForKey:@"nickName"];
        _vipImgView.hidden = ![[dic objectForKey:@"vip"] boolValue];
        [self updateNameLabFrame:NO];
    }
    
    
   
}

-(void)timerAction{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    anim.duration = 0.5;
    UIColor* fcolor;
    UIColor* tcolor;
    
    if (!b) {
        
        if (_count==_colors.count-2) {
            b=YES;
        }
        fcolor = _colors[_count];
        tcolor = _colors[_count+1];
        _count++;
        
    }else{
        
        if (_count == 1) {
            b=NO;
        }
        fcolor = _colors[_count];
        tcolor = _colors[_count-1];
        _count--;
    }
    
    anim.fromValue = (id)fcolor.CGColor;
    anim.toValue = (id)tcolor.CGColor;
    //填充效果：动画结束后，动画将保持最后的表现状态
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.beginTime = 0.0f;
    
//    [self.view.layer addAnimation:anim forKey:nil];
    [_bgImgView.layer addAnimation:anim forKey:nil];
}


- (CABasicAnimation *)AlphaLight:(float)time
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = infoIndex%2!=0?@(0.6):@(1);
    animation.toValue = infoIndex%2!=0?@(1):@(0.6);
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (CABasicAnimation *)scaleLight:(float)time
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(0.9);
    animation.toValue = @(1.1);
    animation.duration= time;
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount= FLT_MAX;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (void)updateNameLabFrame:(BOOL)isMatched
{
    isMatched = NO;
    [_nameLab sizeToFit];
    [_nameLab setHeight:MAX(_nameLab.height, 18)];
    if(_nameLab.width > _avatarImgView.width*1.8)
    {
        [_nameLab setWidth:_avatarImgView.width*1.8];
    }
    [_nameLab setY:_avatarImgView.bottom+32];
    [_nameLab setCenterX:isMatched?(kMainScreenWidth/2-18):(kMainScreenWidth/2)];
    [videoImg setX:_nameLab.right+10];
    [videoImg setCenterY:_nameLab.centerY];
    videoImg.hidden = !isMatched;
//    if(isMatched)
//    {
//        [love.layer addAnimation:[self scaleLight:1] forKey:@"aScale"];
//    }
//    else
//    {
//        [love.layer removeAnimationForKey:@"aScale"];
//    }
}

- (void)initView
{
    NSDictionary *dic = nil;
    if([self.currentGender isEqualToString:@"A"])
    {
        dic = [[DDSystemInfoManager sharedInstance].allAvaterArr firstObject];
    }
    else if([self.currentGender isEqualToString:@"F"])
    {
        dic = [[DDSystemInfoManager sharedInstance].femalAvaterArr firstObject];
    }
    else if([self.currentGender isEqualToString:@"M"])
    {
        dic = [[DDSystemInfoManager sharedInstance].manAvaterArr firstObject];
    }

    _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [self.view addSubview:_bgImgView];
    _colors = @[RGBCOLOR(88, 186, 151),RGBCOLOR(162, 215, 175),RGBCOLOR(80, 192, 110),RGBCOLOR(37, 143, 127),RGBCOLOR(19, 109, 108)];
    _bgImgView.backgroundColor = _colors[infoIndex%4];
    
    //    RCLightingLayer *lightingLayer = [[RCLightingLayer alloc] initWithColors:@[RGBCOLOR(88, 186, 151),
    //                                                                               RGBCOLOR(162, 215, 175),
    //                                                                               RGBCOLOR(80, 192, 110),
    //                                                                               RGBCOLOR(37, 143, 127),
    //                                                                               RGBCOLOR(19, 109, 108)]];
    //    lightingLayer.perLightingDuration = 1.5;
    //    lightingLayer.kBackgroundColorAlpha = 0.9f;
    //    [_bgImgView showWithLighting:lightingLayer];
    
//    WeakSelf(self)
//    genderView = [[GenderView alloc] initWithFrame:CGRectMake(12, 32, 37, 37)];
//    [self.view addSubview:genderView];
//    genderView.touchGenderBlock = ^(){
//        [weakself cancelMatch];
//        [weakself startMatch];
//    };
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(kMainScreenWidth-49, 32, 37, 37);
    [closeBtn setImage:IMG(@"closeMatch") forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(back)];
    [self.view addSubview:closeBtn];
    
    switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(kMainScreenWidth/2-77/2.0, 30, 77, 28);
    //    [switchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    //    [switchBtn setImage:IMG(@"switchPerson") forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchBtnClick)];
    [switchBtn setTitle:@"换一个" forState:UIControlStateNormal];
    [switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchBtn setTitleColor:RGBCOLOR(136, 136, 136) forState:UIControlStateHighlighted];
    switchBtn.backgroundColor = RGBACOLOR(255, 255, 255, 0.4);
    switchBtn.clipsToBounds = YES;
    switchBtn.layer.cornerRadius = 14;
    switchBtn.titleLabel.font = kFont17;
    [self.view addSubview:switchBtn];
    
    NSString *str = [dic objectForKey:@"avatar"];
    float width = 100 * kScale;
    _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kMainScreenWidth-width)/2.0, 191.5*kScale, width, width)];
    _avatarImgView.backgroundColor = [UIColor clearColor];
    _avatarImgView.clipsToBounds = YES;
    _avatarImgView.layer.cornerRadius = _avatarImgView.height/2;
    [_avatarImgView sd_setImageWithURL:URL(str) placeholderImage:DEFAULTAVATAR];
    [self.view addSubview:_avatarImgView];
    [_avatarImgView addTarget:self action:@selector(showDetailView)];
    
    _vipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_avatarImgView.right-22, _avatarImgView.bottom-24, 17, 17)];
    _vipImgView.image = IMG(@"crownVip");
    [self.view addSubview:_vipImgView];
    _vipImgView.hidden = ![[dic objectForKey:@"vip"] boolValue];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, _avatarImgView.bottom+32, kMainScreenWidth-40, 18)];
    _nameLab.font = kFontBold18;
    _nameLab.textColor = kcolorWhite;
    _nameLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nameLab];
    _nameLab.text = [dic objectForKey:@"nickName"];
    
    videoImg = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.right+10, _nameLab.y-1, 26, 16)];
    videoImg.image = IMG(@"match_video");
    [self.view addSubview:videoImg];
    love = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 8, 8)];
    love.image = IMG(@"match_video_love");
    [videoImg addSubview:love];
    [self updateNameLabFrame:NO];
    //    if(![DDSystemInfoManager sharedInstance].isOn)
    //    {
    //        _avatarImgView.image = IMG(@"DDBear");
    //        _nameLab.text = @"正在匹配新朋友";
    //    }
    
    _sexImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.right, (_nameLab.height-20)/2.0+_nameLab.y, 20, 20)];
    _sexImgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_sexImgView];
    str = [[dic objectForKey:@"gender"] isEqualToString:@"M"]?@"sex_man":@"sex_female";
    _sexImgView.image = IMG(str);
    _sexImgView.hidden = YES;
    
    _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLab.bottom+10, kMainScreenWidth, 30)];
    _tipLab.font = kFont16;
    _tipLab.textColor = kcolorWhite;
    _tipLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipLab];
    _tipLab.text = tipsArr[tipIndex];
    
    [switchBtn setY:_tipLab.bottom+10];
    
    //    float width = 100*kScale;
    float height = 140*kScale;
    _localBGView = [[LocalView alloc] initWithFrame:CGRectMake(kMainScreenWidth-width-12, kMainScreenHeight-height-67.5, width, height)];
    _localBGView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_localBGView];
    _localBGView.hidden = YES;
    _localBGView.userInteractionEnabled = NO;
    _localBGView.clipsToBounds = YES;
    
    preView = [[UIView alloc] initWithFrame:CGRectMake(1.5, 1.5, _localBGView.width-3, _localBGView.height-3)];
    preView.clipsToBounds = YES;
    [_localBGView addSubview:preView];
}

- (void)initCaptureSession
{
    if(![GPUImageManager sharedInstance].isOpenCameraService)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _localBGView.hidden = NO;
        [preView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:0];
        [[GPUImageManager sharedInstance] adjustBounds];
//        [GPUImageManager sharedInstance].flag = YES;
        [[GPUImageManager sharedInstance] start:NO];
    });
}

- (void)startMatch
{
    _nameLab.hidden = NO;
    switchBtn.hidden = ![DDSystemInfoManager sharedInstance].isOn;
    [_wait4CallTimer stopTimer];
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    if(_isMatching || ![nav.topViewController isKindOfClass:[MatchingViewController class]] || !self)
        return;
    _isMatching = YES;
    self.calleeData = nil;
    [self initTimer];

    WeakSelf(self)
//    NSDate* tmpStartData = [NSDate date];
    [MobClick event:MsgMatchStart];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:@"0" forKey:@"type"];//0、一般；1、秒配
    [dict setObject:[LocationManager sharedInstance].latitude forKey:@"lat"];
    [dict setObject:[LocationManager sharedInstance].longitude forKey:@"lng"];
    [dict setObject:self.currentGender forKey:@"targetGender"];
    
    [NetManager requestWith:dict apiName:kUserMatch method:kPost timeOutInterval:30 succ:^(NSDictionary *successDict) {
        
        if(!weakself)
            return ;
        
        weakself.isMatching = NO;
        [weakself stopTimer];
        
        if(successDict && ![successDict objectForKey:@"state"])
        {
            if(!weakself.isOkTime)
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:weakself selector:@selector(gotoVideoVC) object:nil];
            }
            

//            double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//            NSString *timeStr = [NSString stringWithFormat:@"%.2f", deltaTime];
            [MobClick event:MsgMatchSuccess];
            OtherUserInfoData *userInfo = [[OtherUserInfoData alloc] init];
            [userInfo unPakceUserInfoDict:successDict];
            
            //            if([DDSystemInfoManager sharedInstance].isOn)
            //            {
            //                weakself.calleeData = userInfo;
            //                [weakself setConnectView];
            //                [weakself startToVideoChat:successDict];
            //            }
            //            else
            //            {
            NSMutableArray *arr = [[FMDBManager shareInstance] getBlackList:GETBLACKLIST];
            if([DDSystemInfoManager sharedInstance].isOn && [arr containsObject:userInfo.strUserId])
            {
                [weakself startMatch];
            }
            else
            {
                weakself.calleeData = userInfo;
                [weakself setConnectView];
                [weakself startToVideoChat:successDict];
            }
            //            }
            
        }
        else
        {
            if([[successDict objectForKey:@"state"] intValue] == 2038)
            {
//                [DLAPPDELEGATE showToastView:[successDict objectForKey:@"message"] duration:1 position:CSToastPositionCenter];
//                [weakself back];
                [weakself initTimer];
                return ;
            }
            
            if(!_isOkTime)
            {
                [weakself showRobot];
            }
            else
                [weakself startMatch];
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        
    }];
}

- (void)startToVideoChat:(NSDictionary *)dic
{
    if([[dic objectForKey:@"isCaller"] boolValue])
    {
        [self startCaller];
    }
    else
    {
        if(_wait4CallTimer)
            [_wait4CallTimer stopTimer];
        
        _wait4CallTimer = [[NTESTimerHolder alloc] init];
        [_wait4CallTimer startTimer:25 delegate:self repeats:NO];
    }
}

- (void)setConnectView
{
    switchBtn.hidden = NO;
    [self stopTimer];
    [self.avatarImgView sd_setImageWithURL:URL(self.calleeData.strHeadUrl) placeholderImage:DEFAULTAVATAR];
    self.nameLab.text = self.calleeData.strUserNick;
    self.vipImgView.hidden = !self.calleeData.isVip;
    //    self.sexImgView.image = self.calleeData.sexType==0?IMG(@"sex_man"):IMG(@"sex_female");
    self.tipLab.text = @"匹配成功，正在连接...";
    [self updateNameLabFrame:YES];
}

- (BOOL)isTopNav
{
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    return [nav.topViewController isKindOfClass:[MatchingViewController class]];
}

- (void)startCaller
{
    if(![self isTopNav])
        return;
    
    [[YXManager sharedInstance] initWithCallee:self.calleeData.strUserId];
    [[YXManager sharedInstance] startByCaller:YES];
}

- (void)connectTimeOut
{
    NSLog(@"connectTimeOut");
    [[YXManager sharedInstance] hangup];

    [self matchAgain];
}

- (void)matchAgain
{
    WeakSelf(self);
    _tipLab.text = @"连接超时，正在重新匹配...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakself)
            [weakself startMatch];
    });
}

- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    WeakSelf(self);
    if(holder == self.wait4CallTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself connectTimeOut];
        });
    }
}

- (void)connectRes:(ConnectState)state
{
    WeakSelf(self)

    __weak UIButton *weakBtn = switchBtn;
    [_wait4CallTimer stopTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakself.detailView)
            [weakself.detailView dismiss];

        //回调或者说是通知主线程刷新，
        if(state == ConnectState_HANGUP_BYTIMER)
            weakself.tipLab.text = @"聊天时间到，正在重新匹配...";
        else if (state == ConnectState_HANGUP_BYUSER)
        {
            weakself.tipLab.text = [YXManager sharedInstance].isUserHangup?@"正在匹配...":@"对方已离开，正在重新匹配...";
            [YXManager sharedInstance].isUserHangup = NO;
        }
        else if (state == ConnectState_CONNECTFAILED)
            weakself.tipLab.text = @"连接超时，正在重新匹配...";
        
        if(state != ConnectState_CONNECTED)
            weakBtn.hidden = ![DDSystemInfoManager sharedInstance].isOn;
        
        [weakself tryToOpenCamera];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(weakself)
            [weakself startMatch];
    });
}

- (void)tryToOpenCamera
{
//    WeakSelf(self)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if(weakself && [weakself shouldTopVC])
//            [weakself initCaptureSession];
//    });
}

- (void)showNoNetView
{
    [self stopTimer];
    
    _isMatching = NO;
    
    _avatarImgView.image = IMG(@"noNetTip");
    _nameLab.hidden = YES;
    _sexImgView.hidden = YES;
    _tipLab.text = @"网络异常，请检查网络...";
}

- (void)back
{
    [self cancelMatch];
    
    [[YXManager sharedInstance] hangup];

    [MobClick event:MsgClickQuitMatch];
    [self stopTimer];
    //    [_bgImgView removeLighting];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelMatch
{
    _isMatching = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    
    [NetManager requestWith:dict apiName:kCancelMatchAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];

}

- (void)switchBtnClick
{
    switchBtn.hidden = ![DDSystemInfoManager sharedInstance].isOn;
    
    if(self.detailView)
        [self.detailView dismiss];

    if(_isMatching)
    {
        [self changeInfo];
        [self changeTip];
        [self stopTimer];
        [self initTimer];
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gotoVideoVC) object:nil];
    _tipLab.text = @"正在重新匹配...";
    
    if(self.calleeData)
    {
        [YXManager sharedInstance].isUserHangup = YES;
        [[YXManager sharedInstance] hangup];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
        [dict setObject:self.calleeData.strUserId forKey:@"targetId"];
        [dict setObject:@"vedio" forKey:@"act"];
        [dict setObject:@(0) forKey:@"len"];
        [dict setObject:@(0) forKey:@"likes"];
        [dict setObject:@(2) forKey:@"discType"];
        
        WeakSelf(self)
        [NetManager requestWith:dict apiName:kRepertAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [weakself startMatch];
        } failure:^(NSDictionary *failDict, NSError *error) {
            [weakself startMatch];
        }];
        
        self.calleeData = nil;
//        [self tryToOpenCamera];
    }
    else
    {
        [self startMatch];
    }
    
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

- (void)gotoVideoChat:(OtherUserInfoData *)userInfo
{
    [_wait4CallTimer stopTimer];

    if(![YXManager sharedInstance].callInfo)
    {
        [[YXManager sharedInstance] hangup];
        return;
    }
    
    if(!self.calleeData)
    {
        [[YXManager sharedInstance] hangup];
        return;
    }
    
    NTESVideoChatViewController *vc = [[NTESVideoChatViewController alloc] init];
    vc.userInfo = self.calleeData;
    vc.isCircleAnimation = YES;
    vc.immediate = YES;
    [vc setYXCallLifeBlocks];
    UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:_avatarImgView.frame];
    
    CGPoint finalPoint = CGPointMake(_avatarImgView.center.x - 0, _avatarImgView.center.y - CGRectGetMaxY(self.view.bounds));
    CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
    UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_avatarImgView.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskFinalBP.CGPath; //将它的 path 指定为最终的 path 来避免在动画完成后会回弹
    self.navigationController.view.backgroundColor = RGBCOLOR(37, 143, 127);
    vc.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((maskFinalBP.CGPath));
    maskLayerAnimation.duration = 0.5;
    maskLayerAnimation.autoreverses = NO;

    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    [self.navigationController pushViewController:vc animated:NO];
    [vc onCalling];
}

- (void)showRobot
{
//    NSInteger index = 0;
//    if([UserInfoData shareUserInfoData].sexType == 0)
//        index = round(random() % 5);
//    else
//        index = round(random() % 2);
    
    switchBtn.hidden = NO;
    
    OtherUserInfoData *user = [robotArr firstObject];
    self.calleeData = user;
    
    self.avatarImgView.image = IMG(user.strHeadUrl);
    self.nameLab.text = user.strUserNick;
    self.vipImgView.hidden = YES;
    self.tipLab.text = @"匹配成功，正在连接...";
    [self updateNameLabFrame:YES];
    
    [self performSelector:@selector(gotoVideoVC) withObject:nil afterDelay:3];

}

- (void)gotoVideoVC
{
    VideoRobotViewController *vc = [[VideoRobotViewController alloc] init];
    vc.userInfo = self.calleeData;
    
    UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithOvalInRect:_avatarImgView.frame];
    
    CGPoint finalPoint = CGPointMake(_avatarImgView.center.x - 0, _avatarImgView.center.y - CGRectGetMaxY(self.view.bounds));
    CGFloat radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y));
    UIBezierPath *maskFinalBP = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_avatarImgView.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskFinalBP.CGPath; //将它的 path 指定为最终的 path 来避免在动画完成后会回弹
    self.navigationController.view.backgroundColor = RGBCOLOR(37, 143, 127);
    vc.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((maskFinalBP.CGPath));
    maskLayerAnimation.duration = 0.5;
    maskLayerAnimation.autoreverses = NO;

    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)showDetailView
{
    if(_isMatching || !self.calleeData)
        return;
    
    WeakSelf(self)
    [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:self.calleeData.strUserId completeBlock:^(NSDictionary *dataDic) {
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

- (void)clickAttentionBtn
{
    NSString *userID = self.calleeData.strUserId;
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

- (void)refreshDetailView
{

    if(!self.detailView)
        return;
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.calleeData.strUserId])
    {
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"互相关注" forState:UIControlStateNormal];
    }
    else if([[DDFriendsInfoManager sharedInstance] isAttentioned:self.calleeData.strUserId])
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

#pragma mark - UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    if(operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[NewRootViewController class]])
    {
        GoMatchVCTransition *transition = [[GoMatchVCTransition alloc] init];
        transition.isPush = NO;
        return transition;
    }
    return nil;
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
        [dict setObject:self.calleeData.strUserId forKey:@"targetId"];
        [dict setObject:title forKey:@"type"];
        
        [NetManager requestWith:dict apiName:kTipoffAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [DLAPPDELEGATE showToastView:@"举报成功" duration:1 position:CSToastPositionCenter];
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

- (BOOL)shouldTopVC
{
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    return [nav.topViewController isKindOfClass:[MatchingViewController class]];
}

@end
