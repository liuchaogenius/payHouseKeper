//
//  DDAlertView.h
//  DongDong
//
//  Created by BY on 2017/3/26.
//  Copyright © 2017年 BestLife. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BlackAlertViewTypeNormal = 0, // 没有标题 只有说明文字和底部按钮
    BlackAlertViewTypeTitle, // 标题为普通文字
    BlackAlertViewTypeCallHead, // 标题为呼叫的圆头像
    BlackAlertViewTypeTime // 标题为时间数字
} DDAlertViewTitleType; // 标题类型


@class ManGodView;

@protocol DDAlertViewDelegate <NSObject>

@optional
- (void)alerViewDidBtnClicked:(UIButton *)btn;

@end


@interface DDAlertView : UIView
@property (nonatomic, weak)id<DDAlertViewDelegate> delegate;
/*
    title: 头部主标题，没有标题时传nil即可
    headStr: 头像地址 不是BlackAlertViewTypeCallHead类型时传nil即可
    detailsStr: 中间内容，传nil时会使用valueArray值  优先级：detailsStr > valueArray
    valueArray: 显示剩余咚币和可聊时长的数据，detailsStr只需传nil
    closeStr / nextStr 为底部按钮title
    translucency: 是否需要黑色的半透明背景
    DDAlertViewTitleType: 主标题枚举型
 */
- (instancetype)initWithTitleText:(NSString *)title headUrlStr:(NSString *)headStr valueArray:(NSArray<NSString *> *)valueArray detailsText:(NSString *)detailsStr closeText:(NSString *)closeStr nextText:(NSString *)nextStr translucencyBackground:(BOOL)translucency  type:(DDAlertViewTitleType)DDAlertViewTitleType;

- (void)show;
- (void)removeAlerView;
@end
