//
//  TPItemBuilder.h
//  cft
//
//  Created by striveliu on 16/7/20.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPItemCompontentCell;

@interface TPItemBuilder : NSObject

//cell里面的分割线的位置
@property (nonatomic)BOOL isTopLine;
@property (nonatomic)BOOL isBottomLine;
@property (nonatomic)BOOL isTopMarginLine;
@property (nonatomic)BOOL isBottomMarginLine;
@property (nonatomic)BOOL isImageMarginLine;
//类似个人中心cell的样式数据
@property (nonatomic, strong)NSString *leftContent;
@property (nonatomic, strong)NSString *rightContent;
@property (nonatomic)BOOL isRightConRed;
@property (nonatomic)BOOL isHiddenArrow; //默认是yes 隐藏的
@property (nonatomic, strong)UIColor *leftTextColor;
@property (nonatomic, strong)UIColor *rightTextColor;
@property (nonatomic, strong)UIColor *viewBackgroundColor;

//好友列表cell的样式数据
@property (nonatomic, strong)NSString *headImgUrl;
@property (nonatomic, strong)NSString *headImgName;
@property (nonatomic, strong)NSString *nick;
@property (nonatomic, strong)NSString *status;//在线or不在线
@property (nonatomic)BOOL isQQFriend;

//转账类型的cell样式数据
@property (nonatomic, strong)NSString *transferHeadImgName;
@property (nonatomic, strong)NSString *transferName;

//转账记录cell样式数据
@property (nonatomic, strong)NSString *transferRecordName;
@property (nonatomic, strong)NSString *transferRecordTimer;
@property (nonatomic, strong)NSString *transferRecordMoney;
@property (nonatomic, strong)NSString *transferRecordStatus;

- (TPItemCompontentCell *)buildPersonTableCell:(UITableViewCellStyle)style
                               reuseIdentifier:(NSString *)reuseIdentifier
                                    cellHeight:(CGFloat)aCellHeight;

- (TPItemCompontentCell *)buildFriendTableCell:(UITableViewCellStyle)style
                               reuseIdentifier:(NSString *)reuseIdentifier
                                    cellHeight:(CGFloat)aCellHeight;

- (TPItemCompontentCell *)buildTransferTableCell:(UITableViewCellStyle)style
                                 reuseIdentifier:(NSString *)reuseIdentifier
                                      cellHeight:(CGFloat)aCellHeight;

- (TPItemCompontentCell *)buildTransferRecordTableCell:(UITableViewCellStyle)style
                                       reuseIdentifier:(NSString *)reuseIdentifier
                                            cellHeight:(CGFloat)aCellHeight;
@end
