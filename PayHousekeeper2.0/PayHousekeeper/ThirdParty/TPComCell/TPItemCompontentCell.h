//
//  TPItemCompontentCell.h
//  cft
//
//  Created by striveliu on 16/7/20.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPItemWrapperView.h"
@class TPItemBuilder;
#define kHeadimgsize  40
#define kSectionHeight  15
@interface TPItemCompontentCell : UITableViewCell

@property (nonatomic, strong)TPItemWrapperView *wrapper;
/*****
*构造个人中心的cell的基本view
*
***/
+ (instancetype)itemPersonCellWithBlock:(UITableViewCellStyle)style
                        reuseIdentifier:(NSString *)reuseIdentifier
                             cellHeight:(CGFloat)aCellHeight
                             buildBlock:(void(^)(TPItemBuilder *builder))aBlock;
/**
 *  生成好友列表cell的样式
 *
 *  @param style
 *  @param reuseIdentifier
 *  @param aBlock
 *
 *  @return cell
 */
+ (instancetype)itemFriendCellWithBlock:(UITableViewCellStyle)style
                        reuseIdentifier:(NSString *)reuseIdentifier
                             cellHeight:(CGFloat)aCellHeight
                             buildBlock:(void(^)(TPItemBuilder *builder))aBlock;

/**
 *  生成转账类型的cell
 *
 *  @param style
 *  @param reuseIdentifier
 *  @param aBlock          
 *
 *  @return cell
 */
+ (instancetype)itemTransferTypeCellWithBlock:(UITableViewCellStyle)style
                              reuseIdentifier:(NSString *)reuseIdentifier
                                   cellHeight:(CGFloat)aCellHeight
                                   buildBlock:(void(^)(TPItemBuilder *builder))aBlock;

/**
 *  生成转账记录类型的cell
 *
 *  @param style
 *  @param reuseIdentifier
 *  @param aBlock
 *
 *  @return cell
 */
+ (instancetype)itemTransferRecordCellWithBlock:(UITableViewCellStyle)style
                                reuseIdentifier:(NSString *)reuseIdentifier
                                     cellHeight:(CGFloat)aCellHeight
                                     buildBlock:(void(^)(TPItemBuilder *builder))aBlock;

//更新左边内容
- (void)updateLeftContent:(NSString *)aContent;

//更新右边内容
- (void)updateRightContent:(NSString *)aContent;

//小红点更新
- (void)hiddenRedPoint:(BOOL)aIsHidden;

//右边的尖头
- (void)hiddenArrow:(BOOL)aIsHiddenArrow;

//更新好友cell的头像
- (void)updateHeadImgview:(NSString *)aHeadImgName;

//更新nick
- (void)updateNick:(NSString *)aNick;

//更新好友是否在线状态
- (void)updateStatus:(NSString *)aStatus;

//更好转账类型的headimgview
- (void)updateTransferHeadImgview:(NSString *)aImgName;

//更新转账类型的名字
- (void)updateTransferTypeName:(NSString * )aTransferTypeName;

//更新cell顶部的分割线
- (void)updateTopLine:(BOOL)aIsShowLine;

//更新cell底部的分割线
- (void)updateBottomLine:(BOOL)aIsShowLine;

//更新cell margin顶部的分割线
- (void)updateTopMarginLine:(BOOL)aIsShowLine;

//更新cell margin底部的分割线
- (void)updateBottomMarginLine:(BOOL)aIsShowLine;

//更新cell imgBottomMargin底部线
- (void)updateImgBottomMarginLine:(BOOL)aIsShowLine;

//更新是否是qq好友
- (void)updateIsQQFriend:(BOOL)aIsQQFriend;

//更新转账记录的名字
- (void)updateTransferRecordName:(NSString *)aName;

//更新转账记录的时间
- (void)updateTransferRecordTimer:(NSString *)aTimer;

//更新转账记录的金额
- (void)updateTransferRecordMoney:(NSString *)aMoney;

//更新转账记录的状态
- (void)updateTransferRecordStatus:(NSString *)aStatus;
@end
