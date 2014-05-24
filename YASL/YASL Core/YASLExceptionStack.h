//
//  YASLExceptionStack.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLNonfatalException;
@interface YASLExceptionStack : NSObject

- (void) raiseError:(NSString *)msg, ...;

- (void) pushException:(YASLNonfatalException *)exception;
- (YASLNonfatalException *) popException;
- (void) reRaise;

- (NSUInteger) pushExceptionStackState;
- (void) popExceptionStackState:(NSUInteger)guid;

@end

@interface YASLExceptionStack (Protected)

- (YASLNonfatalException *) prepareExceptionObject:(NSString *)msg;

@end
