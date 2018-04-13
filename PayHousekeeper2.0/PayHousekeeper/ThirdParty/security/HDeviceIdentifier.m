//
//  HDeviceIdentifier.m
//  HDeviceIdentifier
//
//  Created by striveliu 16/4/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "HDeviceIdentifier.h"
#import "SFHFKeychainUtils.h"


#define bundleIdentifier [[NSBundle mainBundle]bundleIdentifier]

@implementation HDeviceIdentifier

/**
 *  同步唯一设备标识 (生成并保存唯一设备标识,如已存在则不进行任何处理)
 *
 *  @return 是否成功
 */
+(BOOL)syncDeviceIdentifier:(NSString *)aUUID
{
    
    /**
     *  获取应用的UUID标识
     *  (
     *  identifierForVendor返回本应用的UUID, 卸载重装后会变.所以要存入钥匙串
     *  此处可用 [[NSUUID UUID]UUIDString] 代替, [NSUUID UUID]方法每次调用都会生成一个不同的UUID
     *  但是identifierForVendor可以用来验证是不是第一次安装
     *  )
     */
//    NSString *myUUIDStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    /**
     *  保存UUID到钥匙串Keychain, 如果已存在则不保存
     *  storeUsername:键
     *  Password:值
     *  ServiceName:组名
     *  updateExisting:更新已存在的
     */
    BOOL f = [SFHFKeychainUtils storeUsername:@"deviceIdentifiermoqu" andPassword:aUUID forServiceName:bundleIdentifier updateExisting:NO error:nil];
    
    return f;
}

/**
 *  返回唯一设备标识
 *
 *  @return 设备标识
 */
+(NSString*)deviceIdentifier{
    //先同步一下, 防止设备标识还未存在的情况
//    [self syncDeviceIdentifier];
    
    //从钥匙串中获取唯一设备标识
    NSString * deviceIdentifier = [SFHFKeychainUtils getPasswordForUsername:@"deviceIdentifiermoqu" andServiceName:bundleIdentifier error:nil];
    
    if(!deviceIdentifier)
    {
        NSString *tempUUID = [HDeviceIdentifier getUUID];
        if([HDeviceIdentifier syncDeviceIdentifier:tempUUID])
        {
            deviceIdentifier = tempUUID;
        }
    }
    return deviceIdentifier;
}

/**
 *  本应用是第一次安装
 *
 *  @return 是否是第一次安装
 */
+(BOOL)isFirstInstall{
    
    NSString * deviceIdentifier = [HDeviceIdentifier deviceIdentifier];
    
    /**
     *  如果钥匙串中存的deviceIdentifier(设备标识)不存在 或者 等于deviceIdentifier(本应用的UUID) , 则为第一次安装
     */
    if (!deviceIdentifier)
    {
        return YES;
    }else{
        return NO;
    }
}


+ (NSString *)getUUID
{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    
    CFRelease(uuid_ref);
    
    CFRelease(uuid_string_ref);
    
    return [uuid lowercaseString];
}
@end