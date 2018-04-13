//
//  PersonSettingCell.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/10.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonSettingCell.h"

@interface PersonSettingCell()
{
    UIButton *bt;
}
@property (nonatomic, strong) NSString *leftContent;
@property (nonatomic, strong) NSString *rightContent;

@end

@implementation PersonSettingCell

- (void)setCellData:(NSString *)aLeftContent righcontent:(NSString *)aRightContent
{
    self.leftContent = aLeftContent;
    self.rightContent = aRightContent;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(_islogout)
    {
        [self createLogOut];
    }
    else
    {
        [self createCell];
    }
}

- (void)createCell
{
    if(bt)
    {
        bt.hidden = YES;
    }
    self.backgroundColor = kcolorWhite;
    CGSize lsize = [self.leftContent sizeWithFont:kFont17];
    UILabel *leftlabel = [self labelWithFrame:CGRectMake(kLeftMragin, 0, lsize.width+2, self.height) text:self.leftContent textFont:kFont17 textColor:kBlackColor];
    [self addSubview:leftlabel];
    
    UIImage *img = [UIImage imageNamed:@"personArrow"];
    if(self.rightContent && self.rightContent.length > 0)
    {
        CGSize rsize = [self.rightContent sizeWithFont:kFont17];
        CGFloat x = self.width-kLeftMragin-img.size.width-10-rsize.width-2;
        UILabel *rightLabel = [self labelWithFrame:CGRectMake(x, 0, lsize.width+2, self.height) text:self.rightContent textFont:kFont17 textColor:kBlackColor];
        [self addSubview:rightLabel];
    }
    if(self.leftContent && self.leftContent.length > 0)
    {
        UIImageView *arrowImgview = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-kLeftMragin-img.size.width, (self.height-img.size.height)/2, img.size.width, img.size.height)];
        [arrowImgview setImage:img];
        [self addSubview:arrowImgview];
    }
}

- (void)createLogOut
{
    if(!bt)
    {
        bt = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, self.width-40, 44)];
        [self addSubview:bt];
    }
    bt.hidden = NO;
    [bt setTitle:@"退出登录" forState:UIControlStateNormal];
    [bt setTitleColor:kcolorWhite forState:UIControlStateNormal];
    bt.layer.cornerRadius = 22.f;
    bt.userInteractionEnabled = NO;
    bt.backgroundColor = RGBCOLOR(255, 103, 108);
    self.backgroundColor = kClearColor;
    
}

@end
