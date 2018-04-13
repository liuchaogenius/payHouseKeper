//
//  PersonInfoVipInfoCell.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonInfoVipInfoCell.h"
#import "UIViewAdaptive.h"
@interface PersonInfoVipInfoCell()
{
    BOOL isVip;
    int vipLevel;
    NSString *vipName;
}
@property (nonatomic, copy)void(^buttonClickBlock)(int tag);
@end
@implementation PersonInfoVipInfoCell
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.baseRatio = RatioBaseOn_6_ScaleFor5;
    }
    return self;
}
- (void)setCellData:(BOOL)aIsVip
            vipName:(NSString *)aVipName
           vipLevel:(int)aVipLevel
        buttonClick:(void(^)(int tag))aClickBlock
{
    isVip = aIsVip;
    vipName = aVipName;
    vipLevel = aVipLevel;
    self.buttonClickBlock = aClickBlock;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self createCell];
}

- (void)createCell
{
    [self removeSubviews];
    UILabel *titlLabel = [self labelWithFrame:CGRectMake(FitSize(16), FitSize(20), kMainScreenWidth-FitSize(15), FitSize(15)) text:@"账号等级" textFont:kFont14 textColor:[UIColor colorWithHexValue:0x333333]];
    [self addSubview:titlLabel];

    
    UIImage *leveImg = [UIImage imageNamed:@"vipLevelimg"];
    UIImageView *levelImgview = [[UIImageView alloc] initWithFrame:CGRectMake(titlLabel.left, FitSize(45), FitSize(44), FitSize(44))];
    [levelImgview setImage:leveImg];
    [self addSubview:levelImgview];
    
    NSString *strlevel = [NSString stringWithFormat:@"Lv.%d",vipLevel];
    UILabel *levelLabel = [self labelWithFrame:CGRectMake(levelImgview.right+FitSize(15), levelImgview.top+(levelImgview.height-FitSize(17))/2, FitSize(90), FitSize(18)) text:strlevel textFont:kFont17 textColor:[UIColor colorWithHexValue:0xffcf3e]];
    [self addSubview:levelLabel];
    
    UIImage *vipImg = nil;
    NSString *vipDesc = nil;
    UIColor *vipFontcolor = nil;
    if(isVip)
    {
        vipImg = [UIImage imageNamed:@"personVip"];
        vipDesc = vipName?vipName:@"VIP会员";
        vipFontcolor = [UIColor colorWithHexValue:0xDAC23E];
    }
    else
    {
        vipImg = [UIImage imageNamed:@"persionNoVip"];
        vipDesc = @"请开通vip";
        vipFontcolor = [UIColor colorWithHexValue:0x999999];
    }
    //(titlLabel.left, 50, 44, 44)
    UIImageView *vipImgview = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth-FitSize(125)-FitSize(44), levelImgview.top, FitSize(44), FitSize(44))];
    [vipImgview setImage:vipImg];
    [self addSubview:vipImgview];
    
    UILabel *vipDescLabel = [self labelWithFrame:CGRectMake(vipImgview.right+FitSize(15), vipImgview.top+(vipImgview.height-FitSize(17))/2, FitSize(90), FitSize(18)) text:vipDesc textFont:kFont17 textColor:vipFontcolor];
    [self addSubview:vipDescLabel];
    
//    [self viewAddTopLine];
    
    // BY注释
//    [self viewAddBottomLine];
    
    UIButton *levelBt = [self buttonWithFrame:CGRectMake(0, 0, levelLabel.right, self.height) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    levelBt.tag = 1;
    
    [levelBt addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:levelBt];
    
    UIButton *vipBt = [self buttonWithFrame:CGRectMake(vipImgview.left, 0, self.width-vipImgview.left, self.height) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    vipBt.tag = 0;

    [vipBt addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:vipBt];
    

    
}

- (void)buttonClickItem:(UIButton *)aBt
{
    if(self.buttonClickBlock)
    {
        self.buttonClickBlock((int) aBt.tag);
    }
}

@end
