//
//  YASLEventsAPI.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLEventsAPI.h"
#import "YASLNativeFunction.h"
#import "YASLDataType.h"

NSString *NATIVE_EVENT_OPEN = @"";

@interface YASLEventsAPI () {
	NSMutableArray *events;
	NSMutableDictionary *namedEvents;
	NSMutableDictionary *handledEvents;
	YASLInt guid;
}

@end

@implementation YASLEventsAPI

- (id)init {
	if (!(self = [super init]))
		return self;

	events = [NSMutableArray array];
	namedEvents = [NSMutableDictionary dictionary];
	handledEvents = [NSMutableDictionary dictionary];

	guid = 0;
	return self;
}

#pragma mark - Base functionality

- (YASLInt) genGUID {
	return ++guid;
}

- (YASLEvent *) findByHandle:(YASLInt)handle {
	return handledEvents[@(handle)];
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
		event = [YASLEvent eventWithEventManager:self];
		event.name = name;
		event.handle = [self genGUID];
		event.state = state;
		event.autoreset = autoreset;
		event.links = 1;
		[events addObject:event];
		if (name) {
			namedEvents[name] = event;
		}
		handledEvents[@(event.handle)] = event;
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
	YASLEvent *event = [self findByHandle:handle];

	if (!event)
		return YASL_INVALID_HANDLE;

	NSUInteger links = --event.links;

	if (links <= 0) {
		[self deleteEvent:event];
	}

	return (YASLInt)links;
}

- (void) deleteEvent:(YASLEvent *)event {
	[events removeObject:event];
	if (event.name)
		[namedEvents removeObjectForKey:event.name];
	[handledEvents removeObjectForKey:@(event.handle)];
}

#pragma mark - Native functions implementation

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:@"createEvent" isVoid:NO withSelector:@selector(n_CreateEvent:params:withParamCount:)];
	[self registerNativeFunction:@"signalEvent" isVoid:NO withSelector:@selector(n_SignalEvent:params:withParamCount:)];
	[self registerNativeFunction:@"closeEvent" isVoid:NO withSelector:@selector(n_CloseEvent:params:withParamCount:)];
}

- (YASLInt) n_CreateEvent:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	NSString *name = [native stringParam:1 atBase:paramsBase withParamCount:params];
	YASLInt state = [native intParam:2 atBase:paramsBase withParamCount:params];
	YASLInt autoreset = [native intParam:3 atBase:paramsBase withParamCount:params];

	YASLEvent *event = [self createEventWithName:name initialState:state autoreset:!!autoreset];

	return event ? event.handle : YASL_INVALID_HANDLE;
}

- (YASLInt) n_SignalEvent:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	YASLInt handle = [native intParam:1 atBase:paramsBase withParamCount:params];
	YASLInt state = [native intParam:2 atBase:paramsBase withParamCount:params];
	return [self signalEvent:handle withSignalState:state];
}

- (YASLInt) n_CloseEvent:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	return [self closeEvent:[native intParam:1 atBase:paramsBase withParamCount:params]];
}

@end
