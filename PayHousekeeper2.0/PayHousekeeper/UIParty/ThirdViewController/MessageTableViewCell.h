//
//  MessageTableViewCell.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *avatarImgView;
@property(nonatomic, strong) UIImageView *vipImgView;
@property(nonatomic, strong) UILabel *nameLab;
@property(nonatomic, strong) UILabel *timeLab;
@property(nonatomic, strong) UILabel *messLab;
@property(nonatomic, strong) UILabel *line;
@property(nonatomic, strong) UILabel *redDot;

@end
