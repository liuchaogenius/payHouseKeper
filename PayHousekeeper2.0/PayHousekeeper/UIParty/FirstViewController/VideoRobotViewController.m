//
//  VideoRobotViewController.m
//  PayHousekeeper
//
//  Created by liuguangren on 2017/1/22.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "VideoRobotViewController.h"
#import "LocalView.h"
#import "VideoChatBottomView.h"
#import "PersonHeaderView.h"

@interface VideoRobotViewController ()
{
    UIView *preView;
}

@property(nonatomic, strong) LocalView      *localBGView;
@property (nonatomic,strong) VideoChatBottomView *bottomView;
@property (nonatomic,strong) PersonHeaderView *headView;
@property (nonatomic,strong) UIButton       *hungUpBtn;                   //挂断按钮
@property (nonatomic,strong) AVPlayer       *player;

@end

@implementation VideoRobotViewController

- (void)dealloc
{
    [self cancelMatch];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self initUI];
    
    [preView insertSubview:[[GPUImageManager sharedInstance] localPreviewView] atIndex:0];
    [[GPUImageManager sharedInstance] adjustBounds];
   
    [[GPUImageManager sharedInstance] start:NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
   
}

- (void)cancelMatch
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    
    [NetManager requestWith:dict apiName:kCancelMatchAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
    
}

- (void)playbackFinished:(NSNotification *)notification {
    NSLog(@"视频播放完成通知");
    [self goRootVC];
}
#pragma mark - 懒加载

- (void)initPlayer
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@.mp4",self.userInfo.strHeadUrl] withExtension:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    layer.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    [self.view.layer addSublayer:layer];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_player play];
    WeakSelf(self)
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    DLAPPDELEGATE.becomeActiveBlock = ^(){
        [weakself.player play];
    };
}

- (VideoChatBottomView *)bottomView
{
    if(!_bottomView)
    {
        _bottomView = [[VideoChatBottomView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight-52, kMainScreenWidth, 42)];
        _bottomView.userInteractionEnabled = NO;
    }
    return _bottomView;
}

- (UIButton *)hungUpBtn
{
    if(!_hungUpBtn)
    {
        _hungUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hungUpBtn.frame = CGRectMake(kMainScreenWidth-60, self.headView.y+5, 40, 40);
        [_hungUpBtn setImage:IMG(@"hungupBtn") forState:UIControlStateNormal];
        [_hungUpBtn addTarget:self action:@selector(goRootVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hungUpBtn;
}

- (LocalView *)localBGView
{
    if(!_localBGView)
    {
        float width = 96*kScale;
        float height = 136*kScale;
        _localBGView = [[LocalView alloc] initWithFrame:CGRectMake(kMainScreenWidth-width-12, kMainScreenHeight-height-67.5, width, height)];
        _localBGView.backgroundColor = [UIColor whiteColor];
        
        preView = [[UIView alloc] initWithFrame:CGRectMake(1.5, 1.5, _localBGView.width-3, _localBGView.height-3)];
        [_localBGView addSubview:preView];
    }
    return _localBGView;
}

- (PersonHeaderView *)headView
{
    if(!_headView)
    {
        PersonHeaderModel *model = [[PersonHeaderModel alloc] init];
        [model unPackeDictFromOtherUserInfo:self.userInfo];
        _headView = [[PersonHeaderView alloc] initWithFrame:CGRectMake(20, 30, 200, 80) headerModel:model];
        [_headView.headerBtn setImage:IMG(self.userInfo.strHeadUrl) forState:UIControlStateNormal];
        [_headView.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
        _headView.userInteractionEnabled = NO;
    }
    return _headView;
}

- (void)goRootVC
{
    [[GPUImageManager sharedInstance] stop];
    [_player pause];
    
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
            [DLAPPDELEGATE showRootviewController];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [self initPlayer];
    
    [self.view addSubview:self.bottomView];
    
    [self.view addSubview:self.headView];
    
    [self.view addSubview:self.localBGView];
    
    [self.view addSubview:self.hungUpBtn];
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
