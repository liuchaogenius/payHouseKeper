//
//  MessageDefine.h
//  Hubanghu
//
//  Created by  striveliu on 14-10-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#ifndef Hubanghu_MessageDefine_h
#define Hubanghu_MessageDefine_h

#define kLeftViewPushMessage @"leftviewpushmessage"
#define kLeftViewPopMessage @"leftviewpopmessage"
#define kLoginForUserMessage @"loginforuser"
#define kLoginSuccessMessae @"loginsuccess" //登陆成功发送消息
#define kLoginFailMessage @"loginFail"
#define kLoadingTips @"加载中..."
#define kPost @"POST"
#define KGet  @"GET"

#define kDevelopment 1

#if kDevelopment
#define kBaseUrl        @"http://120.24.154.77/dondon/facade/"
#else
#define kBaseUrl   @"https://moqukeji.top/dondon/facade/"
#endif
#define kRegisterAPI @"duser/register" //注册
#define kGetVerCode  @"duser/verCode" //获取验证码
#define kComInfo @"duser/comInfo" //完善用户资料
#define kGetInfoStateList @"duser/infoStateList" //获取官方最新消息及用户最新更新的心情列表
#define kLoginAPI @"duser/login"
#define kUpdateStatusAPI @"duser/upstate"
#define kResetPSW  @"duser/resetPwd"
#define kGetRestPSWCode @"duser/verCodeByReset"
#define kUserMatch @"duser/userMatch" //用户匹配
#define kGetUserInfo @"inter/userInfo" //获取用户信息
#define kMyWalletAPI @"duser/myWallet"//获取我的钱包
#define kMyIncomeAPI @"duser/myIncome"//我的收益
#define kRechargeListAPI @"duser/rechargeList" //充值项目清单
#define kVIPRechargeListAPI @"duser/vipRechargeList" //VIP充值项目清单
#define kBindPhoneNoAPI @"duser/bindPhoneNo" //绑定手机
#define kGetUserLevelAPI @"inter/userLevel" //获取用户等级api
#define kGetOterPersonUserInfoAPI @"inter/userInfo" //获取其他用户信息
#define kILikeAPI @"duser/iLike" //点喜欢
#define kPueryUserAPI @"inter/queryUsers" //查询用户信息
#define kAddRosterAPI @"roster/addRoster" //关注
#define kRemoveRosterAPI @"roster/removeRoster" //取消关注
#define kGetGiftsAPI @"inter/pList" //礼物列表
#define kGiveGiftAPI @"inter/givePresent" //赠送礼物
#define kSysInfoAPI @"sys/info" //用户获取当前系统的配置信息
#define kNoticeInfoAPI @"notice/pull" //客户端从服务器拉取通知消息
#define kRandAvatarAPI @"inter/randAvatar" //随机获取10个用户头像
#define kThirdLoginAPI @"inter/thirdLogin"
#define kConversionAPI @"conv/conversion" //用于兑换咚果
#define kInviteInfoAPI @"duser/inviteInfo"  //获取邀请码
#define kBindListAPI @"inter/bindList"//获取绑定list
#define kThirdBindAPI @"inter/bind" //第三方绑定
#define kThirdUnBindAPI @"inter/unbind"//解绑第三方
#define kChangeItemAPI @"sys/changeItems"// 获取兑换清单
#define kAlipayCashAPI @"alipay/cash"
#define kGetWXPayInfoAPI @"wx/getPayInfo" //微信支付获取支付信息
#define kGetWXVerifyAPI @"wx/wxVerify" //微信支付验证接口
#define kAlipaySignAPI  @"alipay/aliSign" //支获取支付宝订单签名 
#define kAlipayVerifyAPI @"alipay/verify" //支付宝支付验证接口
#define kBindCrashAlipayAccountAPI @"alipay/alibind" //绑定支付宝账号
#define kGetBindCrashAccountInfoAPI @"alipay/accInfo" //获取绑定账号信息
#define kAppleVerifyAPI @"apple/validating" //苹果内购支付验证接口

#define kGetFansAndAttentionAPI @"roster/getConcerns" //获取粉丝或关注列表
#define kGetFriendsAPI @"roster/getRosters" //获取好友列表
#define kGetDDPushMsgAPI @"notice/getPushMsg" //获取咚咚熊消息
#define kRepertAPI @"duser/reportto" //上传行为信息
#define kTipoffAPI @"duser/tipoff" //举报
#define kGetSwitchAPI @"inter/switch" //开关
#define kCancelMatchAPI @"duser/cancelMatch" //取消匹配
#define kDeFriendAPI @"duser/defriend" //拉黑


#define kGetUserExtInfoAPI @"duser/getUserExt"

#define kWEIXINLoginAppid @"wxa4c083e3fcf06c80"
#define kQQLoginAPPID @"1105702539"
#define kWEXINAppSecret @"2de3d3a83645f9882747971ffb64203b"
#define kQQAppKey @"sevk2vhjDMGgbGGQ"
#define kWEIBOAppKey @"500593477"
#define kWEIBOAppSecret @"0409b06dd8e54111323d742dab631e85"

/*友盟*/
#define UMAppKey            @"584f9a346e27a42f87000654" //友盟appkey
#define MsgCallTime         @"call_time"                //通话时间
#define MsgClickAvatar      @"click_avatar"             //点击头像
#define MsgClickFriend      @"click_friend"             //点击联系人
#define MsgClickMood        @"click_mood"               //点击心情
#define MsgClickQuitMatch   @"click_quit_match"         //退出匹配
#define MsgClickStart       @"click_start"              //点击开始
#define MsgEnterRecharge    @"enter_recharge"           //进入充值页面
#define MsgEnterRechargeFP  @"enter_recharge_from_present"//从礼物页面进入充值页面
#define MsgEnterRechargeFS  @"enter_recharge_from_setting"//从设置页面进入充值页面
#define MsgEnterRegister    @"enter_register"           //进入注册页
#define MsgEnterVip         @"enter_vip"                //进入VIP页面
#define MsgFillProfile      @"fill_profile"             //完善个人信息
#define MsgHomeEnter        @"home_enter"               //进入首页
#define MsgMatchStart       @"match_start"              //开始匹配
#define MsgMatchSuccess     @"match_success"            //匹配成功
#define MsgMatchTime        @"match_time"               //匹配时长
#define MsgPayRechargeType  @"pay_recharge_type"        //充值类型
#define MsgPayVipSuccess    @"pay_vip_success"          //购买VIP成功
#define MsgPayVipType       @"pay_vip_type"             //各类会员购买
#define MsgRechargeSuccess  @"recharge_success"         //充值成功
#define MsgRegisterSuccess  @"register_success"         //注册成功
#define MsgSendPresent      @"send_present"             //送礼事件
#define MsgSetBeauty        @"setting_beauty"           //视频装扮
#define MsgSetBlur          @"setting_blur"             //使用模糊
#define MsgThirdLoginStart  @"third_login_start"        //第三方登录开始
#define MsgThirdLoginSuc    @"third_login_success"      //第三方登录成功
#define MsgVerifyCode       @"verify_code"              //获取验证码
//第三方登录openId
#define kWXAutoLoginOpenid @"wx_autoLoginOpenid"
#define kQQAutoLoginOpenid @"qq_autoLoginOpenid"
#define kDDLoginType @"dongdongLoginType" 
//各种消息通知定义
#define kWXLoginSuccessNotifyName @"WXLoginSuccessNotifyName"
#define kQQLoginSuccessNotifyName @"QQLoginSuccessNofityName"
#define kWEIBOLoginSuccessNotifyName @"WEIBOLoginSuccessNotifyName"
#endif
