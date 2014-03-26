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
	NSMutableArray *exceptionsStack;
	NSUInteger stateGUID;
	NSMutableDictionary *stackStates;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	stateGUID = 0;
	return self;
}

- (void) pushException:(YASLNonfatalException *)exception {
	if (!exceptionsStack)
		exceptionsStack = [NSMutableArray array];

	[exceptionsStack addObject:exception];
	exception.stackGUID = stateGUID;
}

- (void) reRaise {
	@throw [self popException];
}

/*! Returns and deletes from stack last thrown syntax exception. */
- (YASLNonfatalException *) popException {
	id e = [exceptionsStack lastObject];
	if (e)
		[exceptionsStack removeLastObject];

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
	NSUInteger count = [exceptionsStack count];
	NSUInteger guid = ++stateGUID;

	if (!stackStates)
		stackStates = [NSMutableDictionary dictionary];

	stackStates[@(guid)] = @(count);
	return guid;
}

- (void) popExceptionStackState:(NSUInteger)guid {
	NSNumber *state = stackStates[@(guid)];
	if (!state)
		return;

	NSMutableArray *junk = [NSMutableArray arrayWithCapacity:[[stackStates allKeys] count]];
	for (NSNumber *guidKey in [stackStates allKeys]) {
    if ([guidKey unsignedIntegerValue] > guid) {
			[junk addObject:guidKey];
		}
	}
	for (id key in junk) {
    [stackStates removeObjectForKey:key];
	}

	NSUInteger count = [state unsignedIntegerValue];
	NSUInteger current = [exceptionsStack count];
	NSInteger delta = current - count;
	if (delta > 0) {
		[exceptionsStack removeObjectsInRange:NSMakeRange(count, delta)];
	}
}

@end

@implementation YASLExceptionStack (Protected)

- (YASLNonfatalException *) prepareExceptionObject:(NSString *)msg {
	return (id)[YASLNonfatalException exceptionWithName:NSStringFromClass([self class]) reason:msg userInfo:nil];
}

@end
