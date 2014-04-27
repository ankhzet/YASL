//
//  YASLThreadsAPISpec.m
//  YASL
//  Spec for YASLThreadsAPI
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLThreadsAPI.h"
#import "YASLThread.h"
#import "YASLEventsAPI.h"
#import "YASLEvent.h"

SPEC_BEGIN(YASLThreadsAPISpec)

describe(@"YASLThreadsAPI", ^{
	it(@"should properly initialize", ^{
		YASLEventsAPI *em = [YASLEventsAPI new];
		YASLThreadsAPI *instance = [[YASLThreadsAPI alloc] initWithEventsManager:em];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLThreadsAPI class]];
		[[instance.eventsManager should] equal:em];
	});

	it(@"should create threads", ^{
		YASLEventsAPI *em = [YASLEventsAPI new];
		YASLThreadsAPI *threads = [[YASLThreadsAPI alloc] initWithEventsManager:em];

		YASLThreadState state = YASLThreadStateRunning;
		YASLThread *thread = [threads threadCreateWithEntryAt:0 andState:state andInitParam:0 waitable:true];
		[[thread shouldNot] beNil];
		[[theValue(thread->handle) shouldNot] equal:theValue(YASL_INVALID_HANDLE)];
		[[theValue(thread.state) should] equal:theValue(state)];

		YASLEvent *threadEvent = [em findByHandle:thread->handle];
		[[threadEvent shouldNot] beNil];
		[[theValue(threadEvent.links) should] beGreaterThan:theValue(1)];
		[[theValue(threadEvent.state) should] equal:theValue(state)];
	});
});

SPEC_END
