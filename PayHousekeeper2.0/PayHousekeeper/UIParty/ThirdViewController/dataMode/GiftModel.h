//
//  GiftModel.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftModel : NSObject
@property (nonatomic, readonly) NSString *strID;            //礼物id
@property (nonatomic, readonly) NSString *name;             //礼物名称
@property (nonatomic, readonly) NSString *price;            //咚币价格
@property (nonatomic, readonly) NSString *seconds;          //增加时间（秒）
@property (nonatomic, readonly) NSString *type;             //类型：0、全部；1、男；2、女
@property (nonatomic, readonly) NSString *isvip;            //是否vip特有 ，0vip持有，1非vip持有
@property (nonatomic, readonly) NSString *icon;             //礼物图片url地址
@property (nonatomic, readonly) NSString *effect;           //礼物动效url地址

- (void)unPakceGiftInfoDict:(NSDictionary *)aDict;
- (NSDictionary *)pakceGiftInfoDict;
@end
