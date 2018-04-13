
//
//  NSStringEX.m
//  QZone
//
//  Created by sugar chen on 10-5-3.
//  Copyright 2010 Tencent Technology (Shenzhen) Company Limited. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "NSStringEx.h"

#define COUNTRY_EMOJI

static const char countryEmoChar[][4] = {
    {0xF0,0x9F,0x87,0xA9},//🇩🇪
    {0xF0,0x9F,0x87,0xAC},//🇬🇧
    {0xF0,0x9F,0x87,0xA8},//🇨🇳
    {0xF0,0x9F,0x87,0xAF},//🇯🇵
    {0xF0,0x9F,0x87,0xB0},//🇰🇷
    {0xF0,0x9F,0x87,0xAB},//🇫🇷
    {0xF0,0x9F,0x87,0xAA},//🇪🇸
    {0xF0,0x9F,0x87,0xAE},//🇮🇹
    {0xF0,0x9F,0x87,0xBA},//🇺🇸
    {0xF0,0x9F,0x87,0xB7} //🇷🇺
};

bool isEqualUTF8(const char* char1,const char* char2)
{
    if(NULL == char1 || NULL == char2) return false;
    
    if(0 == strncmp(char1, char2,4)){
        
        return true;
    }
    
    return false;
}

bool compareUTF8Contain(const char* char1, const char* char2)
{
    
    if(NULL == char1 || NULL == char2) return false;
    
    for(int i=0; i < 10; i++)
    {
        const char* subChar = (char1+i*4);
        if(NULL!=subChar && isEqualUTF8(subChar, char2))
        {
            return true;
        }
    }
    
    return false;
}

//+ (NSString*)stringWithInt:(int)value
//{
//    return [NSString stringWithFormat:@"%d", value];
//}

//- (unsigned long long)longLongValueEX
//{
//    if (self.length < 1)
//        return 0;
//    
//    QUINT64 realNum = 0 ;
//    
//    NSString *subStr = [self substringToIndex:[self length] - 1];
//    QINT64 tmpValue = [subStr longLongValue];
//    realNum = tmpValue * 10;
//    realNum += [[self substringWithRange:NSMakeRange(self.length - 1, 1)] intValue];
//    
//    return realNum;
//}

@implementation NSString (other)

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

-(BOOL) containsSystemEmoji {
    
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
         
#ifdef COUNTRY_EMOJI
         if(2 == substringRange.length){
             const char* utf8 = [substring UTF8String];
             if(compareUTF8Contain((char*)countryEmoChar, utf8)){
                 substringRange.length = 4;
             }
         }
#endif
         
#ifdef _10Keyboard
         // ios7 使用九宫格输入法的时候，占位符会被认为是emoji表情。
         if (SYSTEM_VERSION >= 7.0) {
             
             const char *utf8 = [substring UTF8String];
             
             if (is10keyboardInput(utf8)) {
                 returnValue = NO;
             }
         }
#endif
         
     }];
    
    return returnValue;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainSize
{
    if (font == nil) return CGSizeZero;

    CGSize size  = [self boundingRectWithSize:constrainSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil].size;
    return size;
}

- (CGSize)sizeWithFont:(UIFont *)font
{
    if(nil == font)return CGSizeZero;
    CGSize size  = [self boundingRectWithSize:CGSizeMake(NSIntegerMax, NSIntegerMax)
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil].size;
    return size;
}

+(NSString*) safeStr:(NSString*) str
{
    if ([str isEqual:@"NULL"] || [str isKindOfClass:[NSNull class]] || [str isEqual:[NSNull null]] || [str isEqual:NULL] || [[str class] isSubclassOfClass:[NSNull class]] || str == nil || str == NULL || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@"<null>"] || [str isEqualToString:@"(null)"])
    {
        return @"";
    }
    
    if(![str isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"%@",str];
    }
    
    return str;
    //    return ((str)==nil?@"":(str));
}
@end
