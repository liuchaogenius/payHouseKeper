//
//  DDSystemInfoManager.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/20.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BroadcastModel.h"
#import "GiftModel.h"


#define GiftDocumentPath [DocumentPath stringByAppendingPathComponent:@"Gift"]

#define Tip4Gradient   @"Tip4Gradient"
#define Tip4Report     @"Tip4Report"
#define Tip4Blur       @"Tip4Blur"
#define Tip4Switch     @"Tip4Switch"


typedef void (^DownLoadFinished)();

@interface DDSystemInfoManager : NSObject

@property (nonatomic,strong)   NSMutableArray  *timeArr;//允许时间段
@property (atomic,strong)   NSMutableArray  *broadcastArr;//广播消息
@property (nonatomic,strong)   NSMutableArray  *allAvaterArr;//随机头像
@property (nonatomic,strong)   NSMutableArray  *manAvaterArr;//男随机头像
@property (nonatomic,strong)   NSMutableArray  *femalAvaterArr;//女随机头像

@property (nonatomic,strong)   NSMutableArray  *giftsArr;//礼物
@property (nonatomic,strong)   NSMutableDictionary  *picUrlDic;
@property (copy)               DownLoadFinished downloadFinishBlock;
@property (nonatomic,assign)   BOOL    isOn;
@property (nonatomic,strong)   NSString  *supportPayType;//1:苹果支付  2、微信支付+支付宝支付   3、苹果支付+微信支付+支付宝支付
@property (nonatomic,strong)   NSMutableDictionary  *downloadZipDic;

+ (DDSystemInfoManager *)sharedInstance;

//获取匹配时间信息
//- (void)getMacthTimeInfo;

//获取广播信息
- (void)getBroadcastInfo;

//获取随机头像信息
- (void)getRandAvatarInfo;

//获取礼物信息
- (void)getGiftsInfo;

//下载礼物动效包
- (void)downloadGiftZip:(GiftModel *)model;

//礼物包是否存在
- (BOOL)checkPath:(NSString *)path isCreaet:(BOOL)isCreate;

//获取开关
- (void)getSwitchInfo;

//取消缓存图片
- (void)cancelDownloadPic;

//取消缓存礼物
- (void)cancelDownloadGift;

//开启广播定时器
- (void)startBroadcastTimer;

//关闭广播定时器
- (void)stopBroadcastTimer;

//是否需要显示提示
- (BOOL)shouldShowTip:(NSString *)key;

//设置提示开关
- (void)setShowTipValue:(BOOL)flag key:(NSString *)key;


- (BOOL)isOKTime;

- (BOOL)isOKTime4Lab;
@end
