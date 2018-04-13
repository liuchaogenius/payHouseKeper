//
//  NSStringTool.h
//  cft
//
//  Created by striveliu on 16/7/19.
//  Copyright © 2016年 holyli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStringTool : NSObject

+ (NSMutableAttributedString *)createAttributesting:(NSString *)aSource
                                        highContent:(NSString *)aHightContent
                                          hgihtFont:(UIFont *)aHightFont
                                          highColor:(UIColor *)aHighColor;

+ (NSString *)createMaskstring:(NSString *)aSource maskRange:(NSRange)aRange;

+ (NSMutableAttributedString *)createAttributesting:(NSString *)aSource
                                       highContents:(NSArray *)aHighContents
                                          hgihtFont:(UIFont *)aHightFont
                                          highColor:(UIColor *)aHighColor;

@end
