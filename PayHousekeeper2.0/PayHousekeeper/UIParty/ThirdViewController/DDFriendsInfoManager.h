//
//  DDFriendsInfoManager.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsModel.h"

#define RosterInfoChangedNotification @"RosterInfoChangedNotification"

@interface DDFriendsInfoManager : NSObject

@property (atomic,strong)   NSMutableArray  *myAttentionsArr; //我的关注
@property (atomic,strong)   NSMutableArray  *myFansArr;       //我的粉丝
@property (atomic,strong)   NSMutableArray  *myFriendsArr;    //我的好友

+ (DDFriendsInfoManager *)sharedInstance;

//获取我的关注
- (void)getMyAttentionInfo;

//获取我的粉丝
- (void)getMyFansInfo;

//获取我的好友
- (void)getMyFriendsInfo;

//添加关注
- (void)requestAddAttentionID:(NSString *)friendid
                        accid:(NSString *)accid
                completeBlock:(void(^)(BOOL ret))aBlock;

//取消关注
- (void)requestRemoveAttentionID:(NSString *)friendid
                           accid:(NSString *)accid
                   completeBlock:(void(^)(BOOL ret))aBlock;

//是否关注
- (BOOL)isAttentioned:(NSString *)userID;

//获取好友备注，若陌生人返回nil
- (FriendsModel *)getFriendInfo:(NSString *)userID;

//判断是否是好友
- (BOOL)isMyFriend:(NSString *)userID;

//获取用户信息
- (void)requestUserInfoUserId:(NSString *)userid
                        accid:(NSString *)accid
                completeBlock:(void(^)(NSDictionary *data))aBlock;

@end
