//
//  PersonVIPCell.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/8.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyVIPData : NSObject
@property (nonatomic) BOOL isRecommend;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *moneyCount;
@property (nonatomic, strong) NSString *dataId;
@property (nonatomic) BOOL isLasteCell;
@property (nonatomic, strong) NSString *appleProductId; //苹果内购id
@property (nonatomic, strong) NSString *appleReceipt; //苹果内购支付成功票据
@end

@interface PersonVIPCell : UITableViewCell
@property (nonatomic, assign)BOOL imgH;
- (void)setCellData:(BuyVIPData*)aData buyItem:(void(^)(BuyVIPData *data))aBlock;

@end
