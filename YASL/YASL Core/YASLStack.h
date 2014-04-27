//
//  YASLStack.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

#define STACK_DEFAULT_SIZE (1024 * 10)

@class YASLRAM;
@interface YASLStack : NSObject

@property (nonatomic) YASLRAM *ram;
@property (nonatomic) NSUInteger size;
@property (nonatomic) NSUInteger top;
@property (nonatomic) NSUInteger base;

+ (instancetype) stackForRAM:(YASLRAM *)ram;

/*!
 @brief Push integer to the stack.
 */
- (void) push:(YASLInt)value;
- (void) pushSpace:(NSUInteger)count;
/*!
 @brief Push integer from stack.
 */
- (YASLInt) pop;
- (void) popSpace:(NSUInteger)count;

- (void) pushf:(YASLFloat)value;
- (YASLFloat) popf;

@end
