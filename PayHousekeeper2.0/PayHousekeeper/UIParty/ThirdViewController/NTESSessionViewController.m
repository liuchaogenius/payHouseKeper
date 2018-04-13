//
//  NTESSessionViewController.m
//  NIM
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESSessionViewController.h"
@import MobileCoreServices;
@import AVFoundation;
#import "Reachability.h"
#import "UIActionSheet+NTESBlock.h"
//#import "NTESCustomSysNotificationSender.h"
#import "NTESSessionConfig.h"
#import "NIMMediaItem.h"
#import "NTESSessionMsgConverter.h"
#import "NTESFileLocationHelper.h"
#import "UIView+Toast.h"
//#import "NTESLocationViewController.h"
#import "NTESSnapchatAttachment.h"
//#import "NTESJanKenPonAttachment.h"
//#import "NTESFileTransSelectViewController.h"
//#import "NTESAudioChatViewController.h"
//#import "NTESWhiteboardViewController.h"
#import "NTESVideoChatViewController.h"
#import "NTESChartletAttachment.h"
#import "NTESGalleryViewController.h"
//#import "NTESLocationViewController.h"
//#import "NTESVideoViewController.h"
//#import "NTESLocationPoint.h"
//#import "NTESFilePreViewController.h"
//#import "NTESAudio2TextViewController.h"
//#import "NSDictionary+NTESJson.h"
#import "NIMAdvancedTeamCardViewController.h"
//#import "NTESSessionRemoteHistoryViewController.h"
//#import "NIMNormalTeamCardViewController.h"
#import "NTESBundleSetting.h"
//#import "NTESPersonalCardViewController.h"
#import "NTESSessionSnapchatContentView.h"
//#import "NTESSessionLocalHistoryViewController.h"
#import "NIMContactSelectViewController.h"
#import "SVProgressHUD.h"
//#import "NTESSessionCardViewController.h"
//#import "NTESFPSLabel.h"
#import "UIAlertView+NTESBlock.h"
//#import "NTESDataManager.h"
//#import "NTESSessionUtil.h"
#import "DDLoginManager.h"
#import "NIMInputToolBar.h"
#import "PersonHeaderView.h"
#import "PersonDetailView.h"
#import "SPActionSheet.h"
#import "FourthViewController.h"
#import "OtherUserInfoData.h"
#import "MyWalletViewController.h"

typedef enum : NSUInteger {
    NTESImagePickerModeImage,
    NTESImagePickerModeSnapChat,
} NTESImagePickerMode;

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


@interface NTESSessionViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
NIMSystemNotificationManagerDelegate,
NIMMediaManagerDelgate,
//NTESTimerHolderDelegate,
NIMContactSelectDelegate,
SPActionSheetDelegate,
DDAlertViewDelegate>
{
    SPActionSheet *actionsheet;
}

//@property (nonatomic,strong)    NTESCustomSysNotificationSender *notificaionSender;
@property (nonatomic,strong)    NTESSessionConfig       *sessionConfig;
@property (nonatomic,strong)    UIImagePickerController *imagePicker;
@property (nonatomic,assign)    NTESImagePickerMode      mode;
//@property (nonatomic,strong)    NTESTimerHolder         *titleTimer;
@property (nonatomic,strong)    UIView *currentSingleSnapView;
//@property (nonatomic,strong)    NTESFPSLabel *fpsLabel;
@property (nonatomic,strong)    PersonDetailView        *detailView;
@property (nonatomic,assign)    BOOL      isReq; //用来防止多次点击通话按钮
@end



@implementation NTESSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"enter session, id = %@",self.session.sessionId);
    [self setUpNav];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshDetailView)
                                                 name:RosterInfoChangedNotification
                                               object:nil];
//    [self.sessionInputView.toolBar.voiceBtn addTarget:self action:@selector(mediaVideoChatPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc
{
    [[[NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshDetailView
{
    
    if([[DDFriendsInfoManager sharedInstance] isMyFriend:self.session.sessionId])
    {
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateNormal];
        [self.detailView.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateHighlighted];
        [self.detailView.bottomBtn setTitle:@"互相关注" forState:UIControlStateNormal];
    }
    else if([[DDFriendsInfoManager sharedInstance] isAttentioned:self.session.sessionId])
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

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NIMSDK sharedSDK].mediaManager stopRecord];
    [[NIMSDK sharedSDK].mediaManager stopPlay];
}

- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[NTESSessionConfig alloc] init];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

#pragma mark - NIMInputActionDelegate
- (void)onTapMediaItem:(NIMMediaItem *)item
{
    NSDictionary *actions = [self inputActions];
    NSString *value = actions[@(item.tag)];
    BOOL handled = NO;
    if (value) {
        SEL selector = NSSelectorFromString(value);
        if (selector && [self respondsToSelector:selector]) {
            SuppressPerformSelectorLeakWarning([self performSelector:selector]);
            handled = YES;
        }
    }
    if (!handled) {
        NSAssert(0, @"invalid item tag");
    }
}

- (void)onTextChanged:(id)sender
{
//    [_notificaionSender sendTypingState:self.session];
}

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId
{
    NTESChartletAttachment *attachment = [[NTESChartletAttachment alloc] init];
    attachment.chartletId = chartletId;
    attachment.chartletCatalog = catalogId;
    [self sendMessage:[NTESSessionMsgConverter msgWithChartletAttachment:attachment]];
}

#pragma mark - 相册
- (void)mediaPicturePressed
{
    if(![self checkIsMyFriend:self.session.sessionId])
    {
        DDAlertView *alert = [[DDAlertView alloc] initWithTitleText:@"提示" headUrlStr:nil valueArray:nil detailsText:@"互相关注或开通VIP，才能发送图片哦~" closeText:@"取消" nextText:@"开通VIP" translucencyBackground:NO type:BlackAlertViewTypeTitle];
        alert.delegate = self;
        [alert show];
        return;
    }
    
    [self initImagePicker];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    _mode = NTESImagePickerModeImage;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark - 摄像
- (void)mediaShootPressed
{
    if(![self checkIsMyFriend:self.session.sessionId])
    {
        DDAlertView *alert = [[DDAlertView alloc] initWithTitleText:@"提示" headUrlStr:nil valueArray:nil detailsText:@"互相关注或开通VIP，才能发送图片哦~" closeText:@"取消" nextText:@"开通VIP" translucencyBackground:NO type:BlackAlertViewTypeTitle];
        alert.delegate = self;
        [alert show];
        return;
    }
    
    if ([self initCamera]) {
#if TARGET_IPHONE_SIMULATOR
        NSAssert(0, @"not supported");
#elif TARGET_OS_IPHONE
        self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
#endif
    }
}

#pragma mark - 位置
- (void)mediaLocationPressed
{
//    NTESLocationViewController *vc = [[NTESLocationViewController alloc] initWithNibName:nil bundle:nil];
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)onSendLocation:(NTESLocationPoint*)locationPoint{
//    [self sendMessage:[NTESSessionMsgConverter msgWithLocation:locationPoint]];
//}

#pragma mark - 石头剪子布
- (void)mediaJankenponPressed
{
//    NTESJanKenPonAttachment *attachment = [[NTESJanKenPonAttachment alloc] init];
//    attachment.value = arc4random() % 3 + 1;
//    [self sendMessage:[NTESSessionMsgConverter msgWithJenKenPon:attachment]];
}

#pragma mark - 实时语音
- (void)mediaAudioChatPressed
{
//    if ([self checkCondition]) {
//        //由于音视频聊天里头有音频和视频聊天界面的切换，直接用present的话页面过渡会不太自然，这里还是用push，然后做出present的效果
//        NTESAudioChatViewController *vc = [[NTESAudioChatViewController alloc] initWithCallee:self.session.sessionId];
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.25;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
//        transition.type = kCATransitionPush;
//        transition.subtype = kCATransitionFromTop;
//        transition.delegate = self;
//        [self.navigationController.view.layer addAnimation:transition forKey:nil];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:vc animated:NO];
//    }
}

#pragma mark - 视频聊天
- (void)mediaVideoChatPressed
{
    if ([self checkCondition])
    {
        if(![self checkIsMyFriend:self.session.sessionId])
        {
            DDAlertView *alert = [[DDAlertView alloc] initWithTitleText:@"提示" headUrlStr:nil valueArray:nil detailsText:@"开通VIP才能发起视频聊天哦~" closeText:@"取消" nextText:@"开通VIP" translucencyBackground:NO type:BlackAlertViewTypeTitle];
            alert.delegate = self;
            [alert show];
            return;
        }
        //由于音视频聊天里头有音频和视频聊天界面的切换，直接用present的话页面过渡会不太自然，这里还是用push，然后做出present的效果
        WeakSelf(self)
        [[GPUImageManager sharedInstance] checkCameraService:^(BOOL result) {
            if (result)
            {
                weakself.isReq = YES;
                [DLAPPDELEGATE showMakeToastCenter];
                [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:weakself.session.sessionId completeBlock:^(NSDictionary *dataDic) {
                    if(dataDic)
                    {
                        [[YXManager sharedInstance] initWithCallee:weakself.session.sessionId];
                        OtherUserInfoData *userInfo = [[OtherUserInfoData alloc] init];
                        [userInfo unPakceUserInfoDict:dataDic];
                        NTESVideoChatViewController *vc = [[NTESVideoChatViewController alloc] init];
                        vc.userInfo = userInfo;
                        [vc setYXCallLifeBlocks];
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.25;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
                        transition.type = kCATransitionPush;
                        transition.subtype = kCATransitionFromTop;
                        [weakself.navigationController.view.layer addAnimation:transition forKey:nil];
                        weakself.navigationController.navigationBarHidden = YES;
                        [weakself.navigationController pushViewController:vc animated:NO];
                        [[YXManager sharedInstance] startByCaller:NO];
                    }
                    [DLAPPDELEGATE hiddenWindowToast];
                    
                    weakself.isReq = NO;
                }];
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
        }];
    }
}

#pragma mark - 文件传输
- (void)mediaFileTransPressed
{
//    NTESFileTransSelectViewController *vc = [[NTESFileTransSelectViewController alloc]
//                                             initWithNibName:nil bundle:nil];
//    __weak typeof(self) wself = self;
//    vc.completionBlock = ^void(id sender,NSString *ext){
//        if ([sender isKindOfClass:[NSString class]]) {
//            [wself sendMessage:[NTESSessionMsgConverter msgWithFilePath:sender]];
//        }else if ([sender isKindOfClass:[NSData class]]){
//            [wself sendMessage:[NTESSessionMsgConverter msgWithFileData:sender extension:ext]];
//        }
//    };
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 阅后即焚
- (void)mediaSnapchatPressed
{
    [self initImagePicker];
    UIActionSheet *sheet;
    BOOL isCamraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCamraAvailable) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取",nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选取",nil];
    }
    __weak typeof(self) wself = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        UIImagePickerControllerSourceType type;
        switch (index) {
            case 0:
                //相册
                if (isCamraAvailable) {
                    type =  UIImagePickerControllerSourceTypeCamera;
                }else{
                    type =  UIImagePickerControllerSourceTypePhotoLibrary;
                }
                break;
            case 1:
                //相机
                if (isCamraAvailable) {
                    type =  UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                }
            default:
                return;
        }
        wself.imagePicker.sourceType = type;
        wself.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        wself.mode = NTESImagePickerModeSnapChat;
        [wself presentViewController:_imagePicker animated:YES completion:nil];
    }];
}

- (void)sendSnapchatMessage:(UIImage *)image
{
//    NTESSnapchatAttachment *attachment = [[NTESSnapchatAttachment alloc] init];
//    [attachment setImage:image];
//    [self sendMessage:[NTESSessionMsgConverter msgWithSnapchatAttachment:attachment]];
}

#pragma mark - 白板
- (void)mediaWhiteBoardPressed
{
//    NTESWhiteboardViewController *vc = [[NTESWhiteboardViewController alloc] initWithSessionID:nil
//                                                                                        peerID:self.session.sessionId
//                                                                                         types:NIMRTSServiceReliableTransfer | NIMRTSServiceAudio
//                                                                                          info:@"白板演示"];
//    [self presentViewController:vc animated:NO completion:nil];
}



#pragma mark - 提醒消息
- (void)mediaTipPressed
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"输入提醒" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 1:{
//                UITextField *textField = [alert textFieldAtIndex:0];
//                NIMMessage *message = [NTESSessionMsgConverter msgWithTip:textField.text];
//                [self sendMessage:message];

            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - ImagePicker初始化
- (void)initImagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
}

- (BOOL)initCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"检测不到相机设备"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
    }
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"相机权限受限"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
        
    }
    [self initImagePicker];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    if(!orgImage)
    {
        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [del showToastView:@"获取图片失败"];
        return;
    }
    switch (_mode)
    {
        case NTESImagePickerModeImage:
            [self sendMessage:[NTESSessionMsgConverter msgWithImage:orgImage]];
            break;
        case NTESImagePickerModeSnapChat:
            [self sendSnapchatMessage:orgImage];
            break;
        default:
            break;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)genFilenameWithExt:(NSString *)ext
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *uuidStr = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@",uuidStr];
    return [ext length] ? [NSString stringWithFormat:@"%@.%@",name,ext]:name;
}

#pragma mark - 录音事件
- (void)onRecordFailed:(NSError *)error
{
    [self.view makeToast:@"录音失败" duration:2 position:CSToastPositionCenter];
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 2;
}

- (void)showRecordFileNotSendReason
{
    [self.view makeToast:@"录音时间太短" duration:0.2f position:CSToastPositionCenter];
}

#pragma mark - Cell事件
- (void)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink])
    {
        NSString *link = event.data;
        [self.view makeToast:[NSString stringWithFormat:@"tap link : %@",link]
                    duration:2
                    position:CSToastPositionCenter];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameOpenSnapPicture])
    {
        NIMCustomObject *object = event.messageModel.message.messageObject;
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
        if(attachment.isFired){
            return;
        }
        UIView *sender = event.data;
        self.currentSingleSnapView = [NTESGalleryViewController alertSingleSnapViewWithMessage:object.message baseView:sender];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameCloseSnapPicture])
    {
        //点击很快的时候可能会触发两次查看，所以这里不管有没有查看过 先强直销毁掉
        NIMCustomObject *object = event.messageModel.message.messageObject;
        UIView *senderView = event.data;
        [senderView dismissPresentedView:YES complete:nil];
        
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
        if(attachment.isFired){
            return;
        }
        attachment.isFired  = YES;
        NIMMessage *message = object.message;
        if ([NTESBundleSetting sharedConfig].autoRemoveSnapMessage) {
            [[NIMSDK sharedSDK].conversationManager deleteMessage:message];
            [self uiDeleteMessage:message];
            
        }else{
            [[NIMSDK sharedSDK].conversationManager updateMessage:message forSession:message.session completion:nil];
            [self uiUpdateMessage:message];
        }
        [[NSFileManager defaultManager] removeItemAtPath:attachment.filepath error:nil];
        handled = YES;
        self.currentSingleSnapView = nil;
    }

    if (!handled) {
        NSAssert(0, @"invalid event");
    }
}

- (void)onLongPressCell:(NIMMessage *)message inView:(UIView *)view
{
    [super onLongPressCell:message
                    inView:view];
}


- (void)onTapAvatar:(NSString *)userId
{
//    [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:self.session removeRecentSession:YES];
//    return;
    WeakSelf(self)
    [[DDFriendsInfoManager sharedInstance] requestUserInfoUserId:[UserInfoData shareUserInfoData].strUserId accid:userId completeBlock:^(NSDictionary *dataDic) {
        if(dataDic)
        {
            PersonDetailModel *user = [[PersonDetailModel alloc] init];
            [user unPackeDict:dataDic];
            PersonDetailView *view = [[PersonDetailView alloc] initWithDetailModel:user];
            [view.leftBtn addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            weakself.detailView = view;
            if(![userId isEqualToString:[UserInfoData shareUserInfoData].strUserId])
            {
                [weakself refreshDetailView];
                [view.bottomBtn addTarget:weakself action:@selector(clickAttentionBtn:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [view.bottomBtn addTarget:weakself action:@selector(goToPersonalVC) forControlEvents:UIControlEventTouchUpInside];
                [view.profitBtn addTarget:weakself action:@selector(goToMyWalletView) forControlEvents:UIControlEventTouchUpInside];
            }
            [view show];
        }
    }];
}

- (void)goToMyWalletView
{
    [self.detailView dismiss];
    MyWalletViewController *vc = [[MyWalletViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)clickAttentionBtn:(UIButton *)btn
{
    WeakSelf(self)
    if([[DDFriendsInfoManager sharedInstance] isAttentioned:self.session.sessionId])
    {
        [[DDFriendsInfoManager sharedInstance] requestRemoveAttentionID:self.session.sessionId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself refreshDetailView];
        }];
    }
    else
    {
        [[DDFriendsInfoManager sharedInstance] requestAddAttentionID:self.session.sessionId accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            [weakself refreshDetailView];
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
        [dict setObject:self.session.sessionId forKey:@"targetId"];
        [dict setObject:title forKey:@"type"];
        
        [NetManager requestWith:dict apiName:kTipoffAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [DLAPPDELEGATE showToastView:@"举报成功" duration:1 position:CSToastPositionCenter];
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

- (void)goToPersonalVC
{
    [self.detailView dismiss];
    FourthViewController *vc = [[FourthViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Cell Actions
- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showVideo:(NIMMessage *)message
{
//    NIMVideoObject *object = message.messageObject;
//    NTESVideoViewController *playerViewController = [[NTESVideoViewController alloc] initWithVideoObject:object];
//    [self.navigationController pushViewController:playerViewController animated:YES];
//    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
//        //如果封面图下跪了，点进视频的时候再去下一把封面图
//        __weak typeof(self) wself = self;
//        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
//            if (!error) {
//                [wself uiUpdateMessage:message];
//            }
//        }];
//    }
}

- (void)showLocation:(NIMMessage *)message
{
//    NIMLocationObject *object = message.messageObject;
//    NTESLocationPoint *locationPoint = [[NTESLocationPoint alloc] initWithLocationObject:object];
//    NTESLocationViewController *vc = [[NTESLocationViewController alloc] initWithLocationPoint:locationPoint];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFile:(NIMMessage *)message
{
//    NIMFileObject *object = message.messageObject;
//    NTESFilePreViewController *vc = [[NTESFilePreViewController alloc] initWithFileObject:object];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCustom:(NIMMessage *)message
{
   //普通的自定义消息点击事件可以在这里做哦~
}


#pragma mark - 导航按钮
- (void)onTouchUpInfoBtn:(id)sender{
//    NTESSessionCardViewController *vc = [[NTESSessionCardViewController alloc] initWithSession:self.session];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterHistory:(id)sender{
    [self.view endEditing:YES];
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"云消息记录",@"搜索本地消息记录",@"清空本地聊天记录", nil];
//    [sheet showInView:self.view completionHandler:^(NSInteger index) {
//        switch (index) {
//            case 0:{ //查看云端消息
//                NTESSessionRemoteHistoryViewController *vc = [[NTESSessionRemoteHistoryViewController alloc] initWithSession:self.session];
//                [self.navigationController pushViewController:vc animated:YES];
//                break;
//            }
//            case 1:{ //搜索本地消息
//                NTESSessionLocalHistoryViewController *vc = [[NTESSessionLocalHistoryViewController alloc] initWithSession:self.session];
//                [self.navigationController pushViewController:vc animated:YES];
//                break;
//            }
//            case 2:{ //清空聊天记录
//                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定清空聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                __weak UIActionSheet *wSheet;
//                [sheet showInView:self.view completionHandler:^(NSInteger index) {
//                    if (index == wSheet.destructiveButtonIndex) {
//                        BOOL removeRecentSession = [NTESBundleSetting sharedConfig].removeSessionWheDeleteMessages;
//                        [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:self.session removeRecentSession:removeRecentSession];
//                    }
//                }];
//                break;
//            }
//            default:
//                break;
//        }
//    }];
}

- (void)enterTeamCard:(id)sender{
//    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
//    UIViewController *vc;
//    if (team.type == NIMTeamTypeNormal) {
//        vc = [[NIMNormalTeamCardViewController alloc] initWithTeam:team];
//    }else if(team.type == NIMTeamTypeAdvanced){
//        vc = [[NIMAdvancedTeamCardViewController alloc] initWithTeam:team];
//    }
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    if (defaultItems) {
        [items addObjectsFromArray:defaultItems];
    }
    
//    if ([NTESSessionUtil canMessageBeForwarded:message]) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)]];
//    }
//    
//    if ([NTESSessionUtil canMessageBeRevoked:message]) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessage:)]];
//    }
//    
//    if (message.messageType == NIMMessageTypeAudio) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字" action:@selector(audio2Text:)]];
//    }
    
    return items;
    
}

- (void)audio2Text:(id)sender
{
//    NIMMessage *message = [self messageForMenu];
//    __weak typeof(self) wself = self;
//    NTESAudio2TextViewController *vc = [[NTESAudio2TextViewController alloc] initWithMessage:message];
//    vc.completeHandler = ^(void){
//        [wself uiUpdateMessage:message];
//    };
//    [self presentViewController:vc
//                       animated:YES
//                     completion:nil];
}


- (void)forwardMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人",@"群组", nil];
    __weak typeof(self) weakSelf = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
                config.needMutiSelected = NO;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *userId = array.firstObject;
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 1:{
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 2:
                break;
            default:
                break;
        }
    }];
}


- (void)revokeMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
//                DDLogError(@"revoke message eror code %zd",error.code);
                [weakSelf.view makeToast:@"消息撤回失败，请重试" duration:2.0 position:CSToastPositionCenter];
            }
        }
        else
        {
//            NIMMessageModel *model = [self uiDeleteMessage:message];
//            NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:message]];
//            tip.timestamp = model.messageTime;
//            [self uiAddMessages:@[tip]];
//            
//            tip.timestamp = message.timestamp;
//            // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
//            [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
        }
    }];
}


- (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P)
    {
//        name = [[NTESDataManager sharedInstance] infoByUser:session.sessionId inSession:session].showName;
    }
    else
    {
//        name = [[NTESDataManager sharedInstance] infoByTeam:session.sessionId].showName;
    }
    NSString *tip = [NSString stringWithFormat:@"确认转发给 %@ ?",name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转发" message:tip delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(index == 1){
            [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:nil];
            [weakSelf.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
        }
    }];
}

#pragma mark - 辅助方法
- (BOOL)checkCondition
{
    BOOL result = YES;
    
    if(self.isReq)
        result = NO;
    
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        [self.view makeToast:@"请检查网络" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    if ([currentAccount isEqualToString:self.session.sessionId]) {
        [self.view makeToast:@"不能和自己通话哦" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    return result;
}

- (NSDictionary *)inputActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NTESMediaButtonPicture)   : @"mediaPicturePressed",
                    @(NTESMediaButtonShoot)     : @"mediaShootPressed",
                    @(NTESMediaButtonLocation)  : @"mediaLocationPressed",
                    @(NTESMediaButtonJanKenPon) : @"mediaJankenponPressed",
                    @(NTESMediaButtonVideoChat) : @"mediaVideoChatPressed",
                    @(NTESMediaButtonAudioChat) : @"mediaAudioChatPressed",
                    @(NTESMediaButtonFileTrans) : @"mediaFileTransPressed",
                    @(NTESMediaButtonSnapchat)  : @"mediaSnapchatPressed",
                    @(NTESMediaButtonWhiteBoard): @"mediaWhiteBoardPressed",
                    @(NTESMediaButtonTip)       : @"mediaTipPressed"};
    });
    return actions;
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeAudio) :    @"playAudio:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}



- (void)setUpNav
{
    self.view.backgroundColor = RGBCOLOR(244, 244, 244);

//    if(self.session.sessionType == NIMSessionTypeP2P)
//    {
//        if (![self.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
//        {
//            [self setRightButton:IMG(@"personalInfoBtn") title:nil titlecolor:nil target:self action:@selector(onTouchUpInfoBtn:)];
//        }
//    }
}

- (BOOL)shouldAutorotate{
    return !self.currentSingleSnapView;
}

- (BOOL)checkIsMyFriend:(NSString *)userID
{
    if(![[DDFriendsInfoManager sharedInstance] isMyFriend:userID] || ![UserInfoData shareUserInfoData].isVip)
    {
//        [self.view makeToast:@"互相关注才能使用此功能哦" duration:0.5 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}

- (BOOL)passVoiceBtn
{
    if(![self checkIsMyFriend:self.session.sessionId])
    {
        DDAlertView *alert = [[DDAlertView alloc] initWithTitleText:@"提示" headUrlStr:nil valueArray:nil detailsText:@"互相关注或开通VIP，才能发送语音哦~" closeText:@"取消" nextText:@"开通VIP" translucencyBackground:NO type:BlackAlertViewTypeTitle];
        alert.delegate = self;
        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark - DDAlertViewDelegate
- (void)alerViewDidBtnClicked:(UIButton *)btn
{
    
}

@end
