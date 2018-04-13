//
//  ImpressionAlertView.h
//  PayHousekeeper
//
//  Created by BY on 2017/3/27.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImpressionAlertViewDelegate <NSObject>
@optional
- (void)impressionViewDidBtnClicked:(NSArray *)textArr;
@end


@interface BQButton : UIButton

@end

@interface ImpressionAlertView : UIView
@property (nonatomic, weak)id<ImpressionAlertViewDelegate> delegate;

// isSelf 是否为自己参数暂时没有做具体的业务处理
- (instancetype)initTimeStr:(NSString *)timeStr dongbiCount:(NSString *)dbCount tagArrray:(NSArray *)tagArr isSelf:(BOOL)isSelf;
- (void)show;
- (void)removeAlerView;
@end
