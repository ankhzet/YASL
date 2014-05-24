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
@interface YASLCPU : YASLThreadsAPI
@property (nonatomic)	YASLRAM *ram;
@property (nonatomic)	YASLStack *stack;

+ (instancetype) cpu;


- (void) run;
- (void) runTo;

- (YASLInt)regValue:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg value:(YASLInt)value;

- (YASLFloat)regValuef:(YASLIndexedRegister)reg;
- (void) setReg:(YASLIndexedRegister)reg valuef:(YASLFloat)value;

- (void) processInstruction;
- (YASLInt) disassemblyAtIP:(YASLInt)ip Instr:(YASLCodeInstruction **)instr opcode1:(YASLInt **)op1 opcode2:(YASLInt **)op2;

@end
