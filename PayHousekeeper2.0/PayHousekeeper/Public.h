//
//  QSS_Public.h
//  Quansoso
//
//  Created by  striveliu on 14-9-13.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#ifndef Public_h
#define Public_h

#import "NSStringEX.h"

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

#define StrongSelf(type)  __strong typeof(type) type = weak##type;
//URL
#define URL(STRING)  [NSURL URLWithString:STRING]
//IMG
#define IMG(IMGSTR)  [UIImage imageNamed:IMGSTR]
#define DEFAULTPROBE IMG(@"default_probe")

#define DEFAULTAVATAR IMG(@"defaultAvatar")
#define DEFAULTCALLBG IMG(@"netcall_bkg.jpg")
#define SAFE_STR(str)  [NSString safeStr:str]
#define kScale (kMainScreenWidth/375.0)
#define kOnePxSize      (1.0/[UIScreen mainScreen].scale)

#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMainScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kStatusBar_Height  [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBar_Height     44
#define kView_Height       (kMainScreenHeight-kStatusBar_Height-kNavBar_Height)

#define ScreenW_5   320
#define ScreenH_5   568
#define ScreenW_6   375
#define ScreenW_6P  414
#define ScreenH_6   667

// 4,4s,5,5s
#define IsLower6Screen   (kMainScreenHeight < (ScreenH_6-64))


// 4,4s
#define IsSmallScreen   (kMainScreenHeight < (568-20))
// 6,6s
#define IsMiddleScreen  (kMainScreenWidth > ScreenW_5 && kMainScreenWidth < ScreenW_6P)
// plus
#define IsLargeScreen   (kMainScreenWidth >= ScreenW_6P)

#define kComm_Content_Margin           16 
#define kComm_Content_Width            (kMainScreenWidth-2*kComm_Content_Margin)

#define kRequestUrl(path,outUrl) do{\
  outUrl = [NSString stringWithFormat:@"%@%@",kHubBaseUrl,path];\
}while(0)
#define isNull(a) [a isKindOfClass:[NSNull class]]
#define kShortColor(r) [UIColor colorWithRed:r/256.0 green:r/256.0 blue:r/256.0 alpha:1]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]
#define ShortColor(c)   [UIColor colorWithRed:(c)/255.0f green:(c)/255.0f blue:(c)/255.0f alpha:(1)]

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define kSofterViewsion  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kRandom(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define kRandomColor kRandom(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


#ifdef DEBUG
#define MLOG(...)  printf("\n\t<%s line%d>\n%s\n", __FUNCTION__,__LINE__,[[NSString stringWithFormat:__VA_ARGS__] UTF8String])

#else
#define MLOG(...)
#define NSLog(...) {}
#endif
#define kViewBackgroundHexColor [UIColor colorWithHexValue:0xf4f4f4]
#define kViewBackgroundColor RGBCOLOR(238,238,238) // 所有屏幕底色
#define kTabbarBackgroundColor RGBCOLOR(249,249,249) //tabbar的背景色
#define kIconNorColor RGBCOLOR(153,153,153) //所有icon未选中的颜色
#define kIconSelectColor RGBCOLOR(243,92,67) //所有icon选中的颜色
#define kLineColor RGBCOLOR(204,204,204) //所有线条的颜色
#define kFTableViewColor RGBCOLOR(238, 238, 238) // TableView背景颜色
#define kFColorLightBlue RGBCOLOR(153, 179, 200)
#define kFColorFontBlack RGBCOLOR(0x33, 0x33, 0x33)
#define kFcolorFontGreen RGBCOLOR(33, 235, 190)
#define kClearColor [UIColor clearColor]

#define kFont9 [UIFont systemFontOfSize:9]
#define kFont10 [UIFont systemFontOfSize:10]
#define kFont11 [UIFont systemFontOfSize:11]
#define kFont12 [UIFont systemFontOfSize:12]
#define kFont13 [UIFont systemFontOfSize:13]
#define kFont14 [UIFont systemFontOfSize:14]
#define kFont15 [UIFont systemFontOfSize:15]
#define kFont16 [UIFont systemFontOfSize:16]
#define kFont17 [UIFont systemFontOfSize:17]
#define kFont18 [UIFont systemFontOfSize:18]
#define kFont19 [UIFont systemFontOfSize:19]
#define kFont20 [UIFont systemFontOfSize:20]
#define kFont21 [UIFont systemFontOfSize:21]
#define kFont22 [UIFont systemFontOfSize:22]
#define kFont23 [UIFont systemFontOfSize:23]
#define kFont24 [UIFont systemFontOfSize:24]
#define kFont25 [UIFont systemFontOfSize:25]
#define kFont26 [UIFont systemFontOfSize:26]
#define kFont27 [UIFont systemFontOfSize:27]
#define kFont28 [UIFont systemFontOfSize:28]
#define kFont29 [UIFont systemFontOfSize:29]
#define kFont30 [UIFont systemFontOfSize:30]

#define kAutoFont10 [UIFont systemFontOfSize:10.0f*kMainScreenHeight/667.0f]
#define kAutoFont11 [UIFont systemFontOfSize:11.0f*kMainScreenHeight/667.0f]
#define kAutoFont12 [UIFont systemFontOfSize:12.0f*kMainScreenHeight/667.0f]
#define kAutoFont13 [UIFont systemFontOfSize:13.0f*kMainScreenHeight/667.0f]
#define kAutoFont14 [UIFont systemFontOfSize:14.0f*kMainScreenHeight/667.0f]
#define kAutoFont15 [UIFont systemFontOfSize:15.0f*kMainScreenHeight/667.0f]
#define kAutoFont16 [UIFont systemFontOfSize:16.0f*kMainScreenHeight/667.0f]
#define kAutoFont17 [UIFont systemFontOfSize:17.0f*kMainScreenHeight/667.0f]
#define kAutoFont18 [UIFont systemFontOfSize:18.0f*kMainScreenHeight/667.0f]
#define kAutoFont19 [UIFont systemFontOfSize:19.0f*kMainScreenHeight/667.0f]
#define kAutoFont20 [UIFont systemFontOfSize:20.0f*kMainScreenHeight/667.0f]
#define kAutoFont21 [UIFont systemFontOfSize:21.0f*kMainScreenHeight/667.0f]
#define kAutoFont22 [UIFont systemFontOfSize:22.0f*kMainScreenHeight/667.0f]
#define kAutoFont23 [UIFont systemFontOfSize:23.0f*kMainScreenHeight/667.0f]
#define kAutoFont24 [UIFont systemFontOfSize:24.0f*kMainScreenHeight/667.0f]
#define kAutoFont25 [UIFont systemFontOfSize:25.0f*kMainScreenHeight/667.0f]
#define kAutoFont26 [UIFont systemFontOfSize:26.0f*kMainScreenHeight/667.0f]
#define kAutoFont27 [UIFont systemFontOfSize:27.0f*kMainScreenHeight/667.0f]
#define kAutoFont28 [UIFont systemFontOfSize:28.0f*kMainScreenHeight/667.0f]
#define kAutoFont29 [UIFont systemFontOfSize:29.0f*kMainScreenHeight/667.0f]
#define kAutoFont30 [UIFont systemFontOfSize:30.0f*kMainScreenHeight/667.0f]

#define kFontBold13 [UIFont fontWithName:@"Helvetica-Bold" size:13*kMainScreenHeight/675]
#define kFontBold15 [UIFont fontWithName:@"Helvetica-Bold" size:15*kMainScreenHeight/675]
#define kFontBold17 [UIFont fontWithName:@"Helvetica-Bold" size:17*kMainScreenHeight/675]
#define kFontBold18 [UIFont fontWithName:@"Helvetica-Bold" size:18*kMainScreenHeight/675]
#define kFontBold19 [UIFont fontWithName:@"Helvetica-Bold" size:19*kMainScreenHeight/675]
#define kFontBold20 [UIFont fontWithName:@"Helvetica-Bold" size:20*kMainScreenHeight/675]
#define kFontBold21 [UIFont fontWithName:@"Helvetica-Bold" size:21*kMainScreenHeight/675]
#define kFontBold22 [UIFont fontWithName:@"Helvetica-Bold" size:22*kMainScreenHeight/675]
#define kFontBold23 [UIFont fontWithName:@"Helvetica-Bold" size:23*kMainScreenHeight/675]
#define kFontBold24 [UIFont fontWithName:@"Helvetica-Bold" size:24*kMainScreenHeight/675]
#define kFontBold25 [UIFont fontWithName:@"Helvetica-Bold" size:25*kMainScreenHeight/675]

#define kGlobeOffsetX 10
#define kLineWidth (1.0/[UIScreen mainScreen].scale)
#define kSafeObject(stringParm)do{\
    if(!stringParm)\
    {\
        stringParm = @""\
    }\
    stringParm\
}while(0)
#define kNSUDefaultSaveVauleAndKey(value,key) do{\
[[NSUserDefaults standardUserDefaults] setObject:value forKey:key]\
[[NSUserDefaults standardUserDefaults] synchronize]\
}while(0)

#define kNSUDefaultReadKey(key) do{\
[[NSUserDefaults standardUserDefaults] valueForKey:key]\
[[NSUserDefaults standardUserDefaults] synchronize]\
}while(0)
//ui色值
#define kViewBackgrouondColor RGBCOLOR(242, 242, 242)
#define kBlackColor RGBCOLOR(51, 51, 51)
#define kGrayColor RGBCOLOR(136, 136, 136)
#define kBGNavagationBarBG RGBCOLOR(13, 72, 147)
//  document路径
#define DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define kFitsizeWidth kMainScreenWidth/375
#define kLeftMragin  20

#define kSafeid(id)  do{\
if(id)\
{\
id = nil;\
}\
}while(0)
#define kIntToString(str,a) do{\
str = [NSString stringWithFormat:@"%d", a];\
}while(0)

#define kFloatToString(str,a) do{\
str=[NSString stringWithFormat:@"%.2f", a];\
}while(0)


#define AssignMentID(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? V : nil); \
} while(0)

#define AssignMentNSNumber(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V intValue] : 0); \
} while(0)

#define AssignMentNSNumberLong(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V longValue] : 0); \
} while(0)

#define AssignMentNSNumberFloat(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V floatValue] : 0); \
} while(0)

#define AssignMentNSNumberBool(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V boolValue] : 0); \
} while(0)

#define AssignMentNSNumberDouble(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V doubleValue] : 0); \
} while(0)

#define AssignMentNSNumberLonglong(l, r) do { \
id V = (r); \
l = (V && !isNull(V) ? [V longLongValue] : 0); \
} while(0)

#define PacketDictObject(i,dict,key) do { \
if(i) { \
[dict setObject:i forKey:key]; }\
}while(0)



#define PacketDictNumberInt(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithInt:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define PacketDictNumberFloat(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithFloat:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define PacketDictNumberDouble(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithDouble:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define PacketDictNumberBool(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithBool:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define PacketDictNumberLong(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithLong:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define PacketDictNumberLongLong(i, dict,key) do { \
NSNumber *iNum = [NSNumber numberWithLongLong:i];\
[dict setObject:iNum forKey:key]; \
}while(0)

#define KColor kIconSelectColor//RGBCOLOR(225, 44, 25)


#define kCreateLabel(outLabel,aRect,aFontsize,aColor,aContent) do{\
UILabel *koutlabel = [[UILabel alloc] initWithFrame:aRect];\
koutlabel.backgroundColor = [UIColor clearColor];\
koutlabel.font = [UIFont systemFontOfSize:aFontsize];\
koutlabel.textColor = [UIColor colorWithHexValue:aColor];\
koutlabel.text = aContent;\
outLabel = koutlabel;\
}while(0)

#endif
