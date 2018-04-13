//
//  PersonSettingCell.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/12/10.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonSettingCell : UITableViewCell
@property (nonatomic)BOOL islogout;
- (void)setCellData:(NSString *)aLeftContent righcontent:(NSString *)aRightContent;

@end
