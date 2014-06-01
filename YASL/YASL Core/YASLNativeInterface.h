//
//  YASLNativeInterface.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Selector signature for native function implementation
 - (YASLInt) n_:(YASLNativeFunction *)native params:(void *)paramsBase;
 */

@interface YASLNativeInterface : NSObject

/*!
 Register all native functions, supported by this interface. Called in -[init] method. Must be overrided by subclasses, if they provides custom native functions.
 */
- (void) registerNativeFunctions;

/*! Register native function with specified parameters. */
- (NSUInteger) registerNativeFunction:(NSString *)name isVoid:(BOOL)isVoid withSelector:(SEL)selector;

@end
