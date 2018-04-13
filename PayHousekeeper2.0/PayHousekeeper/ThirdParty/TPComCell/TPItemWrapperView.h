//
//  TPItemWrapper.h
//  cft
//
//  Created by striveliu on 16/7/20.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPItemWrapperView : UIView
//类似个人中心cell的样式数据
@property (nonatomic, strong)UILabel *leftLabel;
@property (nonatomic, strong)UILabel *rightLabel;
@property (nonatomic, strong)UIButton *arrowBt;
@property (nonatomic, strong)UIImageView *redImgview;

//好友列表cell的样式
@property (nonatomic, strong)UIImageView *headImgview;
@property (nonatomic, strong)UILabel *nicklabel;
@property (nonatomic, strong)UILabel *statusLabel;
@property (nonatomic, strong)UILabel *isQQFriendLabel;

//转账类型的cell样式数据
@property (nonatomic, strong)UIImageView *transferImgview;
@property (nonatomic, strong)UILabel *transferNameLabel;

//转账记录cell样式控件
@property (nonatomic, strong)UILabel *transferRecordNameLabel;
@property (nonatomic, strong)UILabel *transferRecordTimerLabel;
@property (nonatomic, strong)UILabel *transferRecordMoneyLabel;
@property (nonatomic, strong)UILabel *transferRecordStatusLabel;

//cell的各种线
@property (nonatomic, strong)UIView *topLine;
@property (nonatomic, strong)UIView *bottomLine;
@property (nonatomic, strong)UIView *topMarginLine;
@property (nonatomic, strong)UIView *bottomMarginLine;
@property (nonatomic, strong)UIView *imgBottomMarginline;
@end
