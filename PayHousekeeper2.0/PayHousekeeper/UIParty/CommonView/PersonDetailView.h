//
//  PersonDetailView.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PersonDetailModel.h"

@interface PersonDetailView : UIView

@property (nonatomic, strong) PersonDetailModel *detailModel;
@property (nonatomic, strong) UIButton          *closeBtn;
@property (nonatomic, strong) UIButton          *leftBtn;
@property (nonatomic, strong) UIButton          *bottomBtn;
@property (nonatomic, strong) UIButton          *profitBtn;

- (instancetype)initWithDetailModel:(PersonDetailModel*)detailModel;
- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismiss;
@end
