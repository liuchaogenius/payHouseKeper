//
//  TQActionSheet.h
//  PayHousekeeper
//
//  Created by BY on 2017/3/25.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TQActionSheetDelegate <NSObject>

@optional
// 点击按钮下标时传递参数
- (void)didSelectActionSheetButton:(NSString *)title;
@end

@interface TQActionSheet : UIView
@property (nonatomic,weak) id <TQActionSheetDelegate> delegate;
- (instancetype)initWithTitle:(NSString *)title columnTitles:(NSArray *)allTitleArr
                   dismissMsg:(NSString *)message
                     delegate:(id<TQActionSheetDelegate>)delegate;
- (void)show;
@end
