//
//  YASLCodeInstruction.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"
#import "YASLThreadsAPI.h"

@class YASLRAM, YASLStack, YASLEventsAPI;
@interface YASLCPU : YASLThreadsAPI {
@public
	YASLRAM *ram;
	YASLStack *stack;
}

+ (instancetype) cpuWithRAMSize:(NSUInteger)size;

- (YASLInt)regValue:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg value:(YASLInt)value;

- (YASLFloat)regValuef:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg valuef:(YASLFloat)value;

- (void) processInstruction;

@end
