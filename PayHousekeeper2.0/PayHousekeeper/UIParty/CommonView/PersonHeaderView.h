//
//  PersonHeaderView.h
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonHeaderModel.h"


@interface PersonHeaderView : UIView

@property (nonatomic, strong) PersonHeaderModel *headerModel;
@property (nonatomic, strong) UIButton          *headerBtn;
@property (nonatomic, strong) UIButton          *attentionBtn;
//@property (nonatomic, strong) UITextField       *feelingTextField;
@property (nonatomic, strong) NSString          *feeling;
@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UILabel           *connectTipLab;
@property (nonatomic, strong) UILabel           *nameLabel;

- (instancetype)initWithFrame:(CGRect)frame headerModel:(PersonHeaderModel*)headerModel;

- (void)needToShowTipLab:(BOOL)isShow andShowContent:(NSString *)content;

- (void)refresh:(PersonHeaderModel*)headerModel;
@end
