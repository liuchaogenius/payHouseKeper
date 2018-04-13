//
//  PersonInfoDongBiCell.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/7.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChongzhiDBData : NSObject
@property (nonatomic, strong) NSString *czdbNum; //充值的咚币数
@property (nonatomic, strong) NSString *dataId; //当前数据id
@property (nonatomic, strong) NSString *RMBCount;//人民币
@property (nonatomic, strong) NSString *dataDesc; //描述
@property (nonatomic, strong) NSString *appleProductId; //苹果内购id
@property (nonatomic, strong) NSString *appleReceipt; //苹果内购支付成功票据
@property (nonatomic) BOOL isYouhui;//是否有优惠
@property (nonatomic) BOOL isExchangeView;
@end

@interface PersonInfoDongBiCell : UITableViewCell

- (void)setCellData:(ChongzhiDBData *)aData;
- (void)setBuyButtonClickBlock:(void(^)(ChongzhiDBData *data))aBlock;
@end
