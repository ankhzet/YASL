//
//  YASLOpcodes.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLOpcodes_h
#define YASL_YASLOpcodes_h

typedef NS_ENUM (NSUInteger, YASLOpcodes) {
	OPC_NOP = 0,

	// arithmetic
	OPC_ADD,
	OPC_SUB,
	OPC_MUL,
	OPC_DIV,
	OPC_INC,
	OPC_DEC,
	OPC_MOV,

	// binary logic
	OPC_OR,
	OPC_AND,
	OPC_XOR,
	OPC_SHL,
	OPC_SHR,

	// stack
	OPC_PUSH,
	OPC_POP,
	OPC_SAVE,		// save registers r1-r2 to stack, from lower to higher, ex: save r1-r3
	OPC_LOAD,		// restore registers r1-r2 from stack, from higher to lover, ex: load r3-r0


	// routins
	OPC_CALL,
	OPC_RET,
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

	YASLOpcodesMAX
};

#endif
