//
//  YASLThreadsAPI.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLThreadsAPI.h"
#import "YASLThread.h"
#import "YASLEventsAPI.h"
#import "YASLEvent.h"
#import "YASLNativeFunction.h"
#import "YASLNativesList.h"

@interface YASLThreadsAPI () {
	NSMutableArray *threads;
	NSMutableArray *enumerable;
	YASLThreadStruct dummyData;
}

@end

@implementation YASLThreadsAPI

-(id) initWithEventsManager:(YASLEventsAPI *)eventManager {
	if (!(self = [super init]))
		return self;

	_eventsManager = eventManager;
	threads = [NSMutableArray array];
	enumerable = [NSMutableArray array];
	_activeThread = nil;
	threadData = &dummyData;
	_activeThreadHandle = 0;
	return self;
}

- (NSUInteger) threadsCount {
	return [enumerable count];
}

- (NSEnumerator *) enumerateThreads {
	return [enumerable objectEnumerator];
}

#pragma mark - Threads creation/suspend/resume/terminate

- (YASLThread *) thread:(YASLInt)handle {
	YASLThread *thread = threads[handle];
	return (thread != (id)[NSNull null]) ? thread : nil;
}

- (YASLThread *) threadCreateWithEntryAt:(YASLInt)entry andState:(YASLThreadState)state andInitParam:(YASLInt)param waitable:(BOOL)waitable {
	YASLThread *thread = [YASLThread thread:waitable withEventManager:self.eventsManager];
	thread->data.registers[YASLRegisterIIP] = entry;
	thread->param = param;
	thread.state = state;
	@synchronized(threads) {
		NSUInteger c = [threads count];
		while (++c <= thread->handle) {
			[threads addObject:[NSNull null]];
		}
		[threads setObject:thread atIndexedSubscript:thread->handle];
		[enumerable addObject:thread];
	}
	return thread;
}

- (void) threadClose:(YASLInt)handle {
	[_eventsManager closeEvent:handle];
	[enumerable removeObject:[self thread:handle]];
	[threads replaceObjectAtIndex:handle withObject:[NSNull null]];
}

- (YASLInt) thread:(YASLInt)handle terminate:(YASLInt)exitCode {
	YASLThread *thread = [self thread:handle];
	if (!(thread && (thread.state != YASLThreadStateTerminated)))
		return false;

	[thread terminateWithExitCode:exitCode];
	return true;
}

- (YASLInt) thread:(YASLInt)handle suspend:(YASLInt)msec {
	YASLThread *thread = [self thread:handle];
	if (!thread)
		return false;

	[thread suspend:msec];
	return true;
}

- (YASLInt) threadResume:(YASLInt)handle {
	YASLThread *thread = [self thread:handle];
	if (!thread)
		return false;

	[thread resume];
	return true;
}

#pragma mark Thread wait-event functionality

- (YASLInt) thread:(YASLInt)handle event:(YASLInt)event waitFor:(YASLInt)msec state:(YASLThreadState)state {
	YASLThread *thread = [self thread:handle];
	if (!(thread && (event != handle)))
		return false;

	[thread event:event waitFor:msec state:state];
	return true;
}

#pragma mark - Thread switching

- (void) setActiveThreadHandle:(YASLInt)activeThreadHandle {
	if (_activeThreadHandle == activeThreadHandle)
		return;

	_activeThreadHandle = activeThreadHandle;

	_activeThread = ((activeThreadHandle > 0) && (activeThreadHandle < [threads count])) ? [self thread:activeThreadHandle] : nil;
	threadData = _activeThread ? &_activeThread->data : &dummyData;
	[self setActiveThread:_activeThread];
}

- (void) setActiveThread:(YASLThread *)activeThread {
}

/*!
 Switch to thread, that was not yet runned in current cycle, or start next run cycle otherwise. Halts if no more running threads.
 */
- (YASLInt) switchThreads {
	// first, awake all suspended threads (suspended via threadSleep or waitEvent)
	[self awakeThreads];

	YASLInt pickedThread = YASL_INVALID_HANDLE;
	NSUInteger running = [enumerable count]; // count of actually running threads (without terminated)

	for (YASLThread *thread in enumerable) {
		YASLThreadState state = thread.state;
		if (state == YASLThreadStateRunning) {
			// for each running thread
			if (thread->data.halt)
				[self thread:thread->handle terminate:-1]; // terminate it, if recently halted
			else
				if (!thread->runned) { // or pick it, if not runned yet in this cycle
					pickedThread = thread->handle;
					break;
				}
		} else
			if (state == YASLThreadStateTerminated)
				running--; // decrement running threads counter for terminated threads
	}

	if (pickedThread == YASL_INVALID_HANDLE)
		pickedThread = [self nextCycle]; // if no more not runned in this cycle threads - start next cycle

	// thread for this run picked
	self.activeThreadHandle = pickedThread;
	if (pickedThread != YASL_INVALID_HANDLE) {
		self.activeThread->runned = YES; // mark it as runned
	}

	_halted = [enumerable count] && !running; // halt cpu if no more running threads at all
	return pickedThread;
}

/*!
 Awake threads, that was suspended via threadSuspend or threadWaitEvent.
 */
- (void) awakeThreads {
	long long tick = [YASLThread ticksMsec];

	for (YASLThread *thread in enumerable) {
    if (thread.state != YASLThreadStateSleep)
			continue;

		if (thread->awakeWithin > tick) {
			if (thread->waitFor) {
				YASLEvent *event = [_eventsManager findByHandle:thread->waitFor];
				YASLEventState state = event ? event.state : YASLEventStateFailed;

				if ((state != thread->waitState) && (state != YASLEventStateFailed))
					continue;

				thread->waitState = state;
				thread->data.registers[YASLRegisterIR0] = state;
				[thread resume];

				if (event && event.autoreset)
					event.state = YASLEventStateClear;
			}
		} else {
			if (thread->waitFor) {
				thread->data.registers[YASLRegisterIR0] = YASLEventStateTimeout;
				thread->waitState = YASLEventStateTimeout;
			}
			[thread resume];
		}
	}
}

/*!
 Starts next execution cycle. Picks first running thread available, other threads will be marked as ready for execution.
 Also closes terminated threads, for which associated event has zero link count.
 */
- (YASLInt) nextCycle {
	YASLInt selected = YASL_INVALID_HANDLE;

	//TODO: mark for optimization
	NSMutableArray *pendingClose = [NSMutableArray arrayWithCapacity:[enumerable count]];
	for (YASLThread *thread in enumerable) {
		YASLThreadState state = thread.state;
		//if not picked next thread yet - pick it
    if ((selected == YASL_INVALID_HANDLE) && (state == YASLThreadStateRunning))
			selected = thread->handle;
		else
			//if thread terminated and all opened handles of it was closed - close thread
			if ((state == YASLThreadStateTerminated) && ![_eventsManager findByHandle:thread->handle])
				// can't close it in this loop - that will mutate `enumerable` array, so, fetch terminated threads and close them later
				[pendingClose addObject:thread];
			else
				thread->runned = NO;
	}

	// closing fetched terminated threads
	for (YASLThread *thread in pendingClose)
		[self threadClose:thread->handle];

	// return picked thread handle, if any
	return selected;
}

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:YASLNativeThreadsAPI_waitFor withParamCount:3 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(n_waitFor:params:)];

	[self registerNativeFunction:YASLNativeThreadsAPI_threadStart withParamCount:3 returnType:YASLAPITypeHandle withSelector:@selector(n_threadStart:params:)];

	[self registerNativeFunction:YASLNativeThreadsAPI_threadSuspend withParamCount:2 returnType:YASLBuiltInTypeIdentifierBool withSelector:@selector(n_threadSuspend:params:)];
	[self registerNativeFunction:YASLNativeThreadsAPI_threadResume withParamCount:1 returnType:YASLBuiltInTypeIdentifierBool withSelector:@selector(n_threadResume:params:)];
	[self registerNativeFunction:YASLNativeThreadsAPI_threadTerminate withParamCount:2 returnType:YASLBuiltInTypeIdentifierBool withSelector:@selector(n_threadTerminate:params:)];
}

- (YASLInt) n_waitFor:(YASLNativeFunction *)native params:(void *)paramsBase {
	if (!_activeThreadHandle)
		return YASLEventStateFailed;

	YASLInt eventHandle = [native intParam:1 atBase:paramsBase];
	YASLInt msec = [native intParam:2 atBase:paramsBase];
	YASLInt state = [native intParam:3 atBase:paramsBase];
	[self thread:_activeThreadHandle event:eventHandle waitFor:msec state:state];
	return msec ? YASLEventStateFailed : _activeThread->waitState;
}

- (YASLInt) n_threadStart:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLInt threadStartIP = [native intParam:1 atBase:paramsBase];
	YASLInt threadState = [native intParam:2 atBase:paramsBase];
	YASLInt param = [native intParam:3 atBase:paramsBase];
	YASLThread *thread = [self threadCreateWithEntryAt:threadStartIP andState:threadState andInitParam:param waitable:YES];
	return thread ? thread->handle : YASL_INVALID_HANDLE;
}

- (YASLInt) n_threadSuspend:(YASLNativeFunction *)native params:(void *)paramsBase {
	return [self thread:[native intParam:1 atBase:paramsBase]
							suspend:[native intParam:2 atBase:paramsBase]];
}

- (YASLInt) n_threadResume:(YASLNativeFunction *)native params:(void *)paramsBase {
	return [self threadResume:[native intParam:1 atBase:paramsBase]];
}

- (YASLInt) n_threadTerminate:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLInt handle = [native intParam:1 atBase:paramsBase];
	YASLBool terminated = [self thread:handle
													 terminate:[native intParam:2 atBase:paramsBase]];
	if (terminated)
		[[self eventsManager] closeEvent:handle];
	return terminated;
}

@end
