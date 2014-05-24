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
@public
	YASLRAM *_ram;
	YASLStack *_stack;
@protected
	YASLThreadStruct state;
	__weak YASLNativeFunctions *nativeFunctions;
}

@end

typedef YASLInt*(^YASLGetOperandBlock)(YASLCPU *cpu, YASLInt *ip, YASLInt *ptr, YASLOperandType type, YASLIndexedRegister r);
YASLGetOperandBlock SimpleGetOperandBlock = ^YASLInt*(YASLCPU *cpu, YASLInt *ip, YASLInt *ptr, YASLOperandType type, YASLIndexedRegister r) {

	YASLInt *temp = ptr;
	if (type & YASLOperandTypeImmediate) {
		*temp = *(YASLInt *)[cpu->_ram dataAt:*ip];
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
		temp = [cpu->_ram dataAt:*temp];

	return temp;
};

typedef void (^YASLCPUSetOperandBlock)(YASLThreadStruct *threadData, YASLInt *operand, YASLInt value);
YASLCPUSetOperandBlock simpleSetter = ^void(YASLThreadStruct *threadData, YASLInt *operand, YASLInt value) {
	*operand = value;
	threadData->zero = value == 0;
	threadData->sign = value < 0;
};

@implementation YASLCPU
@synthesize ram = _ram;
@synthesize stack = _stack;

+ (instancetype) cpu {
	return [(YASLCPU *)[self alloc] init];
}

//TODO: move ram/stack/eventmanager creation outside of cpu class

- (id)init {
	if (!(self = [super initWithEventsManager:[YASLEventsAPI new]]))
		return self;

	nativeFunctions = [YASLNativeFunctions sharedFunctions];
	nativeFunctions.attachedCPU = self;

	return self;
}

- (void) setRam:(YASLRAM *)ram {
	if (_ram == ram)
		return;

	_ram = ram;
	nativeFunctions.attachedRAM = ram;
}

- (void) setStack:(YASLStack *)stack {
	if (_stack == stack)
		return;

	_stack = stack;
	nativeFunctions.attachedStack = stack;
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

- (void) setActiveThread:(YASLThread *)activeThread {
	if (!activeThread)
		return;

	_stack.top = &threadData->registers[YASLRegisterISP];
	if (activeThread->firstRun) {
		[_stack push:activeThread->param];
		[_stack push:0];
		activeThread->firstRun = NO;
	}
}

- (void) run {
	NSUInteger steps = 0;
	BOOL halted;
	do {
		do {
			if (steps % 10 == 0) {
				if ([self switchThreads] == YASL_INVALID_HANDLE)
					break;
			}

			[self processInstruction];
			steps = ++self.activeThread->steps;
			halted = self.halted || threadData->halt;
		} while (!(halted || (steps % 50 == 0)));

		//TODO: here must be callback & sleep

	} while (!halted);
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

	YASLCodeInstruction *instr = [_ram dataAt:*ip];
	*ip += sizeof(YASLCodeInstruction);

	if (instr->opcode == OPC_NOP) {
		return;
	}

	YASLInt tmp1 = 0xF0, tmp2 = 0x0F;
	YASLInt *op1 = &tmp1, *op2 = &tmp2;
	switch (instr->type) {
		case YASLOperandCountBinary: {
			op2 = SimpleGetOperandBlock(self, ip, &tmp1, instr->operand2, instr->r2);
		}
		case YASLOperandCountUnary: {
			op1 = SimpleGetOperandBlock(self, ip, &tmp2, instr->operand1, instr->r1);
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
		case OPC_RST: simpleSetter(threadData, op1, *op1 % *op2); break;
		case OPC_INC:	simpleSetter(threadData, op1, ++(*op1)); break;
		case OPC_DEC: simpleSetter(threadData, op1, --(*op1)); break;
		case OPC_MOV: simpleSetter(threadData, op1, *op2); break;
		case OPC_INV: simpleSetter(threadData, op1, ~*op1); break;
		case OPC_NEG: simpleSetter(threadData, op1, -*op1); break;

			// binary logic
		case OPC_NOT: simpleSetter(threadData, op1, !*op1); break;
		case OPC_OR : simpleSetter(threadData, op1, *op1 | *op2); break;
		case OPC_AND: simpleSetter(threadData, op1, *op1 & *op2); break;
		case OPC_XOR: simpleSetter(threadData, op1, *op1 ^ *op2); break;
		case OPC_SHL: simpleSetter(threadData, op1, *op1 << *op2); break;
		case OPC_SHR: simpleSetter(threadData, op1, *op1 >> *op2); break;

			// stack
		case OPC_PUSH : [_stack push:*op1]; break;
		case OPC_POP  : simpleSetter(threadData, op1, [_stack pop]); break;
		case OPC_PUSHV: [_stack pushSpace:*op1]; break;
		case OPC_POPV : [_stack popSpace:*op1]; break;

		case OPC_SAVE :
			for (int r = REG_INDEX(instr->r1); r <= REG_INDEX(instr->r2); r++) {
				[_stack push:threadData->registers[r]];
			}
			break;
		case OPC_LOAD :
			for (int r = REG_INDEX(instr->r1); r >= REG_INDEX(instr->r2); r--) {
				threadData->registers[r] = [_stack pop];
			}
			break;

		case OPC_CVFI: simpleSetter(threadData, op1, (YASLInt)(*((YASLFloat *)op1))); break;
		case OPC_CVIF: simpleSetter(threadData, op1, (YASLFloat)(*((YASLInt *)op1))); break;
		case OPC_CVCF: simpleSetter(threadData, op1, (YASLFloat)(*((YASLChar *)op1))); break;
		case OPC_CVFC: simpleSetter(threadData, op1, (YASLChar)(*((YASLFloat *)op1))); break;
		case OPC_CVIB: simpleSetter(threadData, op1, (YASLBool)(!!*((YASLInt *)op1))); break;
		case OPC_CVFB: simpleSetter(threadData, op1, (YASLBool)(!!*((YASLFloat *)op1))); break;
		case OPC_CVCB: simpleSetter(threadData, op1, (YASLBool)(!!*((YASLChar *)op1))); break;

		default:
			switch (instr->opcode) {
					// routins
				case OPC_CALL: {
					[_stack push:*ip];
					*ip = *op1;
					break;
				}
				case OPC_RET: {
					*ip = [_stack pop];
					break;
				}
				case OPC_RETV: {
					*ip = [_stack pop];
					[_stack popSpace:*op1];
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
					YASLInt returnValue = [function callOnParamsBase:[_ram dataAt:*_stack.top - sizeof(YASLInt)]];

					[self setReg:YASLRegisterIR0 value:returnValue];

					if (function.params)
						[_stack popSpace:function.params];

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
}

- (YASLInt) disassemblyAtIP:(YASLInt)ip Instr:(YASLCodeInstruction **)instr opcode1:(YASLInt **)op1 opcode2:(YASLInt **)op2 {
	threadData->halt = false;

	YASLInt *_ip = &ip;

	*instr = [_ram dataAt:*_ip];
	*_ip += sizeof(YASLCodeInstruction);

	if ((*instr)->opcode == OPC_NOP) {
		return ip;
	}

	YASLInt tmp1 = 0xF0, tmp2 = 0x0F;
	switch ((*instr)->type) {
		case YASLOperandCountBinary: {
			*op2 = SimpleGetOperandBlock(self, _ip, &tmp1, (*instr)->operand2, (*instr)->r2);
		}
		case YASLOperandCountUnary: {
			*op1 = SimpleGetOperandBlock(self, _ip, &tmp2, (*instr)->operand1, (*instr)->r1);
			break;
		}
		default:
			break;
	}
	return ip;
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
