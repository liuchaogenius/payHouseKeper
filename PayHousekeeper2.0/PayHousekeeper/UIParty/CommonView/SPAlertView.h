//
//  SPAlertView.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/24.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPAlertViewDelegate <NSObject>

@optional
// 点击按钮下标时传递参数
- (void)didSelectAlertButton:(NSString *)title;
@end

@interface SPAlertView : UIView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id<SPAlertViewDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)okButtonTitle;

@property (nonatomic,weak) id <SPAlertViewDelegate> delegate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *cancelButtonTitle;
@property (nonatomic,copy) NSString *okButtonTitle;

- (void)show;
- (void)dismiss;



@end
