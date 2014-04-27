//
//  YASLNativeInterface.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLNativeInterface : NSObject

/*!
 Register all native functions, supported by this interface. Called in -[init] method. Must be overrided by subclasses, if they provides custom native functions.
 */
- (void) registerNativeFunctions;

/*! Register native function with specified parameters. */
- (NSUInteger) registerNativeFunction:(NSString *)name withParamCount:(NSUInteger)params returnType:(NSString *)returns withSelector:(SEL)selector;

@end
