//
//  PersonVIPCell.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/8.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonVIPCell.h"

@implementation BuyVIPData

@end

#pragma mark cell
@interface PersonVIPCell()
{
    BuyVIPData *data;
    UILabel *descLabel;
    UIButton *moneyBt;
    UIImageView *recommendImgview;
    UIView *bgview;
    UIView *spaceview;
    UIImageView *img;
}
@property (nonatomic, copy)void(^buyButtonBlock)(BuyVIPData *data);
@end
@implementation PersonVIPCell


- (void)setCellData:(BuyVIPData*)aData buyItem:(void(^)(BuyVIPData *data))aBlock
{
    data = aData;
    self.buyButtonBlock = aBlock;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self createCell];
    
    img = [[UIImageView alloc] init];
    img.image = [UIImage imageNamed:@"推荐"];
    img.hidden = YES;
    [bgview addSubview:img];
    img.frame = CGRectMake(1, 1, 34, 34);
    if (_imgH == YES) {
        img.hidden = NO;
    }
}
- (void)createCell
{
    if(!bgview)
    {
        bgview = [[UIView alloc] initWithFrame:CGRectMake(15, 3, self.width-15*2, 62)];
        bgview.backgroundColor = kcolorWhite;
        bgview.layer.borderColor = kFcolorFontGreen.CGColor;
        bgview.layer.borderWidth = kLineWidth;
        bgview.layer.cornerRadius = 10.0f;
        [self addSubview:bgview];

        
    }
    if(!descLabel)
    {
        descLabel = [self labelWithFrame:CGRectMake(17, 0, (bgview.width-34)/2, bgview.height) text:@"" textFont:kFont14 textColor:nil];
        [bgview addSubview:descLabel];
    }
    descLabel.text = data.desc;
    if(data.isRecommend)
    {
//        UIImage *rImg = [UIImage imageNamed:@"preson_recommend"];
//        if(!recommendImgview)
//        {
//            recommendImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rImg.size.width, rImg.size.height)];
//            [self addSubview:recommendImgview];
//        }
//        recommendImgview.hidden = NO;
        descLabel.textColor = RGBCOLOR(179, 173, 17);
//        [recommendImgview setImage:rImg];
    }
    else
    {
        descLabel.textColor = kBlackColor;
//        recommendImgview.hidden = YES;
    }
    if(!moneyBt)
    {
        moneyBt = [self buttonWithFrame:CGRectMake(bgview.width-10-65, (bgview.height-27)/2, 65, 28) titleFont:kFont12 titleStateNorColor:RGBCOLOR(0x00, 0xd8, 0x98) titleStateNor:[NSString stringWithFormat:@"%@元",data.moneyCount]];
//        moneyBt.layer.borderWidth = kLineWidth;
//        moneyBt.layer.borderColor = RGBCOLOR(0x00, 0xd8, 0x98).CGColor;
//        moneyBt.layer.cornerRadius = 5.0f;
        [bgview addSubview:moneyBt];
    }
    moneyBt.layer.cornerRadius = 14.0f;
    moneyBt.backgroundColor = kFcolorFontGreen;
    [moneyBt setTitleColor:kcolorWhite forState:UIControlStateNormal];
    [moneyBt addTarget:self action:@selector(buyButtonItem) forControlEvents:UIControlEventTouchUpInside];
    [moneyBt setTitle:data.moneyCount forState:UIControlStateNormal];
    
    if(data.isLasteCell)
    {
        if(!spaceview)
        {
            spaceview = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-8, self.width, 8)];
            spaceview.backgroundColor = kViewBackgroundHexColor;
            [self addSubview:spaceview];
        }
        spaceview.hidden = NO;
    }
    else
    {
        spaceview.hidden = YES;
    }
}

- (void)buyButtonItem
{
    if(self.buyButtonBlock)
    {
        self.buyButtonBlock(data);
    }
}

@end
