//
//  YASLExceptionStack.m
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLExceptionStack.h"

@implementation YASLExceptionStack {
	NSMutableArray *stack;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	stack = [NSMutableArray array];
	return self;
}

/*! Returns and deletes from stack last thrown syntax exception. */
- (NSException *) popException {
	id e = [stack lastObject];
	if (e)
		[stack removeLastObject];

	return e;
}

- (void) raiseError:(NSString *)msg, ... {
	va_list args;
  va_start(args, msg);
	NSString *formatted = [[NSString alloc] initWithFormat:msg arguments:args];
  va_end(args);

	NSException *exception = [self prepareExceptionObject:formatted];
	[stack addObject:exception];
	@throw exception;
}

- (NSUInteger) pushStackState {
	return [stack count];
}

- (void) popStackState:(NSUInteger)state {
	if (state < [stack count]) {
		[stack removeObjectsInRange:NSMakeRange(state, [stack count] - state)];
	}
}

@end

@implementation YASLExceptionStack (Protected)

- (NSException *) prepareExceptionObject:(NSString *)msg {
	return [NSException exceptionWithName:NSStringFromClass([self class]) reason:msg userInfo:nil];
}

@end
