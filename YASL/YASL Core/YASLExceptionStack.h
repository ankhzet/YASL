//
//  YASLExceptionStack.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLExceptionStack : NSObject

- (void) raiseError:(NSString *)msg, ...;

- (NSException *) popException;

- (NSUInteger) pushStackState;
- (void) popStackState:(NSUInteger)state;

@end

@interface YASLExceptionStack (Protected)

- (NSException *) prepareExceptionObject:(NSString *)msg;

@end
