//
//  BindMobileCell.h
//  PayHousekeeper
//
//  Created by 1 on 2016/12/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindMobileCell : UITableViewCell
@property (nonatomic)BOOL isBind;
- (void)setCellDataIcon:(UIImage *)aIconImg
                  title:(NSString *)aTitle
                 isBind:(BOOL)aIsBind
                  index:(int)aIndex
             clickBlock:(void(^)(int index))aBlock;
@property (nonatomic, strong)UILabel *tLabel;
@property (nonatomic, weak)UIView *line;
@end
