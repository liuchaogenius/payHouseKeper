//
//  UIViewAdaptive.h
//  PayHousekeeper
//
//  Created by sp on 2017/1/8.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    RatioBaseOn_5,   // 基于5的适配
    RatioBaseOn_6,   // 基于6的适配，在5上不缩放
    RatioBaseOn_6_ScaleFor5, // 基于6适配，在5上缩放
}RatioBaseOnType;

#define FitScale_5  1
#define FitScale_6  1.0625
#define FitScale_6P 1.08675

// 屏幕比例适配
#define ScreenRatio(x)      (x*[UIView getTPScreenRatio])
#define ScreenRatioScreen5H(x)      (x* [UIView getTPScreenRatioWith5H])
#define ScreenAdaptation(x)    ((IsSmallScreen) ?  ScreenRatioScreen5H(x) : ScreenRatio(x))
#define ScreenRatioFont(x)  ([UIView getTPScreenRatioFont:x])

// 按特定比例适配6,6Plus
#define FitScale       ([UIView getTPFitScale:self])

#define FitSize(x)     ((x)*FitScale)
#define FitFont(x)     ( [UIView getTPFitFont:x :self])

@interface  UIView (utils)


+(CGFloat) getRedgiftRatio:(id)obj;
+(CGFloat) getTPScreenW;
+(CGFloat) getTPScreenH;


+(CGFloat) getTPFitScale:(id)obj;
+(CGFloat) getTPScreenRatio;
+(CGFloat) getTPScreenRatioWith5H;
+(UIFont*) getTPScreenRatioFont:(CGFloat) size;

+(UIFont*) getTPFitFont:(CGFloat)size :(id)obj;

@end

@interface NSObject (RatioFit)
-(void)setBaseRatio:(RatioBaseOnType)baseType;
-(RatioBaseOnType)baseRatio;
@end
