//
//  WXPayService.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/6.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "WXPayService.h"
#import "NetManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "WXApiObject.h"
#import "WXApi.h"
#import "AppDelegate.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation WXPayOrderData

- (void)unPacketWXPayOrderData:(NSDictionary *)aDict
{
    AssignMentID(self.prepayId, [aDict objectForKey:@"prepayId"]);
    AssignMentID(self.appId, [aDict objectForKey:@"appId"]);
    AssignMentID(self.nonceStr, [aDict objectForKey:@"nonceStr"]);
    AssignMentID(self.packageValue, [aDict objectForKey:@"packageValue"]);
    AssignMentID(self.partnerId, [aDict objectForKey:@"partnerId"]);
    AssignMentID(self.timeStamp, [aDict objectForKey:@"timeStamp"]);
    AssignMentID(self.sign, [aDict objectForKey:@"sign"]);
}

@end

@implementation WXPayService
+ (WXPayService *)shareWXPayService
{
    static WXPayService *payservice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payservice = [[WXPayService alloc] init];
    });
    return payservice;
}
- (void)requestWXPayOrderItemId:(NSString *)aItemid //商品id
                   amount:(NSString *)aAmount //购买个数
                     type:(NSString *)aType //类型，1 购买 2赠送
            completeBlock:(void(^)(WXpayResultType ret))aBlock
{
    self.payResultBlock = aBlock;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:aItemid forKey:@"itemId"];
    [dict setObject:aAmount forKey:@"amount"];
    [dict setObject:aType forKey:@"type"];
    NSString *strIpaddress = [self getIPAddress:YES];
    if(strIpaddress)
    {
        [dict setObject:strIpaddress forKey:@"userIp"];
    }
    [NetManager requestWith:dict apiName:kGetWXPayInfoAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            WXPayOrderData *data = [[WXPayOrderData alloc] init];
            [data unPacketWXPayOrderData:successDict];
            [self WXPay:data];
        }
        else
        {
            aBlock(WXPay_fail);
            self.payResultBlock = nil;
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        aBlock(WXPay_fail);
        self.payResultBlock = nil;
    }];
}

- (void)WXPay:(WXPayOrderData *)aData
{
    //需要创建这个支付对象
    PayReq *req   = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = @"";
    
    // 商家id，在注册的时候给的
    req.partnerId = aData.partnerId;
    
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId  = aData.prepayId;
    
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package   = aData.packageValue;
    
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr  = aData.nonceStr;
    
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp = aData.timeStamp;
    req.timeStamp = stamp.intValue;
    
    // 这个签名也是后台做的
    req.sign = aData.sign;
    
    //设置微信处理handeurl
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    del.loginType = payOrderType_WX;
    //发送请求到微信，等待微信返回onResp
    self.strPrepayId = aData.prepayId;
    [WXApi sendReq:req];
}

- (void)requestWXPayVerify:(void(^)(NSString *tradeState, NSString *out_trade_no,int ret))aBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    if(self.strPrepayId)
    {
        [dict setObject:self.strPrepayId forKey:@"prepayId"];
    }
    [NetManager requestWith:dict apiName:kGetWXVerifyAPI method:kPost timeOutInterval:20 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            int tradeState = [[successDict objectForKey:@"tradeState"] intValue];
            aBlock([successDict objectForKey:@"tradeState"],[successDict objectForKey:@"out_trade_no"],1);
            if(tradeState==2021 || tradeState==2022)
            {
                if(self.payResultBlock)
                {
                    self.payResultBlock(WXPay_fail);
                    self.payResultBlock = nil;
                }
            }
            else
            {
                if(self.payResultBlock)
                {
                    self.payResultBlock(WXPay_success);
                    self.payResultBlock = nil;
                }
            }

        }
        else
        {
            if(self.payResultBlock)
            {
                self.payResultBlock(WXPay_fail);
                self.payResultBlock = nil;
            }
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        if(self.payResultBlock)
        {
            self.payResultBlock(WXPay_fail);
            self.payResultBlock = nil;
        }
    }];
}

//获取ip地址
- (NSString *)getIPAddress:(BOOL)preferIPv4
{
//    NSArray *searchArray = preferIPv4 ?
//    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
//    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    MLOG(@"addresses: %@", addresses);
    NSString *address = [addresses objectForKey:@"pdp_ip0/ipv4"];
//    __block NSString *address;
//    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
//     {
//         address = addresses[key];
//         if(address) *stop = YES;
//     } ];
    return address ? address : @"0.0.0.0";
}
- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
