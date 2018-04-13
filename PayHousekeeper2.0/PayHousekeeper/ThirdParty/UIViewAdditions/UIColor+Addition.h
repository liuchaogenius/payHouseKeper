//
//  UIColor+Addition.h
//  moneyshield
//
//  Created by janDeng on 1/8/15.
//  Copyright (c) 2015 Alibaba.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue alpha:(NSUInteger)alpha;
+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue;

@end