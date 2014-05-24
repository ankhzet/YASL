//
//  YASLOpcodes.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLOpcodes_h
#define YASL_YASLOpcodes_h

typedef NS_ENUM(NSUInteger, YASLOperandAccessType) {
	YASLOperandAccessTypeNone        = 0,
	YASLOperandAccessTypeReadFirst   = 1 << 0,
	YASLOperandAccessTypeReadSecond  = 1 << 1,
	YASLOperandAccessTypeWriteFirst  = 1 << 2,
	YASLOperandAccessTypeReadAll     = 1 << 3,
	YASLOperandAccessTypeWriteAll    = 1 << 4,
	YASLOperandAccessTypeModifiesR0  = 1 << 5,
	YASLOperandAccessTypeImpactsFlow = 1 << 6,
	YASLOperandAccessTypeImpactsStack= 1 << 7,
};

typedef NS_ENUM (NSUInteger, YASLOpcodes) {
	OPC_NOP = 0,

	// arithmetic
	OPC_ADD,
	OPC_SUB,
	OPC_MUL,
	OPC_DIV,
	OPC_RST,
	OPC_INC,
	OPC_DEC,
	OPC_MOV,
	OPC_INV,
	OPC_NEG,

	// binary logic
	OPC_NOT,
	OPC_OR,
	OPC_AND,
	OPC_XOR,
	OPC_SHL,
	OPC_SHR,

	// stack
	OPC_PUSH,
	OPC_PUSHV,
	OPC_POP,
	OPC_POPV,
	OPC_SAVE,		// save registers r1-r2 to stack, from lower to higher, ex: save r1-r3
	OPC_LOAD,		// restore registers r1-r2 from stack, from higher to lover, ex: load r3-r0


	// routins
	OPC_CALL,
	OPC_RET,
	OPC_RETV, // return and move stack pointer
	OPC_NATIV,

	// branching
	OPC_JMP,
	OPC_TEST,
	OPC_JZ,
	OPC_JNZ,
	OPC_JGT,
	OPC_JLT,
	OPC_JGE,
	OPC_JLE,

	OPC_CVIF, // convert int > float
	OPC_CVIB, // convert int > bool
	OPC_CVFI, // convert float > int
	OPC_CVFB, // convert float > bool
	OPC_CVFC, // convert float > char
	OPC_CVCF, // convert char > float
	OPC_CVCB, // convert char > bool

	OPC_HALT,
	YASLOpcodesMAX
};

#endif
