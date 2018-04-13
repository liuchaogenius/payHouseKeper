//
//  DDFriendsInfoManager.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "DDFriendsInfoManager.h"
#import "ChineseToPinyin.h"

@interface DDFriendsInfoManager() <NIMSystemNotificationManagerDelegate>
{
    
}

@end
@implementation DDFriendsInfoManager

#pragma mark 初始化方法
- (id)init
{
    self=[super init];
    if(self)
    {
        _myFansArr = [NSMutableArray array];
        _myAttentionsArr = [NSMutableArray array];
        _myFriendsArr = [NSMutableArray array];
    }
    return self;
}

+ (DDFriendsInfoManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DDFriendsInfoManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[DDFriendsInfoManager alloc] init];
    });
    return sSharedInstance;
}

//获取我的关注
- (void)getMyAttentionInfo
{
    WeakSelf(self)
    [NetManager requestWith:@{@"accid":[UserInfoData shareUserInfoData].strUserId,
                              @"type":@"concern"}
                    apiName:kGetFansAndAttentionAPI method:KGet timeOutInterval:15 succ:^(NSDictionary *successDict) {
        [weakself.myAttentionsArr removeAllObjects];
        NSArray *tmpArr = [successDict objectForKey:@"data"];
        if(tmpArr && tmpArr.count > 0)
        {
            for(NSDictionary *dic in tmpArr)
            {
                FriendsModel *model = [[FriendsModel alloc] init];
                [model unPakceFriendsInfoDict:dic];
                [weakself.myAttentionsArr addObject:model];
            }
            [weakself notifyRoserInfoUpdate];
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

//获取我的粉丝
- (void)getMyFansInfo
{
    WeakSelf(self)
    [NetManager requestWith:@{@"accid":[UserInfoData shareUserInfoData].strUserId,
                              @"type":@"fans"}
                    apiName:kGetFansAndAttentionAPI method:KGet timeOutInterval:15 succ:^(NSDictionary *successDict) {
        [weakself.myFansArr removeAllObjects];
        NSArray *tmpArr = [successDict objectForKey:@"data"];
        for(NSDictionary *dic in tmpArr)
        {
            FriendsModel *model = [[FriendsModel alloc] init];
            [model unPakceFriendsInfoDict:dic];
            [weakself.myFansArr addObject:model];
        }
        [weakself notifyRoserInfoUpdate];
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

//获取我的好友
- (void)getMyFriendsInfo
{
    WeakSelf(self)
    [NetManager requestWith:@{@"accid":[UserInfoData shareUserInfoData].strUserId}
                    apiName:kGetFriendsAPI method:KGet timeOutInterval:15 succ:^(NSDictionary *successDict) {
        [weakself.myFriendsArr removeAllObjects];
        NSArray *tmpArr = [[successDict objectForKey:@"data"] objectForKey:@"rosters"];
        if(tmpArr && tmpArr.count > 0)
        {
            for(NSDictionary *dic in tmpArr)
            {
                FriendsModel *model = [[FriendsModel alloc] init];
                [model unPakceFriendsInfoDict:dic];
                [weakself.myFriendsArr addObject:model];
            }
            [weakself notifyRoserInfoUpdate];
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

//添加关注
- (void)requestAddAttentionID:(NSString *)friendid
                        accid:(NSString *)accid
                completeBlock:(void(^)(BOOL ret))aBlock
{
    WeakSelf(self)
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:accid forKey:@"accid"];
    [dict setObject:friendid forKey:@"friendId"];
    [NetManager requestWith:dict apiName:kAddRosterAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        NSDictionary *dic = @{NTESNotifyID : @(NTESRoserChange),
                               NTESCustomData:CONCERN_MSG_ADD};
        [[YXManager sharedInstance] sendCustomSystemNotification:dic toSessionID:friendid sendToOnlineUsersOnly:NO];
        [weakself getMyAttentionInfo];
        [weakself getMyFriendsInfo];
        [weakself getMyFansInfo];
        
        if(aBlock)
            aBlock(YES);
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(NO);
    }];
}

//取消关注
- (void)requestRemoveAttentionID:(NSString *)friendid
                           accid:(NSString *)accid
                   completeBlock:(void(^)(BOOL ret))aBlock
{
    WeakSelf(self)
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:accid forKey:@"accid"];
    [dict setObject:friendid forKey:@"friendId"];
    
    [NetManager requestWith:dict apiName:kRemoveRosterAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        NSDictionary *dic = @{NTESNotifyID : @(NTESRoserChange),
                              NTESCustomData:CONCERN_MSG_DELETE};
        [[YXManager sharedInstance] sendCustomSystemNotification:dic toSessionID:friendid sendToOnlineUsersOnly:NO];
        for(FriendsModel *model in _myFriendsArr)
        {
            if([model.friendId isEqualToString:friendid])
            {
                [_myAttentionsArr addObject:model];
                [_myFriendsArr removeObject:model];
                break;
            }
        }
        
        [weakself getMyAttentionInfo];
        [weakself getMyFriendsInfo];
        [weakself getMyFansInfo];
        
        if(aBlock)
            aBlock(YES);
    } failure:^(NSDictionary *failDict, NSError *error) {
        if(aBlock)
            aBlock(NO);
    }];
}

//是否关注
- (BOOL)isAttentioned:(NSString *)userID
{
    if([self isMyFriend:userID])
        return YES;
    
    BOOL isAttentioned = NO;
    for(FriendsModel *model in _myAttentionsArr)
    {
        if([model.friendId isEqualToString:userID])
            return YES;
    }
    return isAttentioned;
}

//获取好友备注，若陌生人返回nil
- (FriendsModel *)getFriendInfo:(NSString *)userID
{
    FriendsModel *user = nil;
    for(FriendsModel *model in _myFriendsArr)
    {
        if([model.friendId isEqualToString:userID])
            return model;
    }
    for(FriendsModel *model in _myFansArr)
    {
        if([model.friendId isEqualToString:userID])
            return model;
    }
    for(FriendsModel *model in _myAttentionsArr)
    {
        if([model.friendId isEqualToString:userID])
            return model;
    }
    return user;
}

//判断是否是好友
- (BOOL)isMyFriend:(NSString *)userID
{
    for(FriendsModel *model in _myFriendsArr)
    {
        if([model.friendId isEqualToString:userID])
            return YES;
    }
    return NO;
}

//获取用户信息
- (void)requestUserInfoUserId:(NSString *)userid
                        accid:(NSString *)accid
                completeBlock:(void(^)(NSDictionary *dataDic))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"userid"];
    [dict setObject:accid forKey:@"accid"];
    [NetManager requestWith:dict apiName:kGetUserInfo method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        aBlock(successDict);
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(nil);
    }];
}

//通知关系变更
- (void)notifyRoserInfoUpdate
{
    [self sortArrs];
    [[NSNotificationCenter defaultCenter] postNotificationName:RosterInfoChangedNotification object:nil];
}

- (void)sortArrs
{
    NSArray *tmpArr = [NSArray arrayWithArray:[self sortDataArray:_myFansArr]];
    [_myFansArr removeAllObjects];
    [_myFansArr addObjectsFromArray:tmpArr];
    
    tmpArr = [NSArray arrayWithArray:[self sortDataArray:_myAttentionsArr]];
    [_myAttentionsArr removeAllObjects];
    [_myAttentionsArr addObjectsFromArray:tmpArr];
    
    tmpArr = [NSArray arrayWithArray:[self sortDataArray:_myFriendsArr]];
    [_myFriendsArr removeAllObjects];
    [_myFriendsArr addObjectsFromArray:tmpArr];
}

- (NSArray *)sortDataArray:(NSArray *)dataArray
{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:dataArray];
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(FriendsModel *obj1, FriendsModel *obj2) {
        
        NSString *s1 = [ChineseToPinyin pinyinFromChineseString:obj1.nickName];
        NSString *s2 = [ChineseToPinyin pinyinFromChineseString:obj2.nickName];
        NSComparisonResult result = [s1 compare:s2];
        
        return result == NSOrderedDescending; // 升序
        //        return result == NSOrderedAscending;  // 降序
    }];
    
    return sortedArray;
}

@end
