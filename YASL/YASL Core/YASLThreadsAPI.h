//
//  YASLThreadsAPI.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNativeInterface.h"
#import "YASLAPI.h"
#import "YASLCodeCommons.h"

@class YASLEventsAPI, YASLThread;
@interface YASLThreadsAPI : YASLNativeInterface {
	@public
	YASLThreadStruct *threadData;
}

@property (nonatomic, readonly) YASLEventsAPI *eventsManager;
@property (nonatomic) YASLInt activeThreadHandle;
@property (nonatomic, weak) YASLThread *activeThread;
@property (nonatomic) BOOL halted;


-(id) initWithEventsManager:(YASLEventsAPI *)eventManager;

- (YASLThread *) threadCreateWithEntryAt:(YASLInt)entry andState:(YASLThreadState)state andInitParam:(YASLInt)param waitable:(BOOL)waitable;
- (YASLThread *) thread:(YASLInt)handle;
- (void) thread:(YASLInt)handle terminate:(YASLInt)exitCode;
- (void) thread:(YASLInt)handle suspend:(YASLInt)msec;
- (void) threadResume:(YASLInt)handle;

/*! Called automaticaly when -[switchThreads] switches to new active thread. In class YASLThreadsAPI does nothing. Must be overrided in subclasses, for ex. for setting registers etc. */
- (void) setActiveThread:(YASLThread *)activeThread;
- (YASLInt) switchThreads;
- (NSUInteger) threadsCount;

@end
