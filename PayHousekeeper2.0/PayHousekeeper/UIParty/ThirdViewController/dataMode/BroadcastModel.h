//
//  BroadcastModel.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/20.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BroadcastModel : NSObject
@property (nonatomic, readonly) NSString *content;              //消息内容，系统消息作为消息内容，礼物消息作为礼物名称
@property (nonatomic, readonly) NSString *type;                 //消息类型 0系统通知  1礼物通知
@property (nonatomic, readonly) NSString *sendPic;              //发送人头像,系统通知为空
@property (nonatomic, readonly) NSString *senderId;             //发送人accid，系统通知为空
@property (nonatomic, readonly) NSString *sender;               //发送人昵称，系统通知为空
@property (nonatomic, readonly) NSString *receiver;             //接收人昵称，系统通知为空
@property (nonatomic, readonly) NSString *receiverId;           //接收人accid，系统通知为空
@property (nonatomic, readonly) NSString *receiverPic;          //接收人头像，系统通知为空
@property (nonatomic, readonly) NSString *giftPic;              //礼物图片，系统通知为空
@property (nonatomic, readonly) NSString *effect;               //对应效果，系统通知为空

- (void)unPakceBroadcastInfoDict:(NSDictionary *)aDict;

@end
