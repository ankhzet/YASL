//
//  YASLThread.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

@class YASLEventsAPI;
@interface YASLThread : NSObject {
@public
	// thread related data, like registers state and sign/zero/halt flags
	YASLThreadStruct data;
	// thread-associated event handle. event and thread states synchronized (only created/terminated state)
	YASLInt handle, parentCodeframe;
	// wait-related data
	YASLInt waitFor, waitState;
	long long startedAt, awakeWithin;
	// thread execution steps count
	NSUInteger steps;
	// was thread runned, or terminated straight after creation without wakeup
	YASLInt param;
	BOOL runned, firstRun;
}

// thread state (ready, running, suspended, terminated)
@property (nonatomic) YASLThreadState state;
// thread exit code
@property (nonatomic) YASLInt exitCode;

+ (instancetype) thread:(BOOL)waitable withEventManager:(YASLEventsAPI *)eventManager;

- (YASLInt)regValue:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg value:(YASLInt)value;

- (YASLFloat)regValuef:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg valuef:(YASLFloat)value;

- (void) suspend:(YASLInt)msec;
- (void) resume;
- (void) terminateWithExitCode:(YASLInt)exitCode;

- (void) event:(YASLInt)eventHandle waitFor:(YASLInt)msec state:(YASLThreadState)state;
+ (long long) ticksMsec;

@end
