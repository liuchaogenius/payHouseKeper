//
//  MessageTableViewCell.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/10/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

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
        _nameLab.textColor = RGBCOLOR(83, 219, 144);
        _nameLab.font = kFont16;
        _nameLab.backgroundColor = kClearColor;
        [self.contentView addSubview:_nameLab];

        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth-120, 10, 100, 13)];
        _timeLab.textColor = RGBCOLOR(199, 199, 199);
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.font = kFont11;
        _timeLab.backgroundColor = kClearColor;
        [self.contentView addSubview:_timeLab];
        
        _messLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.x, _nameLab.bottom+8, kMainScreenWidth-97, 13)];
        _messLab.textColor = RGBCOLOR(121, 121, 121);
        _messLab.font = kFont13;
        _messLab.backgroundColor = kClearColor;
        [self.contentView addSubview:_messLab];
        
        _line = [[UILabel alloc] initWithFrame:CGRectMake(0, 63, kMainScreenWidth, 1)];
        _line.backgroundColor = RGBCOLOR(238, 238, 238);
        [self.contentView addSubview:_line];
        
        _redDot = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImgView.right-4, 6, 8, 8)];
        _redDot.backgroundColor = [UIColor redColor];
        _redDot.clipsToBounds = YES;
        _redDot.layer.cornerRadius = 4.0;
        [self.contentView addSubview:_redDot];
    }
    return self;
}

@end
