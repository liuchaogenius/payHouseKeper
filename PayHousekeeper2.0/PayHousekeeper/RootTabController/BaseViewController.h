//
//  BaseViewController.h
//  FW_Project
//
//  Created by  striveliu on 13-10-3.
//  Copyright (c) 2013年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong)UIView *statusBarView;
@property (nonatomic, assign) CGFloat g_OffsetY;
@property (nonatomic, strong) UIImage *backgroundimg;
@property (nonatomic ,strong) UIButton *rightButton;
- (void)setLeftButton:(UIImage *)aImg
                title:(NSString *)aTitle
               target:(id)aTarget
               action:(SEL)aSelector;
- (void)setRightButton:(UIImage *)aImg title:(NSString *)aTitle titlecolor:(UIColor *)aTitleColor target:(id)aTarget action:(SEL)aSelector;
- (void)settitleLabel:(NSString*)aTitle;
- (void)pushView:(UIView*)aView;

- (void)popView:(UIView*)aView completeBlock:(void(^)(BOOL isComplete))aCompleteblock;

- (void)addCustomNavgationBar:(UIImage*)aLeftBtImg
                        title:(NSString*)aLeftBtTitle
                 leftBtAction:(SEL)aLeftBtAction
                   rightBtImg:(UIImage*)aRightBtImg
                        title:(NSString*)aRightBtTitle
                rightBtAction:(SEL)aRightAction
                  navBarTitle:(NSString *)aNavTitle
                  navBarColor:(UIColor *)aNavColor;

- (void)setNavgationBarClear;

- (void)back;

- (void)firstMovingToParentvc;

- (void)showViewOnMask:(UIView*)view;
- (void)dismissViewOnMask:(UIView *)view animated:(BOOL)animated;
- (void)onMaskViewClicked;

@end
