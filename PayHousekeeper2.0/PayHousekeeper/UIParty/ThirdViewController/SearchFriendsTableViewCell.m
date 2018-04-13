//
//  SearchFriendsTableViewCell.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "SearchFriendsTableViewCell.h"

@implementation SearchFriendsTableViewCell

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
        _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stateBtn.titleLabel.font = kFont13;
        _stateBtn.frame = CGRectMake(kMainScreenWidth-60, 26, 40, 13);
        [_stateBtn setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
        [self.contentView addSubview:_stateBtn];
    }
    return self;
}

@end
