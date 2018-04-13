//
//  NSStringEX.h
//  QZone
//
//  Created by sugar chen on 10-5-3.
//  Copyright 2010 Tencent Technology (Shenzhen) Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (other)

- (NSString *) stringFromMD5;
-(BOOL) containsSystemEmoji;

//+ (NSString*)stringWithInt:(int)value;
//- (unsigned long long)longLongValueEX;

- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainSize;
+ (NSString*)safeStr:(NSString*)str;
@end
