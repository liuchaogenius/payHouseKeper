//
//  WBLoginService.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/4.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

@interface WBLoginService : NSObject<WBHttpRequestDelegate>
+ (WBLoginService *)shareWBLoginService;
- (void)requestLogin:(WBBaseResponse *)aParam complete:(void(^)(int ret))aBlock;
@end
