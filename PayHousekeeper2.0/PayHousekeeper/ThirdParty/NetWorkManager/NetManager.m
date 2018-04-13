//
//  NetManager.m
//  striveliu
//
//  Created by striveliu on 12-12-21.
//  Copyright (c) 2012年 xie licai. All rights reserved.
//

#import "NetManager.h"
#import <objc/runtime.h>
#import "ThreadSafeMutableDictionary.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "MatchingViewController.h"
#import "SFHFKeychainUtils.h"
#import "HDeviceIdentifier.h"
@interface NetManager()
{
    NSMutableDictionary *mutaDict;
    NSString *strUserid;
    NSString *strUserToken;
    float lat;
    float lon;
    NSString *areaId;
    BOOL isMultipart;
}
@end

@implementation NetManager

+ (NetManager *)shareInstance
{
    static NetManager *netMan;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netMan = [[NetManager alloc] init];
    });
    return netMan;
}

- (instancetype)init
{
    if(self = [super init])
    {
        mutaDict = [[ThreadSafeMutableDictionary alloc] initWithCapacity:0];
        [self checkReachabilityStatusChange];
        _isNetConnected = YES;
    }
    return self;
}

- (void)addOperationAndKey:(NSString *)aKey operation:(id)aOperation
{
    [mutaDict setObject:aOperation forKey:aKey];
}

- (void)removeOperationKey:(NSString *)aKey
{
    if(aKey)
    {
        [mutaDict removeObjectForKey:aKey];
    }
}

- (id)objectForKey:(NSString *)aKey
{
    if(aKey)
    {
        return [mutaDict objectForKey:aKey];
    }
    return nil;
}
- (void)removeAllOperation
{
    [mutaDict removeAllObjects];
}

- (void)setUserid:(NSString *)aUserid
{
    strUserid = aUserid;
}

- (void)setUserToken:(NSString *)aUserToken
{
    strUserToken = aUserToken;
}


- (NSString *)getUserid
{
    return strUserid;
}

- (NSString *)getUserToken
{
    if(!strUserToken) strUserToken = @"";
    return strUserToken;
}



- (void)dealloc
{
    MLOG(@"Netmanager--dealloc");
}

//监听网络连接状态
- (void)checkReachabilityStatusChange
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    WeakSelf(self)
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusNotReachable:
             {
                 weakself.is3G = NO;
                 NSLog(@"无网络");
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
             {
                 weakself.is3G = NO;
                 NSLog(@"WiFi网络");
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
                 [[DDSystemInfoManager sharedInstance] cancelDownloadGift];
                 weakself.is3G = YES;
                 NSLog(@"无线网络");
                 break;
             }
             default:
                 break;
         }
         
         weakself.isNetConnected = status!=AFNetworkReachabilityStatusNotReachable;
         if(weakself.changeStatusBlock)
         {
             weakself.changeStatusBlock(weakself.isNetConnected);
         }
     }];
}

+ (void)requestWith:(id)aDict
            apiName:(NSString *)aApiName
             method:(NSString *)aMethod
    timeOutInterval:(int)aTimeOutInterval
               succ:(SUCCESSBLOCK)success
            failure:(FAILUREBLOCK)failure

{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedHTTPSessionManager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = aTimeOutInterval;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseUrl,aApiName];
    MLOG(@"%@", aDict);
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO//如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy  = securityPolicy;
    MLOG(@"requestUrl = %@",requestUrl);
    if([aApiName compare:kComInfo] == 0)
    {
        [NetManager setMultiyRequestHeadValue:manager];
    }
    else
    {
        [NetManager setRequestHeadValue:manager apiName:aApiName reqParam:aDict];
    }
    NSString *method = [aMethod uppercaseString];
    
    if([method compare:@"POST"] == 0)
    {
        if([aApiName compare:kComInfo] == 0)
        {
            NSData *headData = [aDict objectForKey:@"avatar"];
            [manager POST:requestUrl parameters:aDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                if(headData)
                    [formData appendPartWithFileData:headData name:@"avatar" fileName:@"avatar" mimeType:@"image/jpeg"];
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
                NSDictionary *dict = responseObject;
                MLOG(@"requestSuccessDict = %@",dict);
                int status = [[dict objectForKey:@"state"] intValue];
                NSDictionary *succDict = [dict objectForKey:@"data"];
                if((isNull(succDict) && ![succDict isKindOfClass:[NSDictionary class]]) || [succDict isEqual:@""])
                {
                    succDict = nil;
                }
                
                if(succDict.count == 0)
                {
                    succDict = nil;
                }
                
                if(status == 200)
                {
                    success(succDict);
                }
                else
                {
                    if([aApiName compare:kThirdBindAPI] == 0 || [aApiName compare:kThirdUnBindAPI] == 0)
                    {
                        success(dict);
                    }
                    else
                    {
                        success(nil);
                    }
                    [NetManager isShowLoginWindow:dict];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSString *message = @"当前网络不可用";
                AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [del showToastView:message];
            }];
        }
        else
        {
            [manager POST:requestUrl parameters:aDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      
                NSDictionary *dict = responseObject;
                
                MLOG(@"requestSuccessDict = %@",dict);
                UINavigationController *nav = [DLAPPDELEGATE.newtabr getCurrentNavController];
                if([aApiName compare:kUserMatch] == 0 && ![nav.topViewController isKindOfClass:[MatchingViewController class]])
                    return;
                int status = [[dict objectForKey:@"state"] intValue];
                NSDictionary *succDict = [dict objectForKey:@"data"];
                if((isNull(succDict) && ![succDict isKindOfClass:[NSDictionary class]]) || [succDict isEqual:@""])
                {
                    succDict = nil;
                }
                
                if(succDict.count == 0)
                {
                    succDict = nil;
                }
                
                if(status == 200)
                {
                    if([aApiName compare:kBindPhoneNoAPI] == 0 || [aApiName compare:kThirdBindAPI] == 0 || [aApiName compare:kThirdUnBindAPI] == 0 || [aApiName compare:kGiveGiftAPI] == 0 || [aApiName compare:kBindCrashAlipayAccountAPI] == 0)
                    {
                        success(dict);
                    }
                    else
                    {
                        if([aApiName compare:kGetGiftsAPI] == 0)
                            succDict = dict;
                        success(succDict);
                    }
                }
                else
                {
                    if([aApiName compare:kBindPhoneNoAPI] == 0 || [aApiName compare:kThirdBindAPI] == 0 || [aApiName compare:kThirdUnBindAPI] == 0 || [aApiName compare:kGiveGiftAPI] == 0 ||[aApiName compare:kBindCrashAlipayAccountAPI] == 0 || [aApiName compare:kUserMatch] == 0)
                    {
                        success(dict);
                    }
                    else
                    {
                        success(succDict);
                    }
                    if(status != 204)
                        [NetManager isShowLoginWindow:dict];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                if([aApiName compare:kUserMatch] == 0)
//                {
//                    //匹配不到超时
//                    if(error.code == -1001)
//                    {
//                        success(nil);
//                    }
//                }
//                else
//                {
                NSString *message = @"当前网络不可用";
                AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [del showToastView:message];

//                    MLOG(@"requestFileDict = %@",task.response);
//                    NSDictionary *dict = @{@"retcode":@"-10000"};
//                    [NetManager isShowLoginWindow:dict];
                    failure(nil,error);
//                }
            }];
        }
        
        
    }
    else if([method compare:@"GET"] == 0)
    {
        [manager GET:requestUrl parameters:aDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            MLOG(@"requestSuccessDict = %@",dict);
            int status = [[dict objectForKey:@"state"] intValue];
            if(status == 200)
            {
//                NSDictionary *succDict = [dict objectForKey:@"data"];
//                if([aApiName compare:kGetGiftsAPI] == 0)
//                    succDict = dict;
                success(dict);
            }
            else{
                success(nil);
                if(status != 204)
                    [NetManager isShowLoginWindow:dict];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            if([aApiName compare:kUserMatch] == 0)
//            {
//                //匹配不到超时
//                if(error.code == -1001)
//                {
//                    success(nil);
//                }
//            }
//            else
//            {
            NSString *message = @"当前网络不可用";
            AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [del showToastView:message];
            
//                MLOG(@"requestFileDict = %@",task.response);
//                NSDictionary *dict = @{@"retcode":@"-10000"};
//                [NetManager isShowLoginWindow:dict];
                failure(nil,error);
//            }

        }];
    }
}



+ (BOOL)isShowLoginWindow:(NSDictionary *)aDict
{
    int status = [[aDict objectForKey:@"state"] intValue];
    NSString *message = [aDict objectForKey:@"message"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([message isEqualToString:@"邀请码错误"]) {
        [del showToastView:@"邀请码错误"];
    }
    if(status == 2007 || status == 2003)
    {
        [del showLoginWindow];
        return YES;
    }
    else if(status == 2002)
    {
        [del showToastView:@"用户名或者密码错误"];
    }
    else if(status == 2004)
    {
        [del showToastView:@"用户不存在"];
    }
    else if(status == 2008)
    {
        [del showToastView:@"验证码错误"];
    }
    else if(status == 2009)
    {
        [del showToastView:@"用户名已注册"];
    }
    else if(status == 2006)
    {
        [del showToastView:@"新密码为空"];
    }
    else if(status == 2034)
    {
        [del showToastView:@"咚果不足"];
    }
    else if(status == 2030)
    {
        [del showToastView:@"咚果不足"];
    }
    else if(status == 403)
    {
        MLOG(@"关键参数缺失");
    }
//    else
//    {
//        [del showToastView:@"网络异常，稍后再试"];
//    }
    return NO;
}

- (NSString *)basePostDict:(id)aParam apiName:(NSString *)aApiName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:0];
    [dict setValue:aApiName forKey:@"ApiName"];

    if([self getUserid])
    {
        [dict setValue:[self getUserid] forKey:@"UID"];
    }

    if([self getUserToken])
    {
        [dict setValue:[self getUserToken] forKey:@"Token"];
    }

    if(aParam)
    {
        NSString *myJsonString = [NetManager Dic_ToJSONString:aParam];
        [dict setValue:myJsonString forKey:@"ApiParam"];
    }
        
    NSString *paramString = [NetManager Dic_ToJSONString:dict];
    return paramString;
}

+ (NSString*)Dic_ToJSONString:(id)aDict
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:aDict
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    
    NSString *jsonString = [[NSString alloc] initWithData:result
                                                 encoding:NSUTF8StringEncoding];
    //    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:(NSUTF8StringEncoding)];//转json的格式
    return jsonString;
}

+ (void)setRequestHeadValue:(AFHTTPSessionManager*)aRequest apiName:(NSString *)aAPIName reqParam:(NSDictionary *)aDict
{
    if([aAPIName compare:kLoginAPI] == 0 || [aAPIName compare:kBindPhoneNoAPI] == 0)
    {
        [aRequest.requestSerializer setValue:[aDict objectForKey:@"timestamp"] forHTTPHeaderField:@"timestamp"];
    }
    [aRequest.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [aRequest.requestSerializer setValue:@"iOS" forHTTPHeaderField: @"Platform-Type"];
    if(![NetManager shareInstance].myUUID)
    {
        [NetManager shareInstance].myUUID = [HDeviceIdentifier deviceIdentifier];
    }
    if([NetManager shareInstance].myUUID)
    {
        [aRequest.requestSerializer setValue:[NetManager shareInstance].myUUID forHTTPHeaderField: @"deviceid"];
    }
    [aRequest.requestSerializer setValue:kSofterViewsion forHTTPHeaderField: @"client-version"];
}

+ (void)setMultiyRequestHeadValue:(AFHTTPSessionManager*)aRequest
{
    [aRequest.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField: @"Content-Type"];
    [aRequest.requestSerializer setValue:@"iOS" forHTTPHeaderField: @"Platform-Type"];
    if(![NetManager shareInstance].myUUID)
    {
        [NetManager shareInstance].myUUID = [HDeviceIdentifier deviceIdentifier];
    }
    if([NetManager shareInstance].myUUID)
    {
        [aRequest.requestSerializer setValue:[NetManager shareInstance].myUUID forHTTPHeaderField: @"deviceid"];
    }
    [aRequest.requestSerializer setValue:kSofterViewsion forHTTPHeaderField: @"client-version"];
}
+ (void)cancelOperation:(id)aKey
{
//    NetManager *net = [NetManager shareInstance];
//    AFHTTPRequestOperation *operation = [net objectForKey:aKey];
//    [operation cancel];
}

+ (void)downloadFileUrl:(NSString*)aUrl
               fullPath:(NSString*)fullPath
          progressBlock:(PROGRESSBLOCK)block
                   succ:(SUCCESSBLOCK)success
                failure:(FAILUREBLOCK)failure
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedHTTPSessionManager];
    NSURL *url = [NSURL URLWithString:aUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task =
    [manager downloadTaskWithRequest:request
                            progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                return [NSURL fileURLWithPath:fullPath];
                            }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       if(!error)
                       {
                           [[DDSystemInfoManager sharedInstance].downloadZipDic removeObjectForKey:aUrl];
                            success(nil);
                       }
                       else
                       {
                           [[DDSystemInfoManager sharedInstance].downloadZipDic removeObjectForKey:aUrl];
                           failure(nil,error);
                       }
                   }];
    [[DDSystemInfoManager sharedInstance].downloadZipDic setObject:task forKey:aUrl];
    [task resume];
}

+ (void)uploadImg:(UIImage*)aImg
       parameters:(NSDictionary*)aParam
          apiName:(NSString *)aApidName
        uploadUrl:(NSString*)aUrl
    uploadimgName:(NSString*)aImgname
    progressBlock:(PROGRESSBLOCK)block
             succ:(SUCCESSBLOCK)success
          failure:(FAILUREBLOCK)failure
{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSData *imageData = UIImageJPEGRepresentation(aImg, 1);
//    NSString *param = nil;
//    NSMutableDictionary *dict = nil;
//    manager.requestSerializer.timeoutInterval = 30;
//    
//    param = [[NetManager shareInstance] basePostDict:aParam apiName:aApidName];
//    dict = [NSMutableDictionary dictionaryWithDictionary:aParam];
//    [dict setValue:param forKey:@"S3CAPI"];
//    [manager.requestSerializer setValue:param forHTTPHeaderField:@"S3CAPI"];
//    [NetManager setRequestHeadValue:manager];
//    if([kBaseUrl compare:@"https://api.dianjia001.com/sapi4app.html"] == 0)
//    {
//        manager.securityPolicy.allowInvalidCertificates = YES;
//    }
//    
//    [manager POST:kBaseUrl parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:imageData name:@"pic" fileName:@"temp_image.jpg" mimeType:@"application/octet-stream"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *Dict = [operation.responseString objectFromJSONString];
//        success(Dict);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSDictionary *Dict = [operation.responseString objectFromJSONString];
//        success(Dict);
//    }];
}

+ (void)uploadImgArry:(NSArray*)aImgArry
           parameters:(NSDictionary*)aParam
              apiName:(NSString *)aApidName
            uploadUrl:(NSString*)aUrl
        uploadimgName:(NSString*)aImgname
        progressBlock:(PROGRESSBLOCK)block
                 succ:(SUCCESSBLOCK)success
              failure:(FAILUREBLOCK)failure
{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    NSString *param = nil;
//    NSMutableDictionary *dict = nil;
//    manager.requestSerializer.timeoutInterval = 30;
//    
//    param = [[NetManager shareInstance] basePostDict:aParam apiName:aApidName];
//    dict = [NSMutableDictionary dictionaryWithDictionary:aParam];
//    [dict setValue:param forKey:@"S3CAPI"];
//    [manager.requestSerializer setValue:param forHTTPHeaderField:@"S3CAPI"];
//    [NetManager setRequestHeadValue:manager];
//    if([kBaseUrl compare:@"https://api.dianjia001.com/sapi4app.html"] == 0)
//    {
//        manager.securityPolicy.allowInvalidCertificates = YES;
//    }
//    
//    [manager POST:kBaseUrl parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSString *fileName = @"temp_image.jpg";
//        for(int i=0; i<aImgArry.count; i++)
//        {
//            fileName = [NSString stringWithFormat:@"temp_image%d.jpg",i];
//            NSData *imageData = UIImageJPEGRepresentation([aImgArry objectAtIndex:i], 1);
//            [formData appendPartWithFileData:imageData name:@"pic" fileName:fileName mimeType:@"application/octet-stream"];
//        }
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *Dict = [operation.responseString objectFromJSONString];
//        success(Dict);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSDictionary *Dict = [operation.responseString objectFromJSONString];
//        success(Dict);
//    }];
}


@end
