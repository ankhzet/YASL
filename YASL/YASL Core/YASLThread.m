//
//  YASLThread.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLThread.h"
#import "YASLEventsAPI.h"
#import "YASLEvent.h"

@interface YASLThread () {
	__weak YASLEvent *event;
	__weak YASLEventsAPI *eventManager;
}

@end

@implementation YASLThread

+ (instancetype) thread:(BOOL)waitable withEventManager:(YASLEventsAPI *)eventManager {
	return [(YASLThread *)[self alloc] init:waitable withEventManager:eventManager];
}

- (id)init:(BOOL)waitable withEventManager:(YASLEventsAPI *)manager {
	if (!(self = [super init]))
		return self;

	// configure associated event
	eventManager = manager;
	event = [eventManager createEventWithName:[NSString stringWithFormat:@"_e_thread_%p", &self]
															 initialState:YASLEventStateClear
																	autoreset:YES];
	if (waitable) {
		event.links++;
	}
	handle = event.handle;

	// initialize base parameters
	startedAt = [YASLThread ticksMsec];
	steps = 0;

	return self;
}

+ (long long) ticksMsec {
	return (long long) ([NSDate timeIntervalSinceReferenceDate] * 1000);
}

- (void) setState:(YASLThreadState)state {
	if (_state == state) {
		return;
	}
	_state = state;
	event.state = state;
}

- (void) terminateWithExitCode:(YASLInt)exitCode {
	self.state = YASLThreadStateTerminated;
	self.exitCode = exitCode;
	[event close];
}

- (void) suspend:(YASLInt)msec {
	if (!(_state == YASLThreadStateRunning) || (_state == YASLThreadStateSleep)) {
		return;
	}

	self.state = YASLThreadStateSleep;
	awakeWithin = (msec == WEI_INFINITE) ? WEI_INFINITE : [YASLThread ticksMsec] + msec;
	waitState = 0;
	runned = YES;
}

- (void) resume {
	if (!(_state == YASLThreadStateNotReady) || (_state == YASLThreadStateSleep)) {
		return;
	}

	waitFor = 0;
	self.state = YASLThreadStateRunning;
	runned = YES;
}

- (void) event:(YASLInt)eventHandle waitFor:(YASLInt)msec state:(YASLThreadState)state {
	waitFor = eventHandle;
	YASLEvent *waitEvent = eventHandle ? [eventManager findByHandle:eventHandle] : nil;

	if (!waitEvent) {
		waitState = YASLEventStateFailed;
	} else {
		BOOL imediateReturn = msec == 0;
		waitState = imediateReturn ? waitEvent.state : state;
		if (!imediateReturn) {
			[self suspend:msec];
		}
	}
}

@end
