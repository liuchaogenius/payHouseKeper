//
//  LocationManager.h
//  PayHousekeeper
//
//  Created by liuguangren on 2017/1/9.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject
@property(nonatomic, strong) NSString       *latitude;      //纬度
@property(nonatomic, strong) NSString       *longitude;     //经度
@property(nonatomic, strong) NSString       *city;          //城市名

+ (LocationManager *)sharedInstance;

- (void)start;
@end
