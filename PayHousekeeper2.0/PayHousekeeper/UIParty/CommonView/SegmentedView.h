//
//  FindSliderView.h
//  DongDong
//
//  Created by BY on 2017/3/13.
//  Copyright © 2017年 BestLife. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoHighlightButton : UIButton

@end

@protocol SegmentedViewDelegate <NSObject>

@optional
- (void)segmentedViewDidClickedPlusButton:(NSInteger)tag;

@end

@interface SegmentedView : UIView

@property (nonatomic, weak) id<SegmentedViewDelegate> delegate;
- (instancetype)initWithTitleArr:(NSArray *)titleArr;

@end
