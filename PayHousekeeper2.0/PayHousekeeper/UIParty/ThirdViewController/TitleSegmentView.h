//
//  TitleSegmentView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/14.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TitleViewClick)(int index);

@interface TitleSegmentView : UIView
@property (nonatomic,readonly) int index;
@property (copy)    TitleViewClick clickTitle;

- (id)initWithTitleArr:(NSArray *)titleArr normalImage:(UIImage *)normalImg selectedImage:(UIImage *)selectedImg;

- (void)switchBtn:(int)index;
@end
