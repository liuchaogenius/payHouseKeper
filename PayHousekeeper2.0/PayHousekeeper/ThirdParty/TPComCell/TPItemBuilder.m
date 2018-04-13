//
//  TPItemBuilder.m
//  cft
//
//  Created by striveliu on 16/7/20.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import "TPItemBuilder.h"
#import "TPItemCompontentCell.h"
#import "TPItemWrapperView.h"
#import "UIImageView+WebCache.h"
#define Screen_Width kMainScreenWidth
#define Comm_Content_Margin 15
#define kBigFontsize 16
#define kMiddleFontsize 14
#define kMiddleFontHeight kMiddleFontsize+2
#define kBigFontHeight kBigFontsize+2
@implementation TPItemBuilder
- (instancetype)init
{
    if(self = [super init])
    {
        self.isHiddenArrow = YES;
    }
    return self;
}
#pragma mark 构造类似个人中心cell的样式
- (TPItemCompontentCell *)buildPersonTableCell:(UITableViewCellStyle)style
                          reuseIdentifier:(NSString *)reuseIdentifier
                               cellHeight:(CGFloat)aCellHeight
{
    TPItemCompontentCell *cell = [[TPItemCompontentCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.frame = CGRectMake(0, 0, Screen_Width, aCellHeight);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self createPersonCellview:cell cellHeight:aCellHeight];
    
    return cell;
}

- (void)createPersonCellview:(TPItemCompontentCell *)aCell cellHeight:(CGFloat)aCellHeight
{
    aCell.wrapper = [[TPItemWrapperView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, aCellHeight)];
    aCell.wrapper.backgroundColor = [UIColor whiteColor];
    if(self.viewBackgroundColor)
    {
        aCell.wrapper.backgroundColor = self.viewBackgroundColor;
    }
    [aCell addSubview:aCell.wrapper];
    CGFloat rightLabelOffsetx = Screen_Width-Comm_Content_Margin;
    int labelY = (aCellHeight-kBigFontsize)/2;
    int redPointX = Screen_Width-Comm_Content_Margin;
    if(self.leftContent)
    {
        aCell.wrapper.leftLabel = [aCell.wrapper labelWithFrame:CGRectMake(Comm_Content_Margin, labelY, Screen_Width/2, kBigFontHeight) text:self.leftContent textFont:[UIFont systemFontOfSize:kBigFontsize] textColor:RGBCOLOR(51, 51, 51)];
        if(self.leftTextColor)
        {
            aCell.wrapper.leftLabel.textColor = self.leftTextColor;
        }
        [aCell.wrapper addSubview:aCell.wrapper.leftLabel];
    }
    if(self.isHiddenArrow == NO)
    {
        UIImage *arrowImg = [UIImage imageNamed:@"personArrow"];
        aCell.wrapper.arrowBt = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width-Comm_Content_Margin-arrowImg.size.width, (aCellHeight-arrowImg.size.height)/2, arrowImg.size.width, arrowImg.size.height)];
        [aCell.wrapper.arrowBt setImage:arrowImg forState:UIControlStateNormal];
        aCell.wrapper.arrowBt.userInteractionEnabled = NO;
        [aCell.wrapper addSubview:aCell.wrapper.arrowBt];
        
        rightLabelOffsetx =aCell.wrapper.arrowBt.left-10;
        redPointX = rightLabelOffsetx;
    }
    
    if(self.rightContent)
    {
        CGSize size = [self.rightContent sizeWithFont:[UIFont systemFontOfSize:kBigFontsize]];
        aCell.wrapper.rightLabel=[aCell labelWithFrame:CGRectMake(rightLabelOffsetx-size.width, labelY, size.width+2, kBigFontHeight) text:self.rightContent textFont:[UIFont systemFontOfSize:kBigFontsize] textColor:kFColorLightBlue];
        [aCell.wrapper addSubview:aCell.wrapper.rightLabel];
        
        redPointX = aCell.wrapper.rightLabel.left-5;
    }
    if(self.isRightConRed)
    {
        aCell.wrapper.redImgview = [[UIImageView alloc] initWithFrame:CGRectMake(redPointX-10, (aCellHeight-10)/2, 10, 10)];
        aCell.wrapper.redImgview.backgroundColor = [UIColor redColor];
        aCell.wrapper.redImgview.layer.cornerRadius = aCell.wrapper.redImgview.width/2;
        aCell.wrapper.redImgview.layer.masksToBounds = YES;
        [aCell.wrapper addSubview:aCell.wrapper.redImgview];
    }
    [self addCellLine:aCell cellHeight:aCellHeight];
}

#pragma mark 构造类似好友列表样式的cell
- (TPItemCompontentCell *)buildFriendTableCell:(UITableViewCellStyle)style
                          reuseIdentifier:(NSString *)reuseIdentifier
                               cellHeight:(CGFloat)aCellHeight
{
    TPItemCompontentCell *cell = [[TPItemCompontentCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.frame = CGRectMake(0, 0, Screen_Width, aCellHeight);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self createFriendCellview:cell cellHeight:aCellHeight];
    return cell;
}

- (void)createFriendCellview:(TPItemCompontentCell *)aCell cellHeight:(CGFloat)aCellHeight
{
    int offsetX = Comm_Content_Margin;
    int fontsize = 15;
    int sigFontsize = 18;
    int offsetY = (aCellHeight- fontsize - fontsize - 5)/2;
    aCell.wrapper = [[TPItemWrapperView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, aCellHeight)];
    aCell.wrapper.backgroundColor = [UIColor whiteColor];
    [aCell addSubview:aCell.wrapper];
    if((self.headImgUrl && self.headImgUrl.length > 0) || (self.headImgName && self.headImgName.length>0))
    {
        int imgsize = kHeadimgsize;
        aCell.wrapper.headImgview = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, (aCellHeight-imgsize)/2, imgsize, imgsize)];
        if((self.headImgUrl && self.headImgUrl.length > 0))
        {
            [aCell.wrapper.headImgview sd_setImageWithURL:[NSURL URLWithString:self.headImgUrl] placeholderImage:nil];
        }
        else
        {
            [aCell.wrapper.headImgview setImage:[UIImage imageNamed:self.headImgName]];
        }
        aCell.wrapper.headImgview.layer.cornerRadius = imgsize/2;
        aCell.wrapper.headImgview.layer.masksToBounds = YES;
        [aCell.wrapper addSubview:aCell.wrapper.headImgview];
        
        offsetX = aCell.wrapper.headImgview.right+10;
    }
    if(self.nick && self.nick.length > 0)
    {
        aCell.wrapper.nicklabel = [aCell labelWithFrame:CGRectMake(offsetX, offsetY, Screen_Width-offsetX-Comm_Content_Margin, fontsize) text:self.nick textFont:[UIFont systemFontOfSize:fontsize] textColor:RGBCOLOR(51, 51, 51)];
        [aCell.wrapper addSubview:aCell.wrapper.nicklabel];
    }
    if(self.isHiddenArrow == NO)
    {
        UIImage *arrowImg = [UIImage imageNamed:@"personArrow"];
        aCell.wrapper.arrowBt = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width-Comm_Content_Margin-arrowImg.size.width, (aCellHeight-arrowImg.size.height)/2, arrowImg.size.width, arrowImg.size.height)];
        [aCell.wrapper.arrowBt setImage:arrowImg forState:UIControlStateNormal];
        aCell.wrapper.arrowBt.userInteractionEnabled = NO;
        [aCell.wrapper addSubview:aCell.wrapper.arrowBt];
    }
    if(self.status && self.status.length > 0)
    {
        aCell.wrapper.statusLabel = [aCell labelWithFrame:CGRectMake(offsetX, aCell.wrapper.nicklabel.bottom+5, Screen_Width-offsetX-Comm_Content_Margin, fontsize) text:self.status textFont:[UIFont systemFontOfSize:fontsize] textColor:[UIColor grayColor]];
        [aCell.wrapper addSubview:aCell.wrapper.statusLabel];
    }
    else
    {
        offsetY = (aCellHeight- sigFontsize)/2;
        aCell.wrapper.nicklabel.frame = CGRectMake(offsetX, offsetY, Screen_Width-offsetX-Comm_Content_Margin, sigFontsize);
        aCell.wrapper.nicklabel.font = [UIFont systemFontOfSize:sigFontsize];
    }
    if(self.isQQFriend)
    {
        NSString *desc = @"QQ好友";
        CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:kMiddleFontsize]];
        aCell.wrapper.isQQFriendLabel = [aCell labelWithFrame:CGRectMake(Screen_Width-Comm_Content_Margin-size.width-2, (aCellHeight-kMiddleFontHeight)/2, size.width+4, kMiddleFontHeight+3) text:desc textFont:[UIFont systemFontOfSize:kMiddleFontsize] textColor:[UIColor redColor]];
        aCell.wrapper.isQQFriendLabel.layer.cornerRadius = 8.0f;
        aCell.wrapper.isQQFriendLabel.layer.masksToBounds = YES;
        aCell.wrapper.isQQFriendLabel.backgroundColor = kFColorLightBlue;
        aCell.wrapper.isQQFriendLabel.textAlignment = NSTextAlignmentCenter;
        [aCell.wrapper addSubview:aCell.wrapper.isQQFriendLabel];
    }
    [self addCellLine:aCell cellHeight:aCellHeight];
}

#pragma mark转账类型的cell,如转账到银行卡  图片＋名字
- (TPItemCompontentCell *)buildTransferTableCell:(UITableViewCellStyle)style
                                reuseIdentifier:(NSString *)reuseIdentifier
                                     cellHeight:(CGFloat)aCellHeight
{
    TPItemCompontentCell *cell = [[TPItemCompontentCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.frame = CGRectMake(0, 0, Screen_Width, aCellHeight);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self createTransferCellview:cell cellHeight:aCellHeight];
    return cell;
}
- (void)createTransferCellview:(TPItemCompontentCell *)aCell cellHeight:(CGFloat)aCellHeight
{
    aCell.wrapper = [[TPItemWrapperView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, aCellHeight)];
    aCell.wrapper.backgroundColor = [UIColor whiteColor];
    [aCell addSubview:aCell.wrapper];
    int offsetX = Comm_Content_Margin;
    if(self.transferHeadImgName)
    {
        aCell.wrapper.transferImgview = [[UIImageView alloc] initWithFrame:CGRectMake(Comm_Content_Margin, (aCellHeight-kHeadimgsize)/2, kHeadimgsize, kHeadimgsize)];
        aCell.wrapper.transferImgview.layer.cornerRadius = kHeadimgsize/2;
        aCell.wrapper.transferImgview.layer.masksToBounds = YES;
        [aCell.wrapper.transferImgview setImage:[UIImage imageNamed:self.transferHeadImgName]];
        [aCell.wrapper addSubview:aCell.wrapper.transferImgview];
        offsetX = aCell.wrapper.transferImgview.right+8;
    }
    if(self.transferName)
    {
        aCell.wrapper.transferNameLabel = [aCell labelWithFrame:CGRectMake(offsetX, (aCellHeight-kBigFontsize)/2, Screen_Width-offsetX-Comm_Content_Margin, kBigFontHeight) text:self.transferName textFont:[UIFont systemFontOfSize:kBigFontsize] textColor:RGBCOLOR(51, 51, 51)];
        [aCell.wrapper addSubview:aCell.wrapper.transferNameLabel];
    }
    [self addCellLine:aCell cellHeight:aCellHeight];
}

#pragma mark 构造转账记录的cell
- (TPItemCompontentCell *)buildTransferRecordTableCell:(UITableViewCellStyle)style
                                       reuseIdentifier:(NSString *)reuseIdentifier
                                            cellHeight:(CGFloat)aCellHeight
{
    TPItemCompontentCell *cell = [[TPItemCompontentCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.frame = CGRectMake(0, 0, Screen_Width, aCellHeight);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self createTransferRecordCell:cell cellHeight:aCellHeight];
    return cell;
}

- (void)createTransferRecordCell:(TPItemCompontentCell *)aCell cellHeight:(CGFloat)aCellHeight
{
    int nameFontsize = kMiddleFontHeight;
    int timeFontsize = 12;
    int moneyFontsize = 18;
    int statusFontsize = 12;
    UIColor *blackColor = RGBCOLOR(51, 51, 51);
    UIColor *grayColor = RGBCOLOR(187, 187, 187);
    aCell.wrapper = [[TPItemWrapperView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, aCellHeight)];
    aCell.wrapper.backgroundColor = [UIColor whiteColor];
    [aCell addSubview:aCell.wrapper];
    int offsetX = Comm_Content_Margin;
    int offsetY = (aCellHeight-nameFontsize-timeFontsize-3)/2;
    int labelwidth = (Screen_Width-offsetX*2)/2;
    aCell.wrapper.transferRecordNameLabel = [aCell labelWithFrame:CGRectMake(offsetX, offsetY, labelwidth, nameFontsize) text:self.transferRecordName textFont:[UIFont systemFontOfSize:nameFontsize] textColor:blackColor];
    [aCell.wrapper addSubview:aCell.wrapper.transferRecordNameLabel];
    
    aCell.wrapper.transferRecordTimerLabel = [aCell labelWithFrame:CGRectMake(offsetX, aCell.wrapper.transferRecordNameLabel.bottom+3, labelwidth, timeFontsize) text:self.transferRecordTimer textFont:[UIFont systemFontOfSize:timeFontsize] textColor:grayColor];
    [aCell.wrapper addSubview:aCell.wrapper.transferRecordTimerLabel];

    aCell.wrapper.transferRecordMoneyLabel = [aCell labelWithFrame:CGRectMake(Screen_Width-Comm_Content_Margin-labelwidth, offsetY, labelwidth, moneyFontsize) text:self.transferRecordMoney textFont:[UIFont boldSystemFontOfSize:moneyFontsize] textColor:blackColor];
    aCell.wrapper.transferRecordMoneyLabel.textAlignment = NSTextAlignmentRight;
    [aCell.wrapper addSubview:aCell.wrapper.transferRecordMoneyLabel];
    
    aCell.wrapper.transferRecordStatusLabel = [aCell labelWithFrame:CGRectMake(Screen_Width-Comm_Content_Margin-labelwidth, aCell.wrapper.transferRecordMoneyLabel.bottom+3, labelwidth, statusFontsize) text:self.transferRecordStatus textFont:[UIFont systemFontOfSize:statusFontsize] textColor:grayColor];
    if([self.transferRecordStatus compare:@"已退款"] == 0)
    {
        aCell.wrapper.transferRecordStatusLabel.textColor = RGBCOLOR(226, 0, 0);
    }
    aCell.wrapper.transferRecordStatusLabel.textAlignment = NSTextAlignmentRight;
    [aCell.wrapper addSubview:aCell.wrapper.transferRecordStatusLabel];
    
    [self addCellLine:aCell cellHeight:aCellHeight];
}

#pragma mark 添加cell线
- (void)addCellLine:(TPItemCompontentCell *)aCell cellHeight:(CGFloat)aCellHeight
{
    if(self.isTopLine)
    {
        aCell.wrapper.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kLineWidth)] ;
        aCell.wrapper.topLine.backgroundColor = kLineColor;
        [aCell.wrapper addSubview:aCell.wrapper.topLine];
    }
    if(self.isBottomLine)
    {
        aCell.wrapper.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, aCellHeight-kLineWidth, Screen_Width, kLineWidth + 1)] ;
        aCell.wrapper.bottomLine.backgroundColor = kFTableViewColor;
        [aCell.wrapper addSubview:aCell.wrapper.bottomLine];
    }
    if(self.isTopMarginLine)
    {
        aCell.wrapper.topMarginLine = [[UIView alloc] initWithFrame:CGRectMake(Comm_Content_Margin, 0, Screen_Width-Comm_Content_Margin, kLineWidth)] ;
        aCell.wrapper.topMarginLine.backgroundColor = kLineColor;
        [aCell.wrapper addSubview:aCell.wrapper.topMarginLine];
    }
    if(self.isBottomMarginLine)
    {
        aCell.wrapper.bottomMarginLine = [[UIView alloc] initWithFrame:CGRectMake(Comm_Content_Margin, aCellHeight-kLineWidth, Screen_Width-Comm_Content_Margin, kLineWidth)] ;
        aCell.wrapper.bottomMarginLine.backgroundColor = kLineColor;
        [aCell.wrapper addSubview:aCell.wrapper.bottomMarginLine];
    }
    if(self.isImageMarginLine)
    {
        aCell.wrapper.imgBottomMarginline = [[UIView alloc] initWithFrame:CGRectMake(kHeadimgsize+5+Comm_Content_Margin, aCellHeight-kLineWidth, Screen_Width-(kHeadimgsize+10), kLineWidth)] ;
        aCell.wrapper.imgBottomMarginline.backgroundColor = kLineColor;
        [aCell.wrapper addSubview:aCell.wrapper.imgBottomMarginline];
    }
}

@end
