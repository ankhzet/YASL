//
//  YASLCodeInstruction.m
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCPU.h"
#import "YASLRAM.h"
#import "YASLStack.h"
#import "YASLOpcodes.h"
#import "YASLNativeFunctions.h"
#import "YASLNativeFunction.h"
#import "YASLEventsAPI.h"
#import "YASLThread.h"

@interface YASLCPU () {
	YASLThreadStruct state;
	__weak YASLNativeFunctions *nativeFunctions;
}

@end

typedef YASLInt*(^YASLGetOperandBlock)(YASLCPU *cpu, YASLInt *ip, YASLInt *ptr, YASLOperandType type, YASLIndexedRegister r);
YASLGetOperandBlock SimpleGetOperandBlock = ^YASLInt*(YASLCPU *cpu, YASLInt *ip, YASLInt *ptr, YASLOperandType type, YASLIndexedRegister r) {

	YASLInt *temp = ptr;
	if (type & YASLOperandTypeImmediate) {
		*temp = *(YASLInt *)[cpu->ram dataAt:*ip];
		*ip += sizeof(YASLInt);
	}

	if (type & YASLOperandTypeRegister) {
		YASLInt *reg = &cpu->threadData->registers[r];
		if (type & YASLOperandTypeImmediate)
			*temp += *reg;
		else
			temp = reg;
	}

	if (type & YASLOperandTypePointer)
		temp = [cpu->ram dataAt:*temp];

	return temp;
};

typedef void (^YASLCPUSetOperandBlock)(YASLThreadStruct *threadData, YASLInt *operand, YASLInt value);
YASLCPUSetOperandBlock simpleSetter = ^void(YASLThreadStruct *threadData, YASLInt *operand, YASLInt value) {
	*operand = value;
	threadData->zero = value == 0;
	threadData->sign = value < 0;
};

@implementation YASLCPU

+ (instancetype) cpuWithRAMSize:(NSUInteger)size {
	return [(YASLCPU *)[self alloc] initWithRAMSize:size];
}

//TODO: move ram/stack/eventmanager creation outside of cpu class

- (id)initWithRAMSize:(NSUInteger)size {
	if (!(self = [super initWithEventsManager:[YASLEventsAPI new]]))
		return self;

	ram = [YASLRAM ramWithSize:size];
	stack = [YASLStack stackForRAM:ram];
	stack.size = ram.size * 0.2;
	stack.base = ram.size - stack.size;

	nativeFunctions = [YASLNativeFunctions sharedFunctions];
	nativeFunctions.attachedRAM = ram;
	nativeFunctions.attachedStack = stack;
	nativeFunctions.attachedCPU = self;

	return self;
}

- (YASLInt)regValue:(YASLIndexedRegister)reg {
	return threadData->registers[reg];
}

- (void) setReg:(YASLIndexedRegister)reg value:(YASLInt)value {
	threadData->registers[reg] = value;
}

- (YASLFloat)regValuef:(YASLIndexedRegister)reg {
	return *(YASLFloat *)&threadData->registers[reg];
}

- (void) setReg:(YASLIndexedRegister)reg valuef:(YASLFloat)value {
	*(YASLFloat *)&threadData->registers[reg] = value;
}

#pragma mark - CPU cycles

- (void) run {
	NSUInteger steps = 0;
	do {
		if ([self switchThreads] != YASL_INVALID_HANDLE) {
			[self processInstruction];
			steps = ++self.activeThread->steps;
		} else
			break;
	} while (!(self.halted || threadData->halt || (steps % 50 == 0)));

	//TODO: here must be callback & sleep
}

- (void) runTo {
	YASLThreadStruct s = [self disASM:threadData->registers[YASLRegisterIIP]];
	YASLInt breakpoint = s.registers[YASLRegisterIIP];
	do {
		[self processInstruction];
	} while (!(self.halted || (threadData->registers[YASLRegisterIIP] == breakpoint)));
}

- (YASLThreadStruct) disASM:(YASLInt)ip {
	YASLThreadStruct s = *threadData;
	return s;
}

#pragma mark - Instructions processing

- (void) processInstruction {
	threadData->halt = false;

	YASLInt *ip = &threadData->registers[YASLRegisterIIP];
	YASLInt *sp = &threadData->registers[YASLRegisterISP];
	YASLInt stackOldTop = stack.top;

	YASLCodeInstruction *instr = [ram dataAt:*ip];
	*ip += sizeof(YASLCodeInstruction);

	if (instr->opcode == OPC_NOP) {
		return;
	}

	YASLInt *op1 = NULL, *op2 = NULL;
	switch (instr->type) {
		case YASLOperandCountBinary: {
			YASLInt tmp;
			op2 = SimpleGetOperandBlock(self, ip, &tmp, instr->operand2, instr->r2);
		}
		case YASLOperandCountUnary: {
			YASLInt tmp;
			op1 = SimpleGetOperandBlock(self, ip, &tmp, instr->operand1, instr->r1);
			break;
		}
		default:
			break;
	}

	switch (instr->opcode) {
			// arithmetic
		case OPC_ADD: simpleSetter(threadData, op1, *op1 + *op2); break;
		case OPC_SUB: simpleSetter(threadData, op1, *op1 - *op2); break;
		case OPC_MUL: simpleSetter(threadData, op1, *op1 * *op2); break;
		case OPC_DIV: simpleSetter(threadData, op1, *op1 / *op2); break;
		case OPC_INC:	simpleSetter(threadData, op1, ++(*op1)); break;
		case OPC_DEC: simpleSetter(threadData, op1, --(*op1)); break;
		case OPC_MOV: simpleSetter(threadData, op1, *op2); break;

			// binary logic
		case OPC_OR : simpleSetter(threadData, op1, *op1 | *op2); break;
		case OPC_AND: simpleSetter(threadData, op1, *op1 & *op2); break;
		case OPC_XOR: simpleSetter(threadData, op1, *op1 ^ *op2); break;
		case OPC_SHL: simpleSetter(threadData, op1, *op1 << *op2); break;
		case OPC_SHR: simpleSetter(threadData, op1, *op1 >> *op2); break;

			// stack
		case OPC_PUSH: [stack push:*op1]; break;
		case OPC_POP : simpleSetter(threadData, op1, [stack pop]); break;

		case OPC_SAVE:
			for (int r = REG_INDEX(instr->r1); r <= REG_INDEX(instr->r2); r++) {
				[stack push:threadData->registers[r]];
			}
			break;
		case OPC_LOAD:
			for (int r = REG_INDEX(instr->r1); r >= REG_INDEX(instr->r2); r--) {
				threadData->registers[r] = [stack pop];
			}
			break;

		default:
			switch (instr->opcode) {
					// routins
				case OPC_CALL: {
					[stack push:*ip];
					*ip = *op1;
					break;
				}
				case OPC_RET: {
					*ip = [stack pop];
					break;
				}
					// native functions call
				case OPC_NATIV: {
					NSUInteger guid = (NSUInteger)(*op1);
					YASLNativeFunction *function = [nativeFunctions findByGUID:guid];
					if (!function) {
						threadData->halt = true;
						//TODO: unknown native function instruction handling
						return;
					}
					YASLInt returnValue = [function callOnParamsBase:[ram dataAt:stack.base + stack.top - sizeof(YASLInt)]];

					[self setReg:YASLRegisterIR0 value:returnValue];

					if (function.params)
						[stack popSpace:function.params];

					break;
				}

					// branching
				case OPC_JMP: *ip = *op1; break;

				case OPC_TEST: {
					YASLInt delta = *op1 - *op2;
					threadData->zero = delta == 0;
					threadData->sign = delta < 0;
					break;
				}

				case OPC_JZ:
					if (threadData->zero)
						*ip = *op1;
					break;
				case OPC_JNZ:
					if (!threadData->zero)
						*ip = *op1;
					break;
				case OPC_JGT:
					if (!(threadData->zero || threadData->sign))
						*ip = *op1;
					break;
				case OPC_JLT:
					if (threadData->sign)
						*ip = *op1;
					break;
				case OPC_JGE:
					if (!threadData->sign)
						*ip = *op1;
					break;
				case OPC_JLE:
					if (threadData->zero || threadData->sign)
						*ip = *op1;
					break;

				default:
					threadData->halt = true;
					break;
			}
	}
	if (stackOldTop != stack.top) *sp = stack.top;
	if (stackOldTop != *sp) stack.top = *sp;
}

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:@"sqrt" withParamCount:1 returnType:@"float" withSelector:@selector(n_sqrt:params:)];
}

- (YASLInt) n_sqrt:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLFloat p1 = [native floatParam:1 atBase:paramsBase];
	p1 = sqrt(p1);
	return *(YASLInt *)(&p1);
}

@end
