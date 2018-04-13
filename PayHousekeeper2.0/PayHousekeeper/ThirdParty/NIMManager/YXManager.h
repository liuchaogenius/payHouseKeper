//
//  YXManager.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMKit.h"
#import "NIMRecentSession.h"
#import "NIMSDK.h"
#import "NIMAVChat.h"
#import "UserInfoData.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "DDFriendsInfoManager.h"
#import "NTESBundleSetting.h"
#import <AVFoundation/AVFoundation.h>
#import "OtherUserInfoData.h"
#import "NetCallChatInfo.h"

#define NIMAPPKEY @"adbe344fb196dee48f4f1aae72f56bee"
#define NIMCERNAME @"devDD"

#define NTESNotifyID        @"id"
#define NTESCustomData      @"data"

#define NTESPresentGift     (1000)
#define NTESPresentDressup  (1001)
#define NTESRoserChange     (1002)
#define NTESSendLike        (1003)

#define CONCERN_MSG_ADD @"add_concern"
#define CONCERN_MSG_DELETE @"delete_concern"

typedef NS_ENUM(NSInteger, ConnectState)
{
    ConnectState_CONNECTED = 1000,                                //视频连接成功
    ConnectState_HANGUP_BYUSER = 1001,                            //视频中用户挂断
    ConnectState_HANGUP_BYTIMER = 1002,                           //聊天时间到
    ConnectState_CONNECTFAILED = 1003,                            //视频连接被拒
};

static const NSInteger MaxNotificationCount = 20;

typedef void (^RefreshConversationList)();
typedef void (^RefreshContactsList)();
typedef void (^RefreshSysMessList)();
typedef void (^CallLife)();
typedef void (^ConnectBlock)(ConnectState state);
typedef void (^ImmediateBlock)(OtherUserInfoData *userInfo);
typedef void (^OnRemoteYUV)(NSData *yuvData, NSUInteger width, NSUInteger height, NSString *user);
typedef void (^CustomSystemNotification)(NIMCustomSystemNotification *notification);
typedef void (^NetStateBlock)(UInt64 callID, NIMNetCallNetStatus status);

@interface YXManager : NSObject
@property (nonatomic,readonly) NSMutableArray *recentSessions;//最近会话集合
//@property (nonatomic,readonly) NSMutableArray *myFriends;//好友列表
//@property (nonatomic,strong)   NSMutableArray *notifications;//验证消息集合

@property (nonatomic,strong) NetCallChatInfo *callInfo;

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音

@property (nonatomic,assign) BOOL isUserHangup;

/**
 *  blocks
 */
@property (copy)               RefreshConversationList refreshConList;//刷新回话列表
@property (copy)               RefreshContactsList refreshContact;//刷新回话列表
@property (copy)               RefreshSysMessList  refreshSysMess;//刷新系统消息列表

/**
 *  Call Life blocks
 */
@property (copy)               CallLife  startByCallerBlock;
@property (copy)               CallLife  startByCalleeBlock;
@property (copy)               CallLife  onCallingBlock;
@property (copy)               CallLife  waitForConnectiongBlock;
@property (copy)               CallLife  dismissBlock;
@property (copy)               CallLife  onLocalPreviewReadyBlock;
@property (copy)               CustomSystemNotification  onReceiveCustomSystemNotificationBlock;
@property (copy)               ConnectBlock  connectBlock;
@property (copy)               ImmediateBlock  immediateBlock;
@property (copy)               OnRemoteYUV  onRemoteYUVBlock;
@property (copy)               NetStateBlock  netStateBlock;


+ (YXManager *)sharedInstance;

/**
 *  更新APNS Token
 *
 *  @param token APNS Token
 */
- (void)updateApnsToken:(NSData *)token;

/**
 *  登录
 */
- (void)yxLogin:(UserInfoData *)user;
/**
 *  自动登录
 */
- (void)yxAutoLogin;
/**
 *  退出登录
 */
- (void)yxLogout:(void(^)(NSError *err))completion;

/**
 *  根据session获取信息
 */
- (NIMKitInfo *)getInfoBySession:(NIMRecentSession *)session;

/**
 *  根据userId获取信息
 */
- (NIMKitInfo *)getInfoByUserId:(NSString *)userId;

/**
 *  根据session获取消息内容
 */
- (NSString *)getContentForRecentSession:(NIMRecentSession *)session;

/**
 *  根据session delete
 */
- (void)deleteRecentSession:(NIMRecentSession *)session;

/**
 *  添加好友
 */
- (void)addFriend:(NSString *)userID isForced:(BOOL)isForced;

/**
 *  删除好友
 */
- (void)deleteFriend:(NSString *)userID;

/**
 *  标记所有系统消息为已读
 */
- (void)markAllNotificationsAsRead;

/**
 *  加载更多系统消息
 */
- (void)loadMoreSysMess;

/**
 *  获取所有未读数
 */
- (NSInteger)getAllUnreadCount;

/**
 *  发送自定义通知
 */
- (void)sendCustomSystemNotification:(NSDictionary *)dic toSessionID:(NSString *)sessionID sendToOnlineUsersOnly:(BOOL)sendToOnlineUsersOnly;



//主叫方是自己，发起通话，初始化方法
- (void)initWithCallee:(NSString *)callee;
//被叫方是自己，接听界面，初始化方法
- (void)initWithCaller:(NSString *)caller
                        callId:(uint64_t)callID;


//主叫方开始界面回调
- (void)startByCaller:(BOOL)immediate;
//被叫方开始界面回调
- (void)startByCallee;
//同意后正在进入聊天界面
- (void)waitForConnectiong;
//双方开始通话
- (void)onCalling;
//挂断
- (void)hangup;
//接受/拒接通话
- (void)response:(BOOL)accept;
//开启关闭摄像头
- (void)disableCammera:(BOOL)isDisableCammera;
//切换视频质量
- (void)switchVideoQuality:(NIMNetCallVideoQuality)videoQuality;

#pragma mark - Ring
//铃声 - 正在呼叫请稍后
- (void)playConnnetRing;
//铃声 - 对方暂时无法接听
- (void)playHangUpRing;
//铃声 - 对方正在通话中
- (void)playOnCallRing;
//铃声 - 对方无人接听
- (void)playTimeoutRing;
//铃声 - 接收方铃声
- (void)playReceiverRing;
//铃声 - 拨打方铃声
- (void)playSenderRing;

- (void)onCall:(UInt64)callID status:(NIMNetCallStatus)status;
@end
