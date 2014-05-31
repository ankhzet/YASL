//
//  YASLExceptionStack.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLNonfatalException.h"

@interface YASLExceptionStack : NSObject

- (void) raiseError:(NSString *)msg, ...;

- (void) pushException:(YASLNonfatalException *)exception;
- (YASLNonfatalException *) popException;
- (void) reRaise;

- (NSUInteger) pushExceptionStackState;
- (void) popExceptionStack;
- (void) popExceptionStackState:(NSUInteger)guid;

@end

@interface YASLExceptionStack (Protected)

- (YASLNonfatalException *) prepareExceptionObject:(NSString *)msg;

@end
