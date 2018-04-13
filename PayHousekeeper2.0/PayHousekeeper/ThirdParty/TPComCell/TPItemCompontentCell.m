//
//  TPItemCompontentCell.m
//  cft
//
//  Created by striveliu on 16/7/20.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import "TPItemCompontentCell.h"
#import "TPItemBuilder.h"
#import "UIImageView+WebCache.h"
@implementation TPItemCompontentCell

+ (instancetype)itemPersonCellWithBlock:(UITableViewCellStyle)style
                           reuseIdentifier:(NSString *)reuseIdentifier
                             cellHeight:(CGFloat)aCellHeight
                                buildBlock:(void(^)(TPItemBuilder *builder))aBlock
{
    TPItemBuilder *builder = [[TPItemBuilder alloc] init];
    aBlock(builder);
    return [builder buildPersonTableCell:style reuseIdentifier:reuseIdentifier cellHeight:aCellHeight];
}


+ (instancetype)itemFriendCellWithBlock:(UITableViewCellStyle)style
                        reuseIdentifier:(NSString *)reuseIdentifier
                             cellHeight:(CGFloat)aCellHeight
                             buildBlock:(void(^)(TPItemBuilder *builder))aBlock
{
    TPItemBuilder *builder = [[TPItemBuilder alloc] init];
    aBlock(builder);
    return [builder buildFriendTableCell:style reuseIdentifier:reuseIdentifier cellHeight:aCellHeight];
}

+ (instancetype)itemTransferTypeCellWithBlock:(UITableViewCellStyle)style
                        reuseIdentifier:(NSString *)reuseIdentifier
                             cellHeight:(CGFloat)aCellHeight
                             buildBlock:(void(^)(TPItemBuilder *builder))aBlock
{
    TPItemBuilder *builder = [[TPItemBuilder alloc] init];
    aBlock(builder);
    return [builder buildTransferTableCell:style reuseIdentifier:reuseIdentifier cellHeight:aCellHeight];
}

+ (instancetype)itemTransferRecordCellWithBlock:(UITableViewCellStyle)style
                                reuseIdentifier:(NSString *)reuseIdentifier
                                     cellHeight:(CGFloat)aCellHeight
                                     buildBlock:(void(^)(TPItemBuilder *builder))aBlock
{
    TPItemBuilder *builder = [[TPItemBuilder alloc] init];
    aBlock(builder);
    return [builder buildTransferRecordTableCell:style reuseIdentifier:reuseIdentifier cellHeight:aCellHeight];
}

- (void)updateLeftContent:(NSString *)aContent
{
    if(aContent && aContent.length > 0)
    {
        self.wrapper.leftLabel.text = aContent;
    }
    else
    {
        self.wrapper.leftLabel.text = @"";
    }
}
- (void)updateRightContent:(NSString *)aContent
{
    if(aContent && aContent.length > 0)
    {
        self.wrapper.rightLabel.text = aContent;
    }
    else
    {
        self.wrapper.rightLabel.text = @"";
    }
}
- (void)hiddenRedPoint:(BOOL)aIsHidden
{
    self.wrapper.redImgview.hidden = aIsHidden;
}
- (void)hiddenArrow:(BOOL)aIsHiddenArrow
{
    self.wrapper.arrowBt.hidden = aIsHiddenArrow;
}
- (void)updateHeadImgview:(NSString *)aHeadImgName
{
    if(aHeadImgName && aHeadImgName.length > 0)
    {
        [self.wrapper.headImgview sd_setImageWithURL:[NSURL URLWithString:aHeadImgName] placeholderImage:nil];
    }
    else
    {
        [self.wrapper.headImgview setImage:nil];
    }
}
- (void)updateNick:(NSString *)aNick
{
    if(aNick && aNick.length > 0)
    {
        self.wrapper.nicklabel.text = aNick;
    }
    else
    {
        self.wrapper.nicklabel.text = @"";
    }
}
- (void)updateStatus:(NSString *)aStatus
{
    if(aStatus && aStatus.length > 0)
    {
        self.wrapper.statusLabel.text = aStatus;
    }
    else
    {
        self.wrapper.statusLabel.text = @"";
    }
}

- (void)updateTransferHeadImgview:(NSString *)aImgName
{
    [self.wrapper.transferImgview setImage:[UIImage imageNamed:aImgName]];
}

- (void)updateTransferTypeName:(NSString * )aTransferTypeName
{
    self.wrapper.transferNameLabel.text = aTransferTypeName;
}

- (void)updateTopLine:(BOOL)aIsShowLine
{
    self.wrapper.topLine.hidden = !aIsShowLine;
}

- (void)updateBottomLine:(BOOL)aIsShowLine
{
    self.wrapper.bottomLine.hidden = !aIsShowLine;
}

- (void)updateTopMarginLine:(BOOL)aIsShowLine
{
    self.wrapper.topMarginLine.hidden = !aIsShowLine;
}

- (void)updateBottomMarginLine:(BOOL)aIsShowLine
{
    self.wrapper.bottomMarginLine.hidden = !aIsShowLine;
}

- (void)updateImgBottomMarginLine:(BOOL)aIsShowLine
{
    self.wrapper.imgBottomMarginline.hidden = !aIsShowLine;
}

- (void)updateIsQQFriend:(BOOL)aIsQQFriend
{
    self.wrapper.isQQFriendLabel.hidden = !aIsQQFriend;
}

- (void)updateTransferRecordName:(NSString *)aName
{
    self.wrapper.transferRecordNameLabel.text = aName;
}

- (void)updateTransferRecordTimer:(NSString *)aTimer
{
    self.wrapper.transferRecordTimerLabel.text = aTimer;
}

- (void)updateTransferRecordMoney:(NSString *)aMoney
{
    self.wrapper.transferRecordMoneyLabel.text = aMoney;
}

- (void)updateTransferRecordStatus:(NSString *)aStatus
{
    self.wrapper.transferRecordStatusLabel.text = aStatus;
}
@end
