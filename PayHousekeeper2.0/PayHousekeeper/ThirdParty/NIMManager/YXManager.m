//
//  YXManager.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "YXManager.h"
#import "AppDelegate.h"
#import "NTESVideoChatViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "DDLoginManager.h"
#import "MatchingViewController.h"
#import "NTESChartletAttachment.h"
#import "NTESCustomAttachmentDecoder.h"
#import "NTESDataManager.h"
#import "OtherUserInfoData.h"
#import "SCach.h"
#import "FMDBManager.h"
#import "NTESTimerHolder.h"

//十秒之后如果还是没有收到对方响应的control字段，则自己发起一个假的control，用来激活铃声并自己先进入房间
#define DelaySelfStartControlTime 15
//激活铃声后无人接听的超时时间
#define NoBodyResponseTimeOut 40

@interface YXManager ()<NIMLoginManagerDelegate,NIMConversationManagerDelegate,NIMChatManagerDelegate,NIMSystemNotificationManagerDelegate,NIMNetCallManagerDelegate,NIMRTSManagerDelegate,NTESTimerHolderDelegate>
{
    BOOL isVideoChatting;
}
@property (nonatomic,strong) AVAudioPlayer *messPlayer; //播放提示音
@property (nonatomic, strong) NSMutableArray *chatRoom;
@property (nonatomic, strong) NTESTimerHolder *calleeResponseTimer; //被叫等待用户响应接听或者拒绝的时间
@property (nonatomic, strong) NTESTimerHolder *responsedTimer; //响应后等待接通的时间
@property (nonatomic, strong) NTESTimerHolder *waitConnectRingTimer; //等待呼叫铃声的时间
@property (nonatomic, strong) NTESTimerHolder *waitResponseTimer; //等待对方应答的时间
@property (nonatomic, strong) NTESTimerHolder *waitcallerTimeOutTimer; //等待呼叫超时
@property (nonatomic, strong) NTESTimerHolder *holderAcceptTimer; //等待同意

@property (nonatomic, assign) BOOL calleeResponsed;
@property (nonatomic,strong) OtherUserInfoData *userInfo;
@property (assign) BOOL isNeedProtect,isWaiting;


@end

@implementation YXManager
+ (YXManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static YXManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[YXManager alloc] init];
    });
    return sSharedInstance;
}

#pragma mark 初始化方法
- (id)init
{
    self=[super init];
    if(self)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"message" withExtension:@"wav"];
        _messPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [[NIMSDK sharedSDK] registerWithAppID:NIMAPPKEY
                                      cerName:NIMCERNAME];
        [NIMCustomObject registerCustomDecoder:[NTESCustomAttachmentDecoder new]];
        [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
        [[NIMSDK sharedSDK].conversationManager addDelegate:self];
        
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
        [[NIMSDK sharedSDK].netCallManager addDelegate:self];
        [[NIMSDK sharedSDK].rtsManager addDelegate:self];
        
        _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
        if (!self.recentSessions.count) {
            _recentSessions = [NSMutableArray array];
        }
        else
        {
            [self filterConversation];
        }
        
//        NSArray *notifications = [[[NIMSDK sharedSDK] systemNotificationManager]
//                                  fetchSystemNotifications:nil limit:MaxNotificationCount];
//        _notifications = [NSMutableArray array];
//        if ([notifications count])
//        {
//            [_notifications addObjectsFromArray:notifications];
//        }
    }
    return self;
}

//更新APNS Token
- (void)updateApnsToken:(NSData *)token
{
    [[NIMSDK sharedSDK] updateApnsToken:token];
}

//登录
- (void)yxLogin:(UserInfoData *)user
{
    if(user)
    {
        [[[NIMSDK sharedSDK] loginManager] login:user.strUserId
                                           token:user.strUserToken
                                      completion:^(NSError *error) {
                                          if(!error)
                                          {
                                              [DLAPPDELEGATE showRootviewController];
                                          }
                                          else
                                          {
                                              [DLAPPDELEGATE showToastView:error.localizedDescription];
                                              [DLAPPDELEGATE showLoginWindow];
                                          }
                                      }];

    }
//    BOOL isAutoLogin = NO;
//    
//    if(isAutoLogin)
//    {
//        [[[NIMSDK sharedSDK] loginManager] autoLogin:@"liuwenfeiyun"
//                                               token:@"9ab05cae3461bcb6642a19b67784866a"];
//        return;
//    }
//    
    
}

//自动登录
- (void)yxAutoLogin
{
    [[[NIMSDK sharedSDK] loginManager] autoLogin:[UserInfoData shareUserInfoData].strUserId
                                           token:[UserInfoData shareUserInfoData].strUserToken];
}

//退出登录
- (void)yxLogout:(void(^)(NSError *err))completion
{
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error){
        completion(error);
    }];
}

//根据session获取信息
- (NIMKitInfo *)getInfoBySession:(NIMRecentSession *)session
{
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info = [self infoByUser:session.session.sessionId inSession:session.session];
    return info;
}

//根据userId获取信息
- (NIMKitInfo *)getInfoByUserId:(NSString *)userId
{
    if(!userId)
        return nil;
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info = [self infoByUser:userId inSession:nil];
    return info;
}

//根据session获取信息
- (NSString *)getContentForRecentSession:(NIMRecentSession *)session
{
    return [self messageContent:session.lastMessage];
}

//根据session delete
- (void)deleteRecentSession:(NIMRecentSession *)session
{
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager deleteRecentSession:session];
    
    [self.recentSessions removeObject:session];
    
    [manager deleteRemoteSessions:@[session.session]
                       completion:nil];
}

//添加好友
- (void)addFriend:(NSString *)userID isForced:(BOOL)isForced
{
//    WeakSelf(self)
//    NIMUserRequest *request = [[NIMUserRequest alloc] init];
//    request.userId = userID;
//    if(isForced)
//    {
//        request.operation = NIMUserOperationAdd;
//    }
//    else
//    {
//        request.operation = NIMUserOperationRequest;
//        request.message = @"跪求通过";
//    }
//    
////    NSString *successText = @"请求成功";
////    NSString *failedText =  @"请求失败";
//    
//    [SVProgressHUD show];
//    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        if (!error) {
//            if(isForced)
//                [weakself updateFriends];
////            if(!isForced)
////                [DLAPPDELEGATE showToastView:successText];
////            else
////                [weakself updateFriends];
//        }else{
////            if(!isForced)
////                [DLAPPDELEGATE showToastView:failedText];
//        }
//    }];
}

//删除好友
- (void)deleteFriend:(NSString *)userID
{
//    WeakSelf(self)
//    [SVProgressHUD show];
//    [[NIMSDK sharedSDK].userManager deleteFriend:userID completion:^(NSError * _Nullable error) {
//        [SVProgressHUD dismiss];
//        if (!error) {
//            [DLAPPDELEGATE showToastView:@"删除成功"];
//            [weakself updateFriends];
//            [weakself filterConversation];
//        }else{
//            [DLAPPDELEGATE showToastView:@"删除失败"];
//        }
//    }];
}

//标记所有系统消息为已读
- (void)markAllNotificationsAsRead
{
    [[[NIMSDK sharedSDK] systemNotificationManager] markAllNotificationsAsRead];
}

//加载更多系统消息
- (void)loadMoreSysMess
{
//    NSArray *notifications = [[[NIMSDK sharedSDK] systemNotificationManager] fetchSystemNotifications:[_notifications lastObject] limit:MaxNotificationCount];
//    if ([notifications count])
//    {
//        [_notifications addObjectsFromArray:notifications];
//        if(_refreshSysMess)
//        {
//            _refreshSysMess();
//        }
//    }
}

//获取所有未读数
- (NSInteger)getAllUnreadCount
{
    NSInteger count = [[[NIMSDK sharedSDK] conversationManager] allUnreadCount];
    return count;
}

//发送自定义通知
- (void)sendCustomSystemNotification:(NSDictionary *)dic toSessionID:(NSString *)sessionID sendToOnlineUsersOnly:(BOOL)sendToOnlineUsersOnly
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                   options:0
                                                     error:nil];
    NSString *content = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    notification.sendToOnlineUsersOnly = sendToOnlineUsersOnly;
    NIMCustomSystemNotificationSetting *setting = [[NIMCustomSystemNotificationSetting alloc] init];
    setting.apnsEnabled  = NO;
    notification.setting = setting;
    [[[NIMSDK sharedSDK] systemNotificationManager] sendCustomNotification:notification
                                                                 toSession:[NIMSession session:sessionID type:NIMSessionTypeP2P]
                                                                completion:nil];
}

#pragma mark - Private
- (void)filterConversation
{
    NSMutableArray *tmpArr = [NSMutableArray array];
    for(NIMRecentSession *recent in _recentSessions)
    {
        if(![[DDFriendsInfoManager sharedInstance] getFriendInfo:recent.session.sessionId])
        {
            [tmpArr addObject:recent];
        }
    }
    
    for(NIMRecentSession *recent in tmpArr)
    {
        [self deleteRecentSession:recent];
    }
}

//- (void)updateFriends
//{
//    _myFriends = [[NIMSDK sharedSDK].userManager.myFriends mutableCopy];
//    if (!self.myFriends.count) {
//        _myFriends = [NSMutableArray array];
//    }
//    if(_refreshContact)
//    {
//        _refreshContact();
//    }
//}

- (NSInteger)findInsertPlace:(NIMRecentSession *)recentSession{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.recentSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NIMRecentSession *item = obj;
        if (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.recentSessions.count;
    }
}

- (void)sort{
    [self.recentSessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NIMRecentSession *item1 = obj1;
        NIMRecentSession *item2 = obj2;
        if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (NSString*)messageContent:(NIMMessage*)lastMessage{
    NSString *text = @"";
    if (lastMessage.messageType == NIMMessageTypeCustom) {
        NIMCustomObject *object = lastMessage.messageObject;
        if ([object.attachment isKindOfClass:[NTESChartletAttachment class]]) {
            text = @"[贴图]";
        }
        else{
            text = @"[未知消息]";
        }
        if (lastMessage.session.sessionType == NIMSessionTypeP2P) {
            return text;
        }
    }
    switch (lastMessage.messageType) {
        case NIMMessageTypeText:
            text = lastMessage.text;
            break;
        case NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case NIMMessageTypeNotification:{
            return [self notificationMessageContent:lastMessage];
        }
        case NIMMessageTypeFile:
            text = @"[文件]";
            break;
        case NIMMessageTypeTip:
            text = lastMessage.text;
            break;
        default:
            text = @"[未知消息]";
    }
    if (lastMessage.session.sessionType == NIMSessionTypeP2P) {
        return text;
    }
    else{
        NSString *nickName = [self infoByUser:lastMessage.from inSession:lastMessage.session].showName;
        return nickName.length ? [nickName stringByAppendingFormat:@" : %@",text] : @"";
    }
}

- (NSString *)notificationMessageContent:(NIMMessage *)lastMessage{
    NIMNotificationObject *object = lastMessage.messageObject;
    if (object.notificationType == NIMNotificationTypeNetCall) {
        NIMNetCallNotificationContent *content = (NIMNetCallNotificationContent *)object.content;
        if (content.callType == NIMNetCallTypeAudio) {
            return @"[网络通话]";
        }
        return @"[视频聊天]";
    }
    if (object.notificationType == NIMNotificationTypeTeam) {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:lastMessage.session.sessionId];
        if (team.type == NIMTeamTypeNormal) {
            return @"[讨论组信息更新]";
        }else{
            return @"[群信息更新]";
        }
    }
    return @"[未知消息]";
}

- (NIMKitInfo *)infoByUser:(NSString *)userId
                 inSession:(NIMSession *)session
{
    return [[NTESDataManager sharedInstance] infoByUser:userId inSession:session];
}

- (NSString *)nickname:(NIMUser *)user
            memberInfo:(NIMTeamMember *)memberInfo
{
    NSString *name = nil;
    do{
        if ([user.alias length])
        {
            name = user.alias;
            break;
        }
        if (memberInfo && [memberInfo.nickname length])
        {
            name = memberInfo.nickname;
            break;
        }
        
        if ([user.userInfo.nickName length])
        {
            name = user.userInfo.nickName;
            break;
        }
    }while (0);
    return name;
}

#pragma NIMLoginManagerDelegate
-(void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    NSString *reason = @"你被踢下线";
    switch (code) {
        case NIMKickReasonByClient:
        case NIMKickReasonByClientManually:{
            reason = @"您的账号已在其他手机上登录，如果不是你本人操作，请尽快更换密码";
            break;
        }
        case NIMKickReasonByServer:
            reason = @"你被服务器踢下线";
            break;
        default:
            break;
    }
    
    [self yxLogout:^(NSError *err) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知" message:reason delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        alert.tag = 9999;
        [alert show];
        
        [[SCach shareInstance] removeFileData:kStoreUserDataKey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserDataKey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_WBkey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_QQkey filePath:nil];
        [[SCach shareInstance] removeFileData:kStoreUserData_WXKey filePath:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDDLoginType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [DLAPPDELEGATE showLoginWindow];
        DLAPPDELEGATE.currentLoginType = 0;
        DLAPPDELEGATE.loginType = 0;
    }];
}

- (void)onAutoLoginFailed:(NSError *)error
{
    NSLog(@"%@", error.description);
//只有连接发生严重错误才会走这个回调，在这个回调里应该登出，返回界面等待用户手动重新登录。
//    DDLogInfo(@"onAutoLoginFailed %zd",error.code);
    [DLAPPDELEGATE showToastView:@"登录失败，请重新登录!"];
    [DLAPPDELEGATE showLoginWindow];
    [self yxLogout:^(NSError *err) {
        
    }];
}

- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        
        _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
        
        if(self.refreshConList)
            self.refreshConList();
    }
    else if (step == NIMLoginStepLoginOK)
    {
        [[DDSystemInfoManager sharedInstance] getBroadcastInfo];
        [[DDSystemInfoManager sharedInstance] getGiftsInfo];
        [[DDFriendsInfoManager sharedInstance] getMyFriendsInfo];
        [[DDFriendsInfoManager sharedInstance] getMyFansInfo];
        [[DDFriendsInfoManager sharedInstance] getMyAttentionInfo];
        [[DDSystemInfoManager sharedInstance] getRandAvatarInfo];
        [[FMDBManager shareInstance] createTable:CREATEBLACKLISTTAB];
        [[DDLoginManager shareLoginManager] requesUpdateUserInfo:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
            
        }];
    }
    
    NSLog(@"NIMLoginStep = %ld",(long)step);
}

#pragma NIMChatManagerDelegate
//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    static BOOL isPlaying = NO;
    if (isPlaying) {
        return;
    }
    isPlaying = YES;
    [self playMessageAudioTip];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isPlaying = NO;
    });
    
    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    [self filterConversation];
    if(self.refreshConList)
        self.refreshConList();
}

- (void)playMessageAudioTip
{
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    BOOL needPlay = YES;
    if ([nav.topViewController isKindOfClass:[NIMSessionViewController class]])
    {
        needPlay = NO;
    }
    if (needPlay) {
        [self.messPlayer stop];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];
        [self.messPlayer play];
    }
}

- (void)onMessageRevoked:(NIMMessage *)message
{
//    NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:message]];
//    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
//    setting.shouldBeCounted = NO;
//    tip.setting = setting;
//    
//    NTESMainTabController *tabVC = [NTESMainTabController instance];
//    UINavigationController *nav = tabVC.selectedViewController;
//    
//    for (NTESSessionViewController *vc in nav.viewControllers) {
//        if ([vc isKindOfClass:[NTESSessionViewController class]]
//            && [vc.session.sessionId isEqualToString:message.session.sessionId]) {
//            NIMMessageModel *model = [vc uiDeleteMessage:message];
//            tip.timestamp = model.messageTime;
//            [vc uiAddMessages:@[tip]];
//            break;
//        }
//    }
//    
//    tip.timestamp = message.timestamp;
//    // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
//    [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    if([[DDFriendsInfoManager sharedInstance] getFriendInfo:recentSession.session.sessionId])
    {
        [self.recentSessions addObject:recentSession];
        [self sort];
        if(self.refreshConList)
            self.refreshConList();
    }
}


- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    for (NIMRecentSession *recent in self.recentSessions) {
        if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
            [self.recentSessions removeObject:recent];
            break;
        }
    }
    NSInteger insert = [self findInsertPlace:recentSession];
    [self.recentSessions insertObject:recentSession atIndex:insert];
    if(self.refreshConList)
        self.refreshConList();
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    [self filterConversation];
    if(self.refreshConList)
        self.refreshConList();
}

- (void)allMessagesDeleted{
    _recentSessions = [[NIMSDK sharedSDK].conversationManager.allRecentSessions mutableCopy];
    [self filterConversation];
    if(self.refreshConList)
        self.refreshConList();
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification
{
//    NIMSystemNotificationType type = notification.type;
//    WeakSelf(self)
//    switch (type)
//    {
//        case NIMSystemNotificationTypeFriendAdd:
//        {
//            [_notifications insertObject:notification atIndex:0];
//            if(self.refreshSysMess)
//                self.refreshSysMess();
//            
//            NSString *text = @"未知请求";
//            id object = notification.attachment;
//            if ([object isKindOfClass:[NIMUserAddAttachment class]])
//            {
//                NIMUserOperation operation = [(NIMUserAddAttachment *)object operationType];
//                if(operation == NIMUserOperationRequest)
//                {
//                    text = @"对方请求加你为好友";
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:nil cancelButtonTitle:@"忽略" otherButtonTitles:@"同意", nil];
//                    [alert showAlertWithCompletionHandler:^(NSInteger idx)
//                    {
//                        NIMUserRequest *request = [[NIMUserRequest alloc] init];
//                        request.userId = notification.sourceID;
//                        request.operation = idx?NIMUserOperationVerify:NIMUserOperationReject;
//                        
//                        [[[NIMSDK sharedSDK] userManager] requestFriend:request
//                                                             completion:^(NSError *error){
//                                                                 if (!error)
//                                                                 {
//                                                                     [DLAPPDELEGATE showToastView:idx?@"验证成功":@"拒绝成功"];
//                                                                     [weakself updateFriends];
//                                                                 }
//                                                                 else
//                                                                 {
//                                                                     [DLAPPDELEGATE showToastView:idx?@"验证失败,请重试":@"拒绝失败,请重试"];
//                                                                 }
//                                                            }];
//                        
//                    }];
//                }
//                else if(operation == NIMUserOperationVerify)
//                {
//                    [[DDLoginManager shareLoginManager] requestAddFriendID:notification.sourceID accid:[UserInfoData shareUserInfoData].strUserId completeBlock:^(BOOL ret) {
//                        
//                    }];
//                    [self updateFriends];
//                }
//            }
//        }
//        break;
//        default:
//            break;
//    }
    
}

- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    NSData *data = [[notification content] dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([[dict objectForKey:NTESNotifyID] intValue] == NTESRoserChange)
        {
            [[DDFriendsInfoManager sharedInstance] getMyAttentionInfo];
            [[DDFriendsInfoManager sharedInstance] getMyFansInfo];
            [[DDFriendsInfoManager sharedInstance] getMyFriendsInfo];
        }
    }
    
    if(_onReceiveCustomSystemNotificationBlock)
    {
        _onReceiveCustomSystemNotificationBlock(notification);
    }
}

#pragma mark - NIMNetCallManagerDelegate
- (void)onReceive:(UInt64)callID from:(NSString *)caller type:(NIMNetCallType)type message:(NSString *)extendMessage{
    
    if(![GPUImageManager sharedInstance].isOpenCameraService)
    {
        [[NIMSDK sharedSDK].netCallManager response:callID accept:NO option:nil completion:nil];
        return;
    }
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    [nav.topViewController.view endEditing:YES];
    
    if ([self shouldResponseBusy] || self.callInfo)
    {
        [[NIMSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
    }
    else
    {
        if(type == NIMNetCallTypeVideo)
        {
            if (!extendMessage)
            {
                NSLog(@"extendMessage为nil");
                return;
            }
            
            NSData *jsonData = [extendMessage dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err) {
                NSLog(@"json解析失败：%@",err);  
                return;
            }
            
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            OtherUserInfoData *userInfo = [[OtherUserInfoData alloc] init];
            [userInfo unPakceUserInfoDict:dataDic];
            BOOL isImmediate = [[dic objectForKey:@"immediate"] boolValue];
            if(isImmediate)
            {
                if([DDSystemInfoManager sharedInstance].isOn)
                {
                    NSMutableArray *arr = [[FMDBManager shareInstance] getBlackList:GETBLACKLIST];
                    if([arr containsObject:userInfo.strUserId])
                    {
                        [[NIMSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
                        return;
                    }
                }
                
                UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
                if(![nav.topViewController isKindOfClass:[MatchingViewController class]])
                {
                    [[NIMSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
                    return;
                }
                [self initWithCaller:caller callId:callID];
                self.callInfo.immediate = isImmediate;
                _isWaiting = YES;
                self.userInfo = userInfo;

                if(_holderAcceptTimer)
                    [_holderAcceptTimer stopTimer];
                
                _holderAcceptTimer = [[NTESTimerHolder alloc] init];
                [_holderAcceptTimer startTimer:5 delegate:self repeats:NO];
            }
            else
            {
                _isWaiting = NO;
                [self initWithCaller:caller callId:callID];
                NTESVideoChatViewController *vc = [[NTESVideoChatViewController alloc] init];
                vc.immediate = isImmediate;
                vc.isCircleAnimation = isImmediate;
                vc.userInfo = userInfo;
                [vc setYXCallLifeBlocks];
                CATransition *transition = [CATransition animation];
                transition.duration = 0.25;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromTop;
                [nav.view.layer addAnimation:transition forKey:nil];
                nav.navigationBarHidden = YES;
                [nav pushViewController:vc animated:NO];
                [self startByCallee];
            }
        }
    }
}

- (void)onRTSRequest:(NSString *)sessionID
                from:(NSString *)caller
            services:(NSUInteger)types
             message:(NSString *)info
{
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    [nav.topViewController.view endEditing:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self shouldResponseBusy] || self.callInfo) {
            [[NIMSDK sharedSDK].rtsManager responseRTS:sessionID accept:NO option:nil completion:nil];
        }
    });
}

- (BOOL)shouldResponseBusy
{
    UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
    return [nav.topViewController isKindOfClass:[NTESVideoChatViewController class]];
}
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 9999)
//    {
//        [self backLoginViewController];
//    }
//}
//- (void)backLoginViewController
//{
//    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [del showLoginWindow];
//}

#pragma mark - Subclass Impl
- (void)begintoCall
{
    if (!self.callInfo) {
        return;
    }
    
    self.callInfo.isStart = YES;
    NSArray *callees = [NSArray arrayWithObjects:self.callInfo.callee, nil];
    
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    NSDictionary *dataDic = @{@"accid":SAFE_STR([UserInfoData shareUserInfoData].strUserId),
                              @"age":SAFE_STR([UserInfoData shareUserInfoData].strBirthday),
                              @"avatar":SAFE_STR([UserInfoData shareUserInfoData].strHeadUrl),
                              @"constellation":@"射手座",
                              @"gender":SAFE_STR([UserInfoData shareUserInfoData].strGender),
                              @"mood":SAFE_STR([UserInfoData shareUserInfoData].strUserMsg),
                              @"nickName":SAFE_STR([UserInfoData shareUserInfoData].strUserNick),
                              @"wealthLevel":@([UserInfoData shareUserInfoData].wealthlevel),
                              @"charmLevel":@([UserInfoData shareUserInfoData].charmlevel),
                              @"vip":@([UserInfoData shareUserInfoData].isVip)
                              };
    NSDictionary *dic = @{@"version":@"0.9",
                          @"immediate":@(self.callInfo.immediate),
                          @"data":dataDic
                          };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    option.extendMessage = jsonString;//@"音视频请求扩展信息";
    option.apnsContent = [NSString stringWithFormat:@"%@请求", self.callInfo.callType == NIMNetCallTypeAudio ? @"网络通话" : @"视频聊天"];
    option.apnsSound = @"video_chat_tip_receiver.aac";
    [self fillUserSetting:option];
    WeakSelf(self);
    [[NIMSDK sharedSDK].netCallManager start:callees type:self.callInfo.callType option:option completion:^(NSError *error, UInt64 callID) {
        if (!error && self.callInfo) {
            weakself.callInfo.callID = callID;
            weakself.chatRoom = [[NSMutableArray alloc]init];
            //十秒之后如果还是没有收到对方响应的control字段，则自己发起一个假的control，用来激活铃声并自己先进入房间
            NSTimeInterval delayTime = DelaySelfStartControlTime;
            if(weakself.waitResponseTimer)
                [weakself.waitResponseTimer stopTimer];
            
            weakself.waitResponseTimer = [[NTESTimerHolder alloc] init];
            [weakself.waitResponseTimer startTimer:delayTime delegate:weakself repeats:NO];
        }
        else
        {
            if (error)
            {
                if(self.callInfo.immediate)
                {
                    if(self.connectBlock)
                    {
                        NSLog(@"1111111111111");
                        self.connectBlock(ConnectState_CONNECTFAILED);
                    }
                }
                else
                    [DLAPPDELEGATE showToastView:@"连接失败"];
            }
            else
            {
                //说明在start的过程中把页面关了。。
                if(!self.callInfo.immediate)
                    [[NIMSDK sharedSDK].netCallManager hangup:callID];
            }
            [self dismiss];
        }
    }];
}

- (void)startByCaller:(BOOL)immediate
{
    NSLog(@"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");

    if(!immediate)
        [self playConnnetRing];
    //等铃声播完再打过去，太快的话很假
    if(_waitConnectRingTimer)
        [_waitConnectRingTimer stopTimer];
    
    _waitConnectRingTimer = [[NTESTimerHolder alloc] init];
    [_waitConnectRingTimer startTimer:immediate?0.5:3.0 delegate:self repeats:NO];
    
    self.callInfo.immediate = immediate;
    
    if(_startByCallerBlock)
    {
        _startByCallerBlock();
    }
}

- (void)startByCallee
{
    //告诉对方可以播放铃声了
    self.callInfo.isStart = YES;
    NSMutableArray *room = [[NSMutableArray alloc] init];
    [room addObject:self.callInfo.caller];
    self.chatRoom = room;
    [[NIMSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeFeedabck];
    if(!self.callInfo.immediate)
        [self playReceiverRing];
    
    if(_calleeResponseTimer)
        [_calleeResponseTimer stopTimer];
    
    _calleeResponseTimer = [[NTESTimerHolder alloc] init];
    [_calleeResponseTimer startTimer:NoBodyResponseTimeOut delegate:self repeats:NO];
    
    if(_startByCalleeBlock)
    {
        _startByCalleeBlock();
    }
}


- (void)hangup
{
    
    if(_connectBlock && self.callInfo.immediate && _isNeedProtect)
    {
        NSLog(@"jiduan");
        _connectBlock(ConnectState_CONNECTFAILED);
    }
    
    _isNeedProtect = NO;
    
    [self.player stop];
    
//    if(self.callInfo.immediate && _connectBlock)
//    {
//        NSLog(@"8888888");
//        _connectBlock(ConnectState_CONNECTFAILED);
//    }
    
    [[NIMSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
    
    [self dismiss];
}

- (void)response:(BOOL)accept
{
    NSLog(@"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    if(accept)
    {
        [[GPUImageManager sharedInstance] stop];
        [[GPUImageManager sharedInstance] setupYX];
    }
    
    _calleeResponsed = YES;
    
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    [self fillUserSetting:option];
    
    __weak typeof(self) wself = self;
    
    [[NIMSDK sharedSDK].netCallManager response:self.callInfo.callID accept:accept option:option completion:^(NSError *error, UInt64 callID) {
        if (!error) {
            [wself onCalling];
            [wself.player stop];
            [wself.chatRoom addObject:wself.callInfo.callee];
            NSTimeInterval delay = 10.f; //10秒后判断下房间
            if(wself.responsedTimer)
                [wself.responsedTimer stopTimer];
            wself.responsedTimer = [[NTESTimerHolder alloc] init];
            [wself.responsedTimer startTimer:delay delegate:wself repeats:NO];
        }
        else
        {
            if(wself.callInfo.immediate)
            {
                if(wself.connectBlock)
                {
                    NSLog(@"99999999999");
                    wself.connectBlock(ConnectState_CONNECTFAILED);
                }
            }
            else
                [DLAPPDELEGATE showToastView:@"连接失败"];
            [wself dismiss];
        }
    }];
    //dismiss需要放在self后面，否在ios7下会有野指针
    if (accept)
    {
        [self waitForConnectiong];
    }
    else
    {
        [self dismiss];
    }
}

- (void)disableCammera:(BOOL)isDisableCammera
{
    if(!self.callInfo || self.callInfo.disableCammera == isDisableCammera || !isVideoChatting)
        return;
    
    self.callInfo.disableCammera = isDisableCammera;
    [[NIMSDK sharedSDK].netCallManager setCameraDisable:isDisableCammera];
    [[NIMSDK sharedSDK].netCallManager control:self.callInfo.callID type:isDisableCammera?NIMNetCallControlTypeCloseVideo:NIMNetCallControlTypeOpenVideo];
}

- (void)switchVideoQuality:(NIMNetCallVideoQuality)videoQuality
{
    if([[NIMSDK sharedSDK].netCallManager switchVideoQuality:videoQuality])
    {
        if(videoQuality == NIMNetCallVideoQualityMedium)
        {
            [DLAPPDELEGATE showToastView:@"当前视频质量:Medium"];
        }
        else if (videoQuality == NIMNetCallVideoQualityLow)
        {
            [DLAPPDELEGATE showToastView:@"当前视频质量:Low"];
        }
    }
}

#pragma mark - NIMNetCallManagerDelegate
- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control
{
    switch (control) {
        case NIMNetCallControlTypeFeedabck:
        {
            NSMutableArray *room = self.chatRoom;
            if (room && !room.count)
            {
                if(!self.callInfo.immediate)
                    [self playSenderRing];
                [room addObject:self.callInfo.caller];
                //40秒之后查看一下房间状态，如果房间还在一个人的话，就播放铃声超时
                __weak typeof(self) wself = self;
//                uint64_t callId = self.callInfo.callID;
                NSTimeInterval delayTime = wself.callInfo.immediate?10:NoBodyResponseTimeOut;
                if(wself.waitcallerTimeOutTimer)
                    [wself.waitcallerTimeOutTimer stopTimer];
                
                wself.waitcallerTimeOutTimer = [[NTESTimerHolder alloc] init];
                [wself.waitcallerTimeOutTimer startTimer:delayTime delegate:wself repeats:NO];
            }
            break;
        }
        case NIMNetCallControlTypeBusyLine:
        {
            if(!self.callInfo.immediate)
                [self playOnCallRing];
            else
            {
                if(_connectBlock)
                {
                    NSLog(@"4444444444444");
                    _connectBlock(ConnectState_CONNECTFAILED);
                }
            }
//            __weak typeof(self) wself = self;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismiss];
//            });
            break;
        }
        case NIMNetCallControlTypeCloseVideo:
        case NIMNetCallControlTypeBackground:
            [DLAPPDELEGATE showToastView:@"对方已暂时关闭摄像头~" duration:3 position:CSToastPositionCenter];
            break;
        case NIMNetCallControlTypeOpenVideo:
            [DLAPPDELEGATE showToastView:@"对方已重新打开摄像头~" duration:3 position:CSToastPositionCenter];
            break;
        default:
            break;
    }
}

- (void)onResponse:(UInt64)callID from:(NSString *)callee accepted:(BOOL)accepted
{
    if (self.callInfo.callID == callID)
    {
        if (!accepted)
        {
            self.chatRoom = nil;
            
            if(!self.callInfo.immediate)
            {
                [DLAPPDELEGATE showToastView:@"对方拒绝接听"];
                [self playHangUpRing];
            }
            else
            {
                if(_connectBlock)
                {
                    NSLog(@"555555555");
                    _connectBlock(ConnectState_CONNECTFAILED);
                }
            }
            [self dismiss];
        }
        else
        {
            _isNeedProtect = YES;
            [[GPUImageManager sharedInstance] stop];
            [[GPUImageManager sharedInstance] setupYX];
            [self.player stop];
            [self onCalling];
            [self.chatRoom addObject:callee];
        }
        
        [_waitResponseTimer stopTimer];
    }
}

- (void)onCall:(UInt64)callID status:(NIMNetCallStatus)status
{
    if (self.callInfo.callID != callID) {
        return;
    }
    
    _isNeedProtect = NO;
    
    //记时
    switch (status) {
        case NIMNetCallStatusConnect:
        {
            //开始计时
            self.callInfo.startTime = [NSDate date].timeIntervalSince1970;
            isVideoChatting = YES;
            _isUserHangup = NO;
            
            if(_immediateBlock && self.callInfo.immediate)
            {
                _immediateBlock(_userInfo);
            }
            
            if(_onLocalPreviewReadyBlock)
            {
                _onLocalPreviewReadyBlock();
            }
            
            [_responsedTimer stopTimer];
            [_waitcallerTimeOutTimer stopTimer];
            [_holderAcceptTimer stopTimer];
        }
            break;
        case NIMNetCallStatusDisconnect:
            //结束计时
//            [self.timer stopTimer];
            if(_connectBlock)
            {
                NSLog(@"6666666666");
                _connectBlock(ConnectState_CONNECTFAILED);
            }
            [self dismiss];
            self.chatRoom = nil;
            [_responsedTimer stopTimer];
            [_waitcallerTimeOutTimer stopTimer];
            [_holderAcceptTimer stopTimer];
            break;
        default:
            break;
    }
}

- (void)onCall:(UInt64)callID netStatus:(NIMNetCallNetStatus)status
{
     if(_netStateBlock)
     {
         _netStateBlock(callID, status);
     }
}

- (void)onHangup:(UInt64)callID
              by:(NSString *)user
{
    if (self.callInfo.callID == callID)
    {
        if(self.callInfo.immediate && _connectBlock)
        {
            if(![self shouldResponseBusy])
            {
                NSLog(@"7777777777");
                _connectBlock(ConnectState_CONNECTFAILED);
            }
        }
        [self.player stop];
        [self dismiss];
    }
}

- (void)dismiss
{
    [_holderAcceptTimer stopTimer];
    [_waitcallerTimeOutTimer stopTimer];
    [_waitResponseTimer stopTimer];
    [_waitConnectRingTimer stopTimer];
    [_responsedTimer stopTimer];
    _isWaiting = NO;
    _calleeResponsed = NO;
    _isNeedProtect = NO;
    self.chatRoom = nil;
    self.callInfo = nil;
    self.userInfo = nil;
    isVideoChatting = NO;
    if(_dismissBlock)
    {
        _dismissBlock();
    }
    [[GPUImageManager sharedInstance] freeYX];
}

- (void)onCalling
{
    if(_onCallingBlock)
    {
        _onCallingBlock();
    }
}

- (void)waitForConnectiong
{
    if(_waitForConnectiongBlock)
    {
        _waitForConnectiongBlock();
    }
}

- (void)fillUserSetting:(NIMNetCallOption *)option
{
    option.videoHandler = [GPUImageManager sharedInstance].videoHandler;
    option.preferredVideoQuality = NIMNetCallVideoQualityDefault;
    option.disableVideoCropping  = NO;
    option.autoRotateRemoteVideo = NO;
    option.serverRecordAudio     = YES;
    option.serverRecordVideo     = YES;
    option.preferredVideoEncoder = NIMNetCallVideoCodecDefault;
    option.preferredVideoDecoder = NIMNetCallVideoCodecDefault;
    option.startWithBackCamera   = ![GPUImageManager sharedInstance].isFront;
    option.autoDeactivateAudioSession = YES;
//    option.videoMaxEncodeBitrate = 600*1000;
}

- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
{
    if(_onRemoteYUVBlock)
    {
        _onRemoteYUVBlock(yuvData,width,height,user);
    }
}

- (void)onLocalPreviewReady:(CALayer *)layer
{
//    if(_onLocalPreviewReadyBlock)
//    {
//        _onLocalPreviewReadyBlock();
//    }
}

#pragma mark - M80TimerHolderDelegate
- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    WeakSelf(self);
    if(holder == self.calleeResponseTimer)
    {
        if (!_calleeResponsed)
        {
            [DLAPPDELEGATE showToastView:@"接听超时"];
            [self response:NO];
        }
    }
    else if(holder == self.responsedTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.chatRoom.count == 1) {
                [DLAPPDELEGATE showToastView:@"通话失败"];
                [weakself hangup];
            }
            if(weakself.chatRoom.count == 2 && ![weakself shouldResponseBusy])
            {
                weakself.chatRoom = nil;
                if(weakself.connectBlock)
                {
                    NSLog(@"22222222222");
                    weakself.connectBlock(ConnectState_CONNECTFAILED);
                }
                [weakself hangup];
            }
        });
    }
    else if(holder == self.waitConnectRingTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself begintoCall];
        });
    }
    
    else if(holder == self.waitResponseTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself onControl:weakself.callInfo.callID from:weakself.callInfo.callee type:NIMNetCallControlTypeFeedabck];
        });
    }
    else if(holder == self.waitcallerTimeOutTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *room = weakself.chatRoom;
            if (weakself.callInfo && room && room.count == 1) {
                [[NIMSDK sharedSDK].netCallManager hangup:weakself.callInfo.callID];
                if(weakself.callInfo.immediate)
                {
                    if(weakself.connectBlock)
                    {
                        NSLog(@"333333333333");
                        weakself.connectBlock(ConnectState_CONNECTFAILED);
                    }
                }
                else
                {
                    weakself.chatRoom = nil;
                    [weakself playTimeoutRing];
                    [DLAPPDELEGATE showToastView:@"无人接听"];
                }
                
                [weakself dismiss];
            }
        });
    }
    else if (holder == self.holderAcceptTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakself.callInfo || !weakself.isWaiting)
            {
                return;
            }
            NSMutableArray *room = [[NSMutableArray alloc] init];
            [room addObject:weakself.callInfo.caller];
            weakself.chatRoom = room;
            [weakself response:YES];
            weakself.isNeedProtect = YES;
            weakself.isWaiting = NO;
        });
    }
}

#pragma mark - Ring
//铃声 - 正在呼叫请稍后
- (void)playConnnetRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_connect_chat_tip_sender" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 对方暂时无法接听
- (void)playHangUpRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_HangUp" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 对方正在通话中
- (void)playOnCallRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_OnCall" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 对方无人接听
- (void)playTimeoutRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_onTimer" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 接收方铃声
- (void)playReceiverRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

//铃声 - 拨打方铃声
- (void)playSenderRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_sender" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

- (void)initWithCallee:(NSString *)callee
{
    self.callInfo = nil;
    self.callInfo = [[NetCallChatInfo alloc] init];
    self.callInfo.callee = callee;
    self.callInfo.caller = [[NIMSDK sharedSDK].loginManager currentAccount];
}

- (void)initWithCaller:(NSString *)caller callId:(uint64_t)callID
{
    self.callInfo = nil;
    self.callInfo = [[NetCallChatInfo alloc] init];
    self.callInfo.caller = caller;
    self.callInfo.callee = [[NIMSDK sharedSDK].loginManager currentAccount];
    self.callInfo.callID = callID;
}
@end
