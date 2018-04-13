//
//  NSStringTool.m
//  cft
//
//  Created by striveliu on 16/7/19.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import "NSStringTool.h"

@implementation NSStringTool
+ (NSMutableAttributedString *)createAttributesting:(NSString *)aSource
                                        highContent:(NSString *)aHightContent
                                          hgihtFont:(UIFont *)aHightFont
                                          highColor:(UIColor *)aHighColor
{
    if(!aSource || aSource.length <= 0)
    {
        return nil;
    }
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:aSource];
    NSRange rang2 = [aSource rangeOfString:aHightContent];
    if(rang2.location == NSNotFound)
    {
        return attriString;
    }
    [attriString addAttribute:NSForegroundColorAttributeName
                        value:aHighColor
                        range:rang2];
//    UIFont *baseFont2 = [UIFont systemFontOfSize:aFontSize];
    if(aHightFont)
    {
        [attriString addAttribute:NSFontAttributeName value:aHightFont range:rang2];
    }
    return attriString;
}

+ (NSString *)createMaskstring:(NSString *)aSource maskRange:(NSRange)aRange
{
    if(!aSource || aSource.length <= 0)
    {
        return nil;
    }
    if(aRange.length <= 0 || aRange.location == NSNotFound || aRange.location <=0)
    {
        return aSource;
    }
    if((aRange.location+aRange.length) > aSource.length)
    {
        aRange.length = aSource.length-aRange.location;
    }
    NSString *resultstring = [aSource stringByReplacingCharactersInRange:aRange withString:@"****"];
    return resultstring;
}

+ (NSMutableAttributedString *)createAttributesting:(NSString *)aSource
                                       highContents:(NSArray *)aHighContents
                                          hgihtFont:(UIFont *)aHightFont
                                          highColor:(UIColor *)aHighColor
{
    if(!aSource || aSource.length <= 0|| aHighContents.count<=0)
    {
        return nil;
    }
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:aSource];
    for (NSString *str in aHighContents) {
        NSRange rang2 = [aSource rangeOfString:str];
        if(rang2.location == NSNotFound)
        {
            return attriString;
        }
        [attriString addAttribute:NSForegroundColorAttributeName
                            value:aHighColor
                            range:rang2];
        //    UIFont *baseFont2 = [UIFont systemFontOfSize:aFontSize];
        if(aHightFont)
        {
            [attriString addAttribute:NSFontAttributeName value:aHightFont range:rang2];
        }
    }

    return attriString;
}
@end
