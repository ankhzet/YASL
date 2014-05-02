//
//  YASLEventsAPI.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLEventsAPI.h"
#import "YASLNativeFunction.h"

NSString *NATIVE_EVENT_OPEN = @"";

@interface YASLEventsAPI () {
	NSMutableArray *events;
	NSMutableDictionary *namedEvents;
}

@end

@implementation YASLEventsAPI

- (id)init {
	if (!(self = [super init]))
		return self;

	events = [NSMutableArray arrayWithObject:[NSNull null]];
	namedEvents = [NSMutableDictionary dictionary];
	return self;
}

#pragma mark - Base functionality

- (YASLInt) genGUID {
	return [events count];
}

- (YASLEvent *) findByHandle:(YASLInt)handle {
	return ((handle > 0) && (handle < [events count])) ? events[handle] : nil;
}

- (YASLEvent *) findByName:(NSString *)name {
	return namedEvents[name];
}

- (YASLEvent *) createEventWithName:(NSString *)name initialState:(YASLInt)state autoreset:(BOOL)autoreset {
	YASLEvent *event = name ? [self findByName:name] : nil;
	if (event) {
		event.links++;
		return event;
	}

	@synchronized (events) {
		YASLInt guid = [self genGUID];
		event = [YASLEvent eventWithEventManager:self];
		event.name = name;
		event.handle = guid;
		event.state = state;
		event.autoreset = autoreset;
		event.links = 1;
		[events setObject:event atIndexedSubscript:guid];
		if (name) {
			namedEvents[name] = event;
		}
	}

	return event;
}

- (YASLInt) signalEvent:(YASLInt)handle withSignalState:(YASLInt)state {
	YASLEvent *event = [self findByHandle:handle];
	if (!event)
		return YASL_INVALID_HANDLE;

	YASLInt oldState = event.state;
	event.state = state;
	return oldState;
}

- (YASLInt) closeEvent:(YASLInt)handle {
	YASLEvent *event = ((handle > 0) && (handle < [events count])) ? events[handle] : nil;

	if (!event)
		return YASL_INVALID_HANDLE;

	NSUInteger links = --event.links;

	if (links <= 0) {
		[self deleteEvent:event];
	}

	return links;
}

- (void) deleteEvent:(YASLEvent *)event {
	[events replaceObjectAtIndex:event.handle withObject:[NSNull null]];
	namedEvents[event.name] = [NSNull null];
}

#pragma mark - Native functions implementation

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:@"createEvent" withParamCount:3 returnType:YASLAPITypeHandle withSelector:@selector(n_CreateEvent:params:)];
	[self registerNativeFunction:@"signalEvent" withParamCount:2 returnType:YASLAPITypeHandle withSelector:@selector(n_SignalEvent:params:)];
	[self registerNativeFunction:@"closeEvent" withParamCount:1 returnType:YASLAtomicTypeBool withSelector:@selector(n_CloseEvent:params:)];
}

- (YASLInt) n_CreateEvent:(YASLNativeFunction *)native params:(void *)paramsBase {
	NSString *name = [native stringParam:1 atBase:paramsBase];
	YASLInt state = [native intParam:2 atBase:paramsBase];
	YASLInt autoreset = [native intParam:3 atBase:paramsBase];

	YASLEvent *event = [self createEventWithName:name initialState:state autoreset:!!autoreset];

	return event ? event.handle : YASL_INVALID_HANDLE;
}

- (YASLInt) n_SignalEvent:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLInt handle = [native intParam:1 atBase:paramsBase];
	YASLInt state = [native intParam:2 atBase:paramsBase];
	return [self signalEvent:handle withSignalState:state];
}

- (YASLInt) n_CloseEvent:(YASLNativeFunction *)native params:(void *)paramsBase {
	return [self closeEvent:[native intParam:1 atBase:paramsBase]];
}

@end
