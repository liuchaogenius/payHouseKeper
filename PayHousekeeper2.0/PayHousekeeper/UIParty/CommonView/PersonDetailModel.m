//
//  PersonDetailModel.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonDetailModel.h"

@implementation PersonDetailModel

- (void)unPackeDict:(NSDictionary *)aDict
{
    _status = [[aDict objectForKey:@"accid"] isEqualToString:[UserInfoData shareUserInfoData].strUserId]?@"1":@"2";
    _headerImage = [aDict objectForKey:@"avatar"];//[aDict objectForKey:@"headerImage"];
    _cornerImage = [[aDict objectForKey:@"vip"] boolValue]?@"VIPIMG":@"";//[aDict objectForKey:@"cornerImage"];
    _name = [aDict objectForKey:@"nickName"];//[aDict objectForKey:@"name"];
    _age = [aDict objectForKey:@"age"];
    NSString *gender =[NSString stringWithFormat:@"%@",[aDict objectForKey:@"gender"]];
    if ([gender  isEqualToString:@"F"])
    {
        _sex = @"2";
    }
    else
    {
        _sex = @"1";
    }
    _startSign = [aDict objectForKey:@"constellation"];//[aDict objectForKey:@"startSign"];
     _like = [aDict objectForKey:@"like"];
    _level = [aDict objectForKey:@"level"];
    _userId = [aDict objectForKey:@"accid"];
    _city = [[aDict objectForKey:@"place"]length]>0?[aDict objectForKey:@"place"]:@"火星";
    _desc = [aDict objectForKey:@"userSign"];//[aDict objectForKey:@"desc"];
    _userCode = [aDict objectForKey:@"userCode"];
    
    _wealthLevelTitle = @"财富等级";//[aDict objectForKey:@"wealthTitle"];
    _wealthValueTitle = @"财富值";//[aDict objectForKey:@"wealthTitle"];
    _wealthImage = @"wealth_icon";//[aDict objectForKey:@"wealthImage"];
    _wealthLevel = [NSString stringWithFormat:@"Lv%@",[aDict objectForKey:@"wealthLevel"]];
    _wealthValue = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"wealthVal"]];
    
    
    _profitLevelTitle = @"收益等级";//[aDict objectForKey:@"profitTitle"];
    _profitValueTitle = @"收益值";
    _profitImage = [aDict objectForKey:@"profitImage"];
    _profitLevel = [NSString stringWithFormat:@"Lv%@",[aDict objectForKey:@"profitLevel"]];
    _profitValue = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"profitVal"]];
    
    
    _charmLevelTitle = @"魅力等级";//[aDict objectForKey:@"charmTitle"];
    _charmValueTitle = @"魅力值";//[aDict objectForKey:@"charmTitle"];
    
    _charmImage = @"meili";//[aDict objectForKey:@"charmImage"];
    _charmLevel = [NSString stringWithFormat:@"Lv%@",[aDict objectForKey:@"charmLevel"]];
    _charmValue = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"charmVal"]];
    
    _activeLevelTitle = @"活跃等级";//[aDict objectForKey:@"activeTitle"];
    _activeValueTitle = @"活跃值";//[aDict objectForKey:@"activeTitle"];
    _activeImage = @"huoyue";// [aDict objectForKey:@"activeImage"];
    _activeLevel = [NSString stringWithFormat:@"Lv%@",[aDict objectForKey:@"activeLevel"]];
    _activeValue = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"activeVal"]];
    
    if([_status intValue] == 2)
        _leftBtnTitle = @"举报";
    
    _defriend = [[aDict objectForKey:@"defriend"] boolValue];
}
- (NSDictionary *)pakcePersonDetailDict
{
    NSDictionary *dic = @{@"status":_status,
                          @"headerImage":_headerImage,
                          @"cornerImage":_cornerImage,
                          @"name":_name,
                          @"sex":_sex,
                          @"startSign":_startSign,
                          @"like":_like,
                          @"level":_level,
                          @"userId":_userId,
                          @"desc":_desc,
                          };
    return dic;
}

@end
