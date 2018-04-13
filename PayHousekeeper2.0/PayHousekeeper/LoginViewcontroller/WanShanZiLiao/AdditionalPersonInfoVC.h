//
//  AdditionalPersonInfoVC.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BaseViewController.h"

@interface AdditionalPersonInfoVC : BaseViewController
@property (nonatomic, assign)BOOL phoneDone;
@property (nonatomic, assign)BOOL isThirdLogin;
@property (nonatomic, strong)NSString *isPhoneNum;
@property (nonatomic, strong)NSString *userPsw;
@end
