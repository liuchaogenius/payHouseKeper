//
//  WXHead.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/27.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#ifndef WXHead_h
#define WXHead_h
#define WXColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define kfont @"Helvetica"
#define kfontBold @"Helvetica-Bold"

#endif /* WXHead_h */
