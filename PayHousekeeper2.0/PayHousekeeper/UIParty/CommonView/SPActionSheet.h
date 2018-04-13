//
//  SPActionSheet.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/24.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SPActionSheetDelegate <NSObject>

@optional
// 点击按钮下标时传递参数
- (void)didSelectActionSheetButton:(NSString *)title;
@end

@interface SPActionSheet : UIView
- (instancetype)initWithTitle:(NSString *)title
                   dismissMsg:(NSString *)message
                     delegate:(id<SPActionSheetDelegate>)delegate
                 buttonTitles:(NSArray *)buttonTitles;

@property (nonatomic,weak)   id <SPActionSheetDelegate> delegate;
@property (nonatomic,copy)   NSString *title;
@property (nonatomic,copy)   NSString *dismissMsg;
@property (nonatomic,strong) NSArray *buttonTitles;

@property (nonatomic,strong) UIFont  *contentBtnFont;//默认字体黑色
@property (nonatomic,strong) UIColor *titleColor;//默认字体灰色
@property (nonatomic,strong) UIColor *contentBtnColor;//默认字体黑色
@property (nonatomic,strong) UIColor *dismissBtnColor;//默认字体灰色

@property (nonatomic,strong) UIColor *titleBackgroundColor;//默认背景白色
@property (nonatomic,strong) UIColor *contentBackgroundBtnColor;//默认背景白色
@property (nonatomic,strong) UIColor *dismissBackgroundBtnColor;//默认背景白色


- (void)show;
- (void)dismiss;
@end
