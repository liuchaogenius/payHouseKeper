//
//  NSDictionary+NilSafe.h
//  NSDictionary-NilSafe
//
//  Created by striveliu on 6/22/16.
//  Copyright © 2016 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NilSafe)
+ (void)NSDictoryCrashHook;
@end

@interface NSMutableDictionary (NilSafe)
+ (void)NSMutableDictoryCrashHook;
@end

//@interface NSNull (NilSafe)
//
//@end
