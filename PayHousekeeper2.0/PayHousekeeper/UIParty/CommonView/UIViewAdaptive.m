//
//  UIViewAdaptive.m
//  PayHousekeeper
//
//  Created by sp on 2017/1/8.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "UIViewAdaptive.h"
#import <objc/runtime.h> 
#import "Public.h"

#define Screen_Width     [UIView getTPScreenW]
#define Screen_Height    [UIView getTPScreenH]

@implementation UIView (utils)

+ (CGFloat)getRedgiftRatio:(id)obj
{
    if ([obj baseRatio] == RatioBaseOn_6_ScaleFor5)
    {
        return Screen_Width <= 320 ? ScreenW_5/(CGFloat)ScreenW_6 : (Screen_Width <= 375 ? 1 : ScreenW_6P/(CGFloat)ScreenW_6);
    }
    if ([obj baseRatio] == RatioBaseOn_6)
    {
        return Screen_Width <= 320 ? 1 : (Screen_Width <= 375 ? 1 : ScreenW_6P/(CGFloat)ScreenW_6);
    }
    
    return Screen_Width <= 320 ? 1 : (Screen_Width <= 375 ? 1.0714 : 1.1357);
}

+ (CGFloat)getTPScreenW
{
    UIScreen* screen = [UIScreen mainScreen];
    CGRect screenFrame = screen.bounds;
    CGFloat scrWidth = MIN(screenFrame.size.width, screenFrame.size.height);
    
    //解决在ipad中app启动时[UIScreen mainScreen].CZ_B_SizeW于768px的问题
    if (scrWidth >= 768) {
        scrWidth = 320 * (scrWidth / 768.0f);
    }
    return scrWidth;
    
}

+ (CGFloat)getTPScreenH
{
    UIScreen* screen = [UIScreen mainScreen];
    CGRect screenFrame = screen.bounds;
    CGFloat scrHeight = MAX(screenFrame.size.height, screenFrame.size.width);
    
    //解决在ipad中app启动时[UIScreen mainScreen].CZ_B_SizeH于1024x的问题
    if (scrHeight >= 1024) {
        scrHeight = 480 * (scrHeight / 1024.0f);
    }
    
    return scrHeight;
}


+ (CGFloat)getTPFitScale:(id)obj
{
    if ([obj baseRatio] == RatioBaseOn_6_ScaleFor5)
    {
        return Screen_Width <= 320 ? ScreenW_5/(CGFloat)ScreenW_6 : (Screen_Width <= 375 ? 1 : ScreenW_6P/(CGFloat)ScreenW_6);
    }
    if ([obj baseRatio] == RatioBaseOn_6)
    {
        return Screen_Width <= 320 ? 1 : (Screen_Width <= 375 ? 1 : ScreenW_6P/(CGFloat)ScreenW_6);
    }
    
    return [UIView getTPScreenW] <= ScreenW_5 ? FitScale_5 : ([UIView getTPScreenW] <= ScreenW_6 ? FitScale_6 : FitScale_6P);
}

+ (UIFont*)getTPFitFont:(CGFloat)size :(id)obj
{
    return [UIFont systemFontOfSize:size*[UIView getTPFitScale:obj]];
}

+(CGFloat) getTPScreenRatio
{
    return [UIView getTPScreenW]/ScreenW_5;
}

+(CGFloat) getTPScreenRatioWith5H
{

    return [UIView getTPScreenH]/ScreenH_5;
    
}

+(UIFont*) getTPScreenRatioFont:(CGFloat) size
{
    return [UIFont systemFontOfSize:size*[UIView getTPScreenRatio]];
}

@end

@implementation NSObject (RatioFit)
-(void)setBaseRatio:(RatioBaseOnType)baseType
{
    objc_setAssociatedObject(self, "ratioBaseOn", @(baseType), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(RatioBaseOnType)baseRatio
{
    // 默认基于5
    if (objc_getAssociatedObject(self, "ratioBaseOn") == nil)
        return RatioBaseOn_5;
    
    return (RatioBaseOnType)[objc_getAssociatedObject(self, "ratioBaseOn") intValue];
}
@end

