//
//  VideoChatBottomView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BotoomBtnClick)(int index);

@interface VideoChatBottomView : UIView

@property (nonatomic,strong) UIButton       *countBtn;        
@property (nonatomic,strong) UILabel        *durationLabel;
@property (nonatomic,strong) UIImageView    *countImg;

@property (copy)             BotoomBtnClick clickBlock;

@end
