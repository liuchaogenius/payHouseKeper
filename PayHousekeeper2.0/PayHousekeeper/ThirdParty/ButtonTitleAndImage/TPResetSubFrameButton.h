//
//  TPResetSubFrameButton.h
//  cft
//
//  Created by springxiao on 16/8/9.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPResetSubFrameButton : UIButton

/*!
 *  @author tenpay, 16-08-09 18:08:27
 *
 *  @brief 水平布局Button
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CGFloat imageX;

@property (nonatomic, assign) CGFloat labelX;

@property (nonatomic, assign) CGFloat labelOffsetX; //相对image右边间隔



/*!
 *  @author tenpay, 16-08-09 18:08:20
 *
 *  @brief 竖直布局Button
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CGFloat imageY;

@property (nonatomic, assign) CGFloat labelY;

@property (nonatomic, assign) CGFloat labelOffsetY; //相对image底部间隔


/*!
 *  @author tenpay, 16-08-09 18:08:20
 *
 *  @brief 直接设置布局Frame
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CGRect imageFrame;

@property (nonatomic, assign) CGRect labelFrame;

@end
