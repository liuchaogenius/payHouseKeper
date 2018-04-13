//
//  NetManager.h
//  striveliu
//
//  Created by striveliu on 12-12-21.
//  Copyright (c) 2012年 xie licai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define SUCCESSBLOCK      void(^)(NSDictionary* successDict)
#define FAILUREBLOCK      void(^)(NSDictionary *failDict, NSError *error)
#define PROGRESSBLOCK     void(^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)

typedef void (^ChangeNetStatus)(BOOL isConnect);

@interface NetManager : NSObject

@property (copy)    ChangeNetStatus               changeStatusBlock;             //网络状态变化闭包
@property (nonatomic, assign) BOOL isNetConnected;
@property (nonatomic, strong) NSString *myUUID;
@property (nonatomic, assign) BOOL is3G;

+ (NetManager *)shareInstance;
- (void)setUserid:(NSString *)aUserid;
- (void)setUserToken:(NSString *)aUserToken;

/**
 *  监听网络状态
 *
 */
- (void)checkReachabilityStatusChange;

//- (void)set
/******************************************************
 *  aDict   body数据 如果没有业务数据此值为nil
 *  aUrl
 *  aMethod
 *  aEncoding
 *  success
 *  failure
 */
+ (void)requestWith:(id)aDict
            apiName:(NSString *)aApiName
             method:(NSString *)aMethod
    timeOutInterval:(int)aTimeOutInterval
               succ:(SUCCESSBLOCK)success
            failure:(FAILUREBLOCK)failure;

+ (void)uploadImg:(UIImage*)aImg
       parameters:(NSDictionary*)aParam
          apiName:(NSString *)aApidName
        uploadUrl:(NSString*)aUrl
    uploadimgName:(NSString*)aImgname
    progressBlock:(PROGRESSBLOCK)block
             succ:(SUCCESSBLOCK)success
          failure:(FAILUREBLOCK)failure;

+ (void)uploadImgArry:(NSArray*)aImgArry
           parameters:(NSDictionary*)aParam
              apiName:(NSString *)aApidName
            uploadUrl:(NSString*)aUrl
        uploadimgName:(NSString*)aImgname
        progressBlock:(PROGRESSBLOCK)block
                 succ:(SUCCESSBLOCK)success
              failure:(FAILUREBLOCK)failure;

+ (void)downloadFileUrl:(NSString*)aUrl
               fullPath:(NSString*)aImgname
          progressBlock:(PROGRESSBLOCK)block
                   succ:(SUCCESSBLOCK)success
                failure:(FAILUREBLOCK)failure;

+ (void)cancelOperation:(id)aOperationKey;
@end
