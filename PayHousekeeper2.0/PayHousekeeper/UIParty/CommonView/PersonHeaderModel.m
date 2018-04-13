//
//  PersonHeaderModel.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonHeaderModel.h"

@implementation PersonHeaderModel
- (void)unPackeDict:(NSDictionary *)aDict
{
    _status = [aDict objectForKey:@"status"];
    _headerImage = [aDict objectForKey:@"headerImage"];
    _cornerImage = [aDict objectForKey:@"cornerImage"];
    _name = [aDict objectForKey:@"name"]?[aDict objectForKey:@"name"]:@" ";
    _like = [aDict objectForKey:@"like"];
    _stone = [aDict objectForKey:@"stone"];
    _desc = [aDict objectForKey:@"desc"];
    _placeHolder = [aDict objectForKey:@"placeHolder"];
}

- (NSDictionary *)pakcePersonHeadeDict
{
    NSDictionary *dic = @{@"status":_status,
                          @"headerImage":_headerImage,
                          @"cornerImage":_cornerImage,
                          @"name":_name,
                          @"like":_like,
                          @"stone":_stone,
                          @"desc":_desc
                          };
    return dic;
}

- (void)unPackeDictFromOtherUserInfo:(OtherUserInfoData *)model
{
    _status = [model.strUserId isEqualToString:[UserInfoData shareUserInfoData].strUserId]?@"1":@"2";
    _headerImage = model.strHeadUrl;
    _cornerImage = model.isVip?@"VIPIMG":@"";
    _name = model.strUserNick?model.strUserNick:@" ";
    _like = [NSString stringWithFormat:@" %d", model.charmlevel];
    _stone = [NSString stringWithFormat:@" %d", model.wealthlevel];
    if (![model.strUserMsg isEqualToString:@"(null)"])
    {
        _desc = model.strUserMsg;
    }
    
    _placeHolder = @"把你的心情写在这里吧";
}

- (void)unPackeDictFromUserInfo:(UserInfoData *)model
{
    _status = [model.strUserId isEqualToString:[UserInfoData shareUserInfoData].strUserId]?@"1":@"2";
    _headerImage = model.strHeadUrl;
    _cornerImage = model.isVip?@"VIPIMG":@"";
    _name = model.strUserNick?model.strUserNick:@" ";
    _like = [NSString stringWithFormat:@" %d", model.charmlevel];
    _stone = [NSString stringWithFormat:@" %d", model.wealthlevel];
    if (![model.strUserMsg isEqualToString:@"(null)"])
    {
        _desc = model.strUserMsg;
    }
    
    _placeHolder = @"把你的心情写在这里吧";
}
@end
