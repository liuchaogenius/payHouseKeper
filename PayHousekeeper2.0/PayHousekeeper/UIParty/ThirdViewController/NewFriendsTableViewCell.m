//
//  NewFriendsTableViewCell.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "NewFriendsTableViewCell.h"

@interface NewFriendsTableViewCell()

@property (nonatomic,strong) NIMSystemNotification *notification;

@end

@implementation NewFriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = kcolorWhite;
        self.contentView.backgroundColor = kcolorWhite;
        
        _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 44, 44)];
        _avatarImgView.layer.cornerRadius = _avatarImgView.height/2.0;
        _avatarImgView.clipsToBounds = YES;
        _avatarImgView.backgroundColor = [UIColor grayColor];
        _avatarImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_avatarImgView];
        
        _vipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_avatarImgView.right-12, _avatarImgView.bottom-12, 12, 12)];
        _vipImgView.image = IMG(@"crownVip");
        [self.contentView addSubview:_vipImgView];
        _vipImgView.hidden = YES;
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImgView.right+10, 13, kMainScreenWidth-197, 17)];
        _nameLab.textColor = RGBCOLOR(51, 51, 51);
        _nameLab.font = kFont16;
        _nameLab.backgroundColor = kClearColor;
        [self.contentView addSubview:_nameLab];
        
        _feelLab = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImgView.right+10, _nameLab.bottom+8, kMainScreenWidth-97, 13)];
        _feelLab.textColor = RGBCOLOR(153, 153, 153);
        _feelLab.font = kFont13;
        _feelLab.backgroundColor = kClearColor;
        [self.contentView addSubview:_feelLab];
        
        _line = [[UILabel alloc] initWithFrame:CGRectMake(0, 63, kMainScreenWidth, 1)];
        _line.backgroundColor = RGBCOLOR(238, 238, 238);
        [self.contentView addSubview:_line];
    }
    return self;
}

@end
