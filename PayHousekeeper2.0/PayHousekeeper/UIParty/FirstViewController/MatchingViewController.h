//
//  MatchingViewController.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BaseViewController.h"
#import "LocalView.h"

@interface MatchingViewController : BaseViewController
@property(nonatomic, strong) UIImageView    *avatarImgView;
@property(nonatomic, strong) LocalView      *localBGView;
@property(nonatomic, assign) BOOL           isOkTime;
@property(nonatomic, strong) NSString       *currentGender;
@end
