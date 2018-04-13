//
//  PersonInfoDongBiCell.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonInfoDongBiCell.h"

@implementation ChongzhiDBData


@end

#pragma mark cell
@interface PersonInfoDongBiCell()
{
    ChongzhiDBData *cellData;
    UIImageView *leftImgview;
    UILabel *dbLabel;
    UILabel *descLabel;
    UIButton *bt;
}
@property (nonatomic, copy) void(^buyButtonClick)(ChongzhiDBData *data);
@end
@implementation PersonInfoDongBiCell

- (void)setCellData:(ChongzhiDBData *)aData
{
    cellData = aData;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [dbLabel removeFromSuperview];
    [descLabel removeFromSuperview];
    [bt removeFromSuperview];
    [self createCell];
}

- (void)setBuyButtonClickBlock:(void(^)(ChongzhiDBData *data))aBlock
{
    self.buyButtonClick = aBlock;
}

- (void)createCell
{
    UIImage *img = nil;
//    if(cellData.isYouhui)
    {
        img = [UIImage imageNamed:@"p_dongbi_icon"];
    }
    if(leftImgview == nil)
    {leftImgview = [[UIImageView alloc] initWithFrame:CGRectMake(10, (self.height-30)/2, 30, 30)];
    [leftImgview setImage:img];
    leftImgview.backgroundColor = [UIColor clearColor];
    [self addSubview:leftImgview];
    }
    
    CGSize dbsize = [cellData.czdbNum sizeWithFont:kFont15];
    dbLabel = [self labelWithFrame:CGRectMake(leftImgview.right+5, leftImgview.top, dbsize.width+2, leftImgview.height) text:cellData.czdbNum textFont:kFont15 textColor:RGBCOLOR(0x51, 0x51, 0x51)];
    [self addSubview:dbLabel];
    
    if(cellData.dataDesc && cellData.dataDesc.length > 0)
    {
        CGSize dssize = [cellData.dataDesc sizeWithFont:kFont12];
        descLabel = [self labelWithFrame:CGRectMake(dbLabel.right+5, leftImgview.top, dssize.width+2, leftImgview.height) text:cellData.dataDesc textFont:kFont12 textColor:RGBCOLOR(231, 174, 20)];
        [self addSubview:descLabel];
    }
    NSString *btit = nil;
    if(cellData.isExchangeView)
    {
        btit = [NSString stringWithFormat:@"%@咚果",cellData.RMBCount];
    }
    else
    {
        btit = [NSString stringWithFormat:@"%@元 ",cellData.RMBCount];
    }
    CGSize tsize = [btit sizeWithFont:kFont12];
    bt = [self buttonWithFrame:CGRectMake(kMainScreenWidth-10-tsize.width-15, (self.height-27)/2, tsize.width+15, 27) titleFont:kFont12 titleStateNorColor:RGBCOLOR(0x00, 0xd8, 0x98) titleStateNor:btit];
    bt.layer.borderWidth = kLineWidth;
    bt.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
    bt.layer.cornerRadius = 5.0f;
    [bt addTarget:self action:@selector(buyButtonItem) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bt];
}

- (void)buyButtonItem
{
    if(self.buyButtonClick)
    {
        self.buyButtonClick(cellData);
    }
}

@end
