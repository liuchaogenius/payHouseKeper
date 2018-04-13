//
//  BindListData.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BindListData.h"

@implementation BindData

- (void)unPacketData:(NSDictionary *)aDict
{
    AssignMentID(self.openid, [aDict objectForKey:@"openId"]);
    AssignMentID(self.nickName, [aDict objectForKey:@"nickName"]);
    AssignMentNSNumber(self.type, [aDict objectForKey:@"type"]);
    AssignMentID(self.typeName, [aDict objectForKey:@"typeName"]);
}

@end

@implementation BindListData
- (void)unPacketDatalist:(NSArray<NSDictionary *>*)aArryDict
{
    if(!self.dataArry)
    {
        self.dataArry = [NSMutableArray arrayWithCapacity:0];
    }
    if(aArryDict)
    {
        for(NSDictionary *dict in aArryDict)
        {
            BindData *data = [BindData new];
            [data unPacketData:dict];
            [self.dataArry addObject:data];
            if (data.type ==3)
            {
                self.phoneNO = data.openid;
            }else if (data.type == 1)
            {
                self.wechat = data.nickName;
            }
            else if (data.type == 2)
            {
                self.weibo = data.nickName;
            }
            else if (data.type == 0)
            {
                self.qq = data.nickName;
            }
        }
    }
}
@end
