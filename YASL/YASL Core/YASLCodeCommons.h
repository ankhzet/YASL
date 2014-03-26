//
//  YASLCodeCommons.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLCodeCommons_h
#define YASL_YASLCodeCommons_h

#import "YASLAPI.h"
#import "YASLOpcodes.h"

#define REG_INDEX(x) ((unsigned char)log2(x & 0xF))

#define CPU_INSTR(_opcode, _type, _op1, _op2, _r1, _r2) {\
.instruction = _opcode,\
.type = _type,\
.operand1 = _op1,\
.operand2 = _op2,\
.r1 = _r1,\
.r2 = _r2,\
}

typedef NS_ENUM(NSUInteger, YASLIndexedRegister) {
	YASLRegisterIR0 = 0, // base register, for function return results, base instructions operations etc
	YASLRegisterIMIN= 0,
	YASLRegisterIR1 = 1, // common register
	YASLRegisterIR2 = 2, // common register
	YASLRegisterIR3 = 3, // common register
	YASLRegisterIR4 = 4, // common register
	YASLRegisterIIP = 5, // instruction pointer
	YASLRegisterISP = 6, // stack pointer
	YASLRegisterIBP = 7, // base pointer
	YASLRegisterIMAX= 7,
};

typedef NS_ENUM(unsigned char, YASLOperandCount) {
	YASLOperandCountNone   = 0,
	YASLOperandCountUnary  = 1,
	YASLOperandCountBinary = 2,
};

typedef NS_ENUM(unsigned char, YASLOperandType) {
	YASLOperandTypeStraight  = 0, // xxx, r0, r0+xxx
	YASLOperandTypePointer   = 1 << 0, // [xxx], [r0], [r0+xxx]
	YASLOperandTypeRegister  = 1 << 1, // register: r0-r4
	YASLOperandTypeImmediate = 1 << 2, // immediate: +-xxx
};

typedef struct {
	// instruction type: add, sub, jump etc
	YASLOpcodes opcode:8;

	// instruction type: common (jne, dec), unary (jmp xxx), binary (add r0, [xxx])
	YASLOperandCount type:2;

	// instruction operand: immediate (-xxx, [xxx]), register (r1, [r1]), both (r0+xxx, [r0+xxx])
	// instruction operand types: straight (r0, r1-xxx, xxx), memory ([r0], [r1-xxx], [xxx])
	YASLOperandType operand1:3;
	YASLOperandType operand2:3;

	YASLIndexedRegister r1:3; // first operand register
	YASLIndexedRegister r2:3; // second operand register

	int spaced:10; // unused
}
__attribute__((packed))
YASLCodeInstruction;

typedef struct {
	YASLInt registers[8];

	bool zero, sign, halt;
} YASLThreadStruct;

typedef NS_ENUM(YASLInt, YASLThreadState) {
	YASLThreadStateNotReady   = 1 << 0,
	YASLThreadStateRunning    = 1 << 1,
	YASLThreadStateSleep      = 1 << 2,
	YASLThreadStateTerminated = 1 << 3,
};

#endif
