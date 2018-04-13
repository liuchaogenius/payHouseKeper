//
//  PersonDetailModel.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonDetailModel : NSObject

@property (nonatomic, strong) NSString *status;//用户身份 1:主人态 2:客人态
@property (nonatomic, strong) NSString *headerImage;//头像
@property (nonatomic, strong) NSString *cornerImage;//角标
@property (nonatomic, strong) NSString *name;//名称
@property (nonatomic, strong) NSString *sex;//性别 1：男 2：女
@property (nonatomic, strong) NSString *age;//年龄
@property (nonatomic, strong) NSString *startSign; //星座

@property (nonatomic, strong) NSString *like;//点赞个数
@property (nonatomic, strong) NSString *level;//级别  如LV5

@property (nonatomic, strong) NSString *userId;//用户id
@property (nonatomic, strong) NSString *userCode;//用户Code
@property (nonatomic, strong) NSString *city;//城市
@property (nonatomic, strong) NSString *desc;//个人说明
@property (nonatomic, strong) NSString *leftBtnTitle;//左上角按钮文案
@property (nonatomic, strong) NSString *bottomBtnTitle;//左上角按钮文案


@property (nonatomic, strong) NSString *wealthLevelTitle;//财富等级标题
@property (nonatomic, strong) NSString *wealthValueTitle;//财富值标题
@property (nonatomic, strong) NSString *wealthImage;//财富logo
@property (nonatomic, strong) NSString *wealthLevel;//财富等级
@property (nonatomic, strong) NSString *wealthValue;//财富值


@property (nonatomic, strong) NSString *profitLevelTitle;//收益登记标题
@property (nonatomic, strong) NSString *profitValueTitle;//收益值标题
@property (nonatomic, strong) NSString *profitImage;//收益logo
@property (nonatomic, strong) NSString *profitLevel;//收益等级
@property (nonatomic, strong) NSString *profitValue;//收益值

@property (nonatomic, strong) NSString *charmLevelTitle;//魅力等级标题
@property (nonatomic, strong) NSString *charmValueTitle;//魅力值标题
@property (nonatomic, strong) NSString *charmImage;//魅力logo
@property (nonatomic, strong) NSString *charmLevel;//魅力等级
@property (nonatomic, strong) NSString *charmValue;//魅力值


@property (nonatomic, strong) NSString *activeLevelTitle;//活跃等级标题
@property (nonatomic, strong) NSString *activeValueTitle;//活跃值标题
@property (nonatomic, strong) NSString *activeImage;//活跃logo
@property (nonatomic, strong) NSString *activeLevel;//活跃等级
@property (nonatomic, strong) NSString *activeValue;//活跃值

@property (nonatomic, assign) BOOL defriend;//是否被拉黑


- (void)unPackeDict:(NSDictionary *)aDict;
- (NSDictionary *)pakcePersonDetailDict;
@end
