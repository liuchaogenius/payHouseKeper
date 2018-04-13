//
//  PersonInfoModifyCell.h
//  PayHousekeeper
//
//  Created by 1 on 2016/11/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonInfoModifyCell : UITableViewCell

@property (nonatomic, strong)UIView *lineView;

- (void)updateHeadImg:(UIImage *)aImg;
- (void)updateNick:(NSString *)aNick;

- (void)setCellLeftContent:(NSString *)aLeftContent
             isHeadImgCell:(BOOL)aIsHeadCell
              rightContent:(NSString *)aRightContent
                   isArrow:(BOOL)aIsArrow
                isHeadView:(BOOL)aIsheadview
                headImgUrl:(NSString *)aHeadImgurl;

@end
