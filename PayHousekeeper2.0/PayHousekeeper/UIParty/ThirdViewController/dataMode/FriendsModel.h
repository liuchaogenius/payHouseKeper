//
//  FriendsModel.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsModel : NSObject

@property (nonatomic, readonly) NSString *friendId;              //好友id
@property (nonatomic, readonly) NSString *remarks;               //好友备注
@property (nonatomic, readonly) NSString *nickName;              //好友昵称
@property (nonatomic, readonly) NSString *avatar;                //好友头像
@property (nonatomic, readonly) NSString *gender;                //好友性别
@property (nonatomic, readonly) NSString *userSign;              //用户签名
@property (nonatomic, readonly, assign) BOOL     isVip;                  //是否会员

- (void)unPakceFriendsInfoDict:(NSDictionary *)aDict;

@end
