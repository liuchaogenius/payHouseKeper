//
//  NTESVideoChatViewController.h
//  NIM
//
//  Created by chris on 15/5/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

//#import "NTESNetChatViewController.h"
#import "LocalView.h"
#import "BroadcastView.h"

@class NetCallChatInfo;

@interface NTESVideoChatViewController : BaseViewController

//@property (nonatomic, strong) NSString *localBGViewFrame;

@property (nonatomic,strong) OtherUserInfoData *userInfo;

@property (nonatomic,assign) BOOL immediate;
@property (nonatomic,assign) BOOL isCircleAnimation;


- (void)setYXCallLifeBlocks;

- (void)onCalling;
@end
