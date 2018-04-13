//
//  PersonHeaderModel.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OtherUserInfoData.h"
#import "UserInfoData.h"


@interface PersonHeaderModel : NSObject

@property (nonatomic, strong) NSString *status;//用户身份 1:主人态 2:客人态
@property (nonatomic, strong) NSString *headerImage;//头像
@property (nonatomic, strong) NSString *cornerImage;//角标
@property (nonatomic, strong) NSString *name;//名称
@property (nonatomic, strong) NSString *like;//点赞个数
@property (nonatomic, strong) NSString *stone;//宝石个数
@property (nonatomic, strong) NSString *desc;//心情描述文案
@property (nonatomic, strong) NSString *placeHolder;//心情占位文案

- (void)unPackeDict:(NSDictionary *)aDict;
- (NSDictionary *)pakcePersonHeadeDict;
- (void)unPackeDictFromOtherUserInfo:(OtherUserInfoData *)model;
- (void)unPackeDictFromUserInfo:(UserInfoData *)model;
@end
