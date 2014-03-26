//
//  YASLNativeFunctions.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YASLNativesList.h"

@class YASLNativeFunction, YASLRAM, YASLStack, YASLCPU;
@interface YASLNativeFunctions : NSObject

@property (nonatomic) YASLRAM *attachedRAM;
@property (nonatomic) YASLCPU *attachedCPU;
@property (nonatomic) YASLStack *attachedStack;

/*! Returns shared manager instance (singleton). */
+ (instancetype) sharedFunctions;

/*!
 @brief Register native function in storage. Valid GUID will be generated and assigned for function.
 */
- (NSUInteger) registerNativeFunction:(YASLNativeFunction *)function;

/*!
 @brief Find native function by name or guid.
 @return Function description object or nil, if not finded.
 */
- (YASLNativeFunction *) findByName:(NSString *)name;
- (YASLNativeFunction *) findByGUID:(NSUInteger)guid;

@end
