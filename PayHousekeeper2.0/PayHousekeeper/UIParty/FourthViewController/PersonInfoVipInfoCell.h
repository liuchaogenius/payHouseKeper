//
//  PersonInfoVipInfoCell.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonInfoVipInfoCell : UITableViewCell
- (void)setCellData:(BOOL)aIsVip
            vipName:(NSString *)aVipName
           vipLevel:(int)aVipLevel
        buttonClick:(void(^)(int tag))aClickBlock;
@end
