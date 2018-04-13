//
//  DDLoginManager.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/5.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDLoginManager : NSObject
+ (DDLoginManager *)shareLoginManager;
+ (BOOL)checkPhoneNum:(NSString *)mobileNum;
// 判断是否是11位手机号码
+ (BOOL)judgePhoneNumber:(NSString *)phoneNum;

//获取验证码 0注册  1重置密码获取验证码
- (void)requestVerCode:(NSString *)aPhoneNum codeType:(int)aCodeType;

//注册
- (void)requestRegisterPhoneNum:(NSString *)aPhoneNum
                            psw:(NSString *)aPsw
                      checkCode:(NSString *)aCheckCode
                  completeBlock:(void(^)(BOOL ret))aBlock;

//完善资料
- (void)reqestComInfoGender:(NSString *)aGender
                   nickName:(NSString *)aNickName
                    imgData:(NSData*)aImgData
                   birthday:(NSString *)aBirthDay
                 inviteCode:(NSString *)aInviteCode
                      place:(NSString *)place
              completeBlock:(void(^)(BOOL ret))aBlock;

//登陆
- (void)requestLoginPhoneNum:(NSString *)aPhoneNum
                         psw:(NSString *)aPsw
               completeBlock:(void(^)(BOOL ret))aBlock;

//编辑心情
- (void)requestMood:(NSString *)aMood
      completeBlock:(void(^)(BOOL ret))aBlock;

//编辑签名
- (void)requestUserSig:(NSString *)sig
         completeBlock:(void(^)(BOOL ret))aBlock;

//重置密码
- (void)requestRestPasswordPhoneNum:(NSString *)aPhoneNum
                                psw:(NSString *)aPsw
                          checkCode:(NSString *)aCheckCode
                      completeBlock:(void(^)(BOOL ret))aBlock;

//查找好友
- (void)requestSearchFriend:(NSString *)keyword
                      accid:(NSString *)accid
              completeBlock:(void(^)(NSMutableArray *userArr))aBlock;

//第三方登录接口调用
- (BOOL)requestThirdLogin:(NSString *)aOpenId  //必须
                loginType:(NSString *)aLoginType //必须 0表示QQ，1标识微信，2表示新浪微博
                  hearUrl:(NSString *)aHeadUrl   //否 头像url
                     nick:(NSString *)aNickName  // 否
                   gender:(NSString*)aGender  // 否 M:男 F:女
                 birthday:(NSString *)aBirthday //否
              loginResult:(void(^)(int result))aBlock;

//刷新用户信息 
- (void)requesUpdateUserInfo:(NSString *)aAccid
               completeBlock:(void(^)(BOOL ret))aBlock;
@end
