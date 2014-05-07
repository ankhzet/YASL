//
//  YASLExceptionStack.m
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLExceptionStack.h"
#import "YASLNonfatalException.h"

@implementation YASLExceptionStack {
	NSMutableArray *stack;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	stack = [NSMutableArray array];
	return self;
}

- (void) pushException:(YASLNonfatalException *)exception {
	[stack addObject:exception];
}

- (void) reRaise {
	@throw [self popException];
}

/*! Returns and deletes from stack last thrown syntax exception. */
- (YASLNonfatalException *) popException {
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

	YASLNonfatalException *exception = [self prepareExceptionObject:formatted];
	[self pushException:exception];
	@throw exception;
}

- (NSUInteger) pushExceptionStackState {
	return [stack count];
}

- (void) popExceptionStackState:(NSUInteger)state {
	if ((int)state < (int)[stack count] - 1) {
		[stack removeObjectsInRange:NSMakeRange(state, [stack count] - state)];
	}
}

@end

@implementation YASLExceptionStack (Protected)

- (YASLNonfatalException *) prepareExceptionObject:(NSString *)msg {
	return (id)[YASLNonfatalException exceptionWithName:NSStringFromClass([self class]) reason:msg userInfo:nil];
}

@end
