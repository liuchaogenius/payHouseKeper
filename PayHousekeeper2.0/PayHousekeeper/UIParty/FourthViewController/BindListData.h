//
//  BindListData.h
//  PayHousekeeper
//
//  Created by 1 on 2016/12/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BindData : NSObject
@property (nonatomic, strong)NSString *openid;
@property (nonatomic, strong)NSString *nickName;
@property (nonatomic)int type;//0=qq,1=微信 , 2=新浪微博,3=手机用户
@property (nonatomic, strong)NSString *typeName;
@end

@interface BindListData : NSObject
@property (nonatomic, strong)NSMutableArray *dataArry;
@property (nonatomic, strong)NSString *phoneNO;
@property (nonatomic, strong)NSString *wechat;
@property (nonatomic, strong)NSString *weibo;
@property (nonatomic, strong)NSString *qq;
- (void)unPacketDatalist:(NSArray<NSDictionary *>*)aArryDict;

@end
