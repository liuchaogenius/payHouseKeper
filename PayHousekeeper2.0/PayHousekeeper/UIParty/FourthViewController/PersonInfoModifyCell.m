//
//  PersonInfoModifyCell.m
//  PayHousekeeper
//
//  Created by 1 on 2016/11/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonInfoModifyCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewAdaptive.h"

#define kRightspce 15

@interface PersonInfoModifyCell()
{
    NSString *leftContent;
    BOOL isHeadCell;
    NSString *rightContent;
    BOOL isArrow;
    NSString *headImgurl;
    
    UILabel *leftLabel;
    UIImageView *arrowimgview;
    UIImageView *imgview;
    UILabel *rightlabel;
    UIImage *defaultImg;
    BOOL isHeadview;
    UIView *headview;
}
@end

@implementation PersonInfoModifyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    if (self) {
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = RGBCOLOR(238, 238, 238);
        [self addSubview:self.lineView];
    }
    
    return self;
}

- (void)setCellLeftContent:(NSString *)aLeftContent
             isHeadImgCell:(BOOL)aIsHeadCell
              rightContent:(NSString *)aRightContent
                   isArrow:(BOOL)aIsArrow
                isHeadView:(BOOL)aIsheadview
                headImgUrl:(NSString *)aHeadImgurl
{
    leftContent = aLeftContent;
    isHeadCell = aIsHeadCell;
    rightContent = aRightContent;
    isArrow = aIsArrow;
    headImgurl = aHeadImgurl;
    isHeadview = aIsheadview;
}

- (void)updateHeadImg:(UIImage *)aImg
{
    defaultImg = aImg;
    headImgurl = nil;
    [imgview setImage:aImg];
}

- (void)updateNick:(NSString *)aNick
{
    
    rightContent = aNick;
    CGSize rightsize = [rightContent sizeWithFont:kFont15];
    if(rightsize.width>(self.width-15-15*2-100))
    {
        rightsize.width = (self.width-15-15*2-100);
    }
    
    rightlabel.frame = CGRectMake(self.width-15-15-rightsize.width-1-kRightspce, 0, rightsize.width+1, self.height);
    
    rightlabel.text = aNick;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self createCell];
}

- (void)createCell
{
    int offsetY = 0;
    if(isHeadview)
    {
        if(!headview)
        {
            headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 10)];
            headview.backgroundColor = kViewBackgroundHexColor;
            //            [self addSubview:headview];
        }
        headview.hidden = NO;
        offsetY = headview.bottom;
    }
    else
    {
        headview.hidden = YES;
        [headview removeFromSuperview];
        headview = nil;
        offsetY = 0;
    }
    if(!leftLabel)
    {
        leftLabel = [self labelWithFrame:CGRectMake(15, 0, 100, self.height) text:leftContent textFont:kFont15 textColor:RGBCOLOR(51, 51, 51)];
        [self addSubview:leftLabel];
    }
    leftLabel.text = leftContent;
    UIImage *arrowImg = nil;
    if(isArrow)
    {
        arrowImg = [UIImage imageNamed:@"personArrow"];
        if(!arrowimgview)
        {
            arrowimgview = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-15-arrowImg.size.width, (self.height-arrowImg.size.height)/2, arrowImg.size.width, arrowImg.size.height)];
            [self addSubview:arrowimgview];
        }
        [arrowimgview setImage:arrowImg];
    }
    else
    {
        arrowimgview.hidden = YES;
    }
    if(isHeadCell)
    {
        if(!imgview)
        {
            imgview = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-15-arrowImg.size.width-15-46, (self.height - 46) / 2, 46, 46)];
            [imgview sd_setImageWithURL:[NSURL URLWithString:headImgurl] placeholderImage:[UIImage imageNamed:@"personInfoheadimg"]];
            [self addSubview:imgview];
        }
        imgview.layer.cornerRadius = 23.f;
        imgview.layer.masksToBounds = YES;
        defaultImg = defaultImg?defaultImg:[UIImage imageNamed:@"personInfoheadimg"];
        [imgview sd_setImageWithURL:[NSURL URLWithString:headImgurl] placeholderImage:defaultImg];
    }
    
    if(rightContent)
    {
        CGSize rightsize = [rightContent sizeWithFont:kFont15];
        if(rightsize.width>(self.width-arrowImg.size.width-15*2-100))
        {
            rightsize.width = (self.width-arrowImg.size.width-15*2-100);
        }
        if(!rightlabel)
        {
            rightlabel = [self labelWithFrame:CGRectMake(self.width-arrowImg.size.width-15-rightsize.width-1-kRightspce, 0, rightsize.width+1, self.height) text:rightContent textFont:kFont15 textColor:[UIColor colorWithHexValue:0x999999]];
            [self addSubview:rightlabel];
        }
        rightlabel.text = rightContent;
        
    }
    
    self.lineView.frame = CGRectMake(0, self.frame.size.height - 1, [UIView getTPScreenW], 1);
}
@end
