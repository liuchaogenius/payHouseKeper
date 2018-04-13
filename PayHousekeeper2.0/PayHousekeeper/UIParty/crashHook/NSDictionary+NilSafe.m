//
//  NSDictionary+NilSafe.m
//  NSDictionary-NilSafe
//
//  Created by striveliu on 6/22/16.
//  Copyright © 2016 striveliu. All rights reserved.
//

#import <objc/runtime.h>
#import "NSDictionary+NilSafe.h"
#import "NSObject+Swizzling.h"

@implementation NSDictionary (NilSafe)

+ (void)NSDictoryCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(initWithObjects:forKeys:count:) swizzledSelector:@selector(gl_initWithObjects:forKeys:count:)];
        [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(dictionaryWithObjects:forKeys:count:) swizzledSelector:@selector(gl_dictionaryWithObjects:forKeys:count:)];
    });
}

+ (instancetype)gl_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self gl_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)gl_initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    id safeObjects[cnt];
    id safeKeys[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key) {
            continue;
        }
        if (!obj) {
            obj = [NSNull null];
        }
        safeKeys[j] = key;
        safeObjects[j] = obj;
        j++;
    }
    return [self gl_initWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

@implementation NSMutableDictionary (NilSafe)

+ (void)NSMutableDictoryCrashHook {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"__NSDictionaryM");
        [class swizzleMethod:@selector(setObject:forKey:) swizzledSelector:@selector(gl_setObject:forKey:)];
        [class swizzleMethod:@selector(setObject:forKeyedSubscript:) swizzledSelector:@selector(gl_setObject:forKeyedSubscript:)];
    });
}

- (void)gl_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return;
    }
    if (!anObject) {
//        anObject = [NSNull null];
        return ;
    }
    [self gl_setObject:anObject forKey:aKey];
}

- (void)gl_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        return;
    }
    if (!obj) {
//        obj = [NSNull null];
        return ;
    }
    [self gl_setObject:obj forKeyedSubscript:key];
}

@end

//@implementation NSNull (NilSafe)
//
//
//+ (void)NSNullCrashHook {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self gl_swizzleMethod:@selector(methodSignatureForSelector:) withMethod:@selector(gl_methodSignatureForSelector:)];
//        [self gl_swizzleMethod:@selector(forwardInvocation:) withMethod:@selector(gl_forwardInvocation:)];
//    });
//}
//
//- (NSMethodSignature *)gl_methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *sig = [self gl_methodSignatureForSelector:aSelector];
//    if (sig) {
//        return sig;
//    }
//    return [NSMethodSignature signatureWithObjCTypes:@encode(void)];
//}
//
//- (void)gl_forwardInvocation:(NSInvocation *)anInvocation {
//    NSUInteger returnLength = [[anInvocation methodSignature] methodReturnLength];
//    if (!returnLength) {
//        // nothing to do
//        return;
//    }
//
//    // set return value to all zero bits
//    char buffer[returnLength];
//    memset(buffer, 0, returnLength);
//
//    [anInvocation setReturnValue:buffer];
//}
//
//@end
