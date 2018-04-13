//
//  InviateData.h
//  PayHousekeeper
//
//  Created by 1 on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriListInvite : NSObject
@property (nonatomic, strong)NSString *accid;
@property (nonatomic, strong)NSString *nickname;
@property (nonatomic, strong)NSString *headUrl;
- (void)unpacketData:(NSDictionary *)aDict;
@end

@interface InviateData : NSObject
@property (nonatomic, strong)NSString *inviteCode;//邀请码
@property (nonatomic)CGFloat income; //收益
@property (nonatomic, strong)NSMutableArray<FriListInvite *> *frilist;//好友list
- (void)unpacketData:(NSDictionary *)aDict;
@end
