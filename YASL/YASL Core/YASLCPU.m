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

@implementation YASLCPU
@synthesize ram = _ram;
@synthesize stack = _stack;
@synthesize paused = _paused;

+ (instancetype) cpu {
	return [(YASLCPU *)[self alloc] init];
}

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
		[_stack push:[activeThread regValue:YASLRegisterIIP]];
		activeThread->firstRun = NO;
	}
}

- (void) run {
	NSUInteger steps = 0, noop = 0;
	do {
		_paused = NO;
		do {
			if ([self switchThreads] == YASL_INVALID_HANDLE) {
//					halted = YES;
				noop++;
				break;
			} else
				noop = 0;

			[self processInstruction];
			steps = ++self.activeThread->steps;
			_paused = self.halted || threadData->halt;
		} while (!(_paused || (steps % 50 == 0)));

		if (_cpuDelegate) {
			if (noop > 100)
				[_cpuDelegate noOp:self forTicks:noop];
			else
				[_cpuDelegate betweenCycles:self thread:self.activeThread];
		} else
			if (noop > 100)
				break;
	} while (!_paused);
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
//	threadData->halt = false;

	YASLInt *ip = &threadData->registers[YASLRegisterIIP];

	YASLCodeInstruction *instr = [_ram dataAt:*ip];
	*ip += sizeof(YASLCodeInstruction);
	YASLOpcodes opcode = instr->opcode;

	if (opcode == OPC_NOP) {
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

	switch (opcode) {
		case OPC_MOV: {
			*op1 = *op2;
			threadData->zero = *op1 == 0;
			threadData->sign = *op1 < 0;
		}
			// arithmetic
		case OPC_ADD: case OPC_SUB: case OPC_MUL: case OPC_DIV: case OPC_RST:
		case OPC_OR : case OPC_AND: case OPC_XOR: case OPC_SHL: case OPC_SHR:
		case OPC_INC: case OPC_DEC: case OPC_INV: case OPC_NEG: case OPC_NOT:
		{
			switch (opcode) {
				case OPC_ADD: *op1 = *op1 + *op2; break;
				case OPC_SUB: *op1 = *op1 - *op2; break;
				case OPC_MUL: *op1 = *op1 * *op2; break;
				case OPC_DIV: *op1 = *op1 / *op2; break;
				case OPC_RST: *op1 = *op1 % *op2; break;
				case OPC_OR : *op1 = *op1 | *op2; break;
				case OPC_AND: *op1 = *op1 & *op2; break;
				case OPC_XOR: *op1 = *op1 ^ *op2; break;
				case OPC_SHL: *op1 = *op1 << *op2; break;
				case OPC_SHR: *op1 = *op1 >> *op2; break;
				case OPC_INC:	*op1 = ++(*op1); break;
				case OPC_DEC: *op1 = --(*op1); break;
				case OPC_INV: *op1 = ~*op1; break;
				case OPC_NEG: *op1 = -*op1; break;
				case OPC_NOT: *op1 = !*op1; break;
				default:;
			}
			threadData->zero = *op1 == 0;
			threadData->sign = *op1 < 0;
			break;
		}

			// arithmetic fp
		case OPC_ADDF: case OPC_SUBF: case OPC_MULF: case OPC_DIVF:
		case OPC_ORF : case OPC_ANDF: case OPC_NOTF:
		case OPC_INCF: case OPC_DECF: case OPC_NEGF:
		{
			YASLFloat *fop1 = (YASLFloat *)op1;
			YASLFloat *fop2 = (YASLFloat *)op2;
			switch (opcode) {
				case OPC_ADDF: *fop1 = *fop1 + *fop2; break;
				case OPC_SUBF: *fop1 = *fop1 - *fop2; break;
				case OPC_MULF: *fop1 = *fop1 * *fop2; break;
				case OPC_DIVF: *fop1 = *fop1 / *fop2; break;
				case OPC_ORF : *fop1 = *fop1 || *fop2; break;
				case OPC_ANDF: *fop1 = *fop1 && *fop2; break;
				case OPC_INCF: *fop1 = ++(*fop1); break;
				case OPC_DECF: *fop1 = --(*fop1); break;
				case OPC_NEGF: *fop1 = -*fop1; break;
				case OPC_NOTF: *fop1 = !*fop2; break;
				default:;
			}
			threadData->zero = *fop1 == 0;
			threadData->sign = *fop1 < 0;
			break;
		}

			// stack
		case OPC_PUSH : [_stack push:*op1]; break;
		case OPC_POP: *op1 = [_stack pop]; break;

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

		case OPC_CVFB:
		case OPC_CVFC:
		case OPC_CVFI: {
			YASLFloat f = *(YASLFloat *)op1;
			switch (opcode) {
				case OPC_CVFB: {
					YASLBool b = !!f;
					*op1 = *((YASLInt *)&b);
					threadData->zero = b == 0;
					threadData->sign = false;
					break;
				}
				case OPC_CVFC: {
					YASLChar c = f;
					*op1 = *((YASLInt *)&c);
					threadData->zero = c == 0;
					threadData->sign = false;
					break;
				}
				case OPC_CVFI: {
					*op1 = f;
					threadData->zero = f == 0;
					threadData->sign = f < 0;
					break;
				}
				default: ;
			}
			break;
		}
		case OPC_CVIF:
		case OPC_CVIB: {
			switch (opcode) {
				case OPC_CVIF: {
					YASLFloat f = *op1;
					*op1 = *((YASLInt *)&f);
					threadData->zero = f == 0;
					threadData->sign = f < 0;
					break;
				}
				case OPC_CVIB: {
					YASLBool b = !!*op1;
					*op1 = *((YASLInt *)&b);
					threadData->zero = b == 0;
					threadData->sign = false;
					break;
				}
				default: ;
			}
			break;
		}
		case OPC_CVCF:
		case OPC_CVCB: {
			YASLChar c = *(YASLChar *)op1;
			switch (opcode) {
				case OPC_CVCF: {
					YASLFloat f = c;
					*op1 = *((YASLInt *)&f);
					threadData->zero = f == 0;
					threadData->sign = f < 0;
					break;
				}
				case OPC_CVCB: {
					YASLBool b = !!c;
					*op1 = *((YASLInt *)&b);
					threadData->zero = b == 0;
					threadData->sign = false;
					break;
				}
				default: ;
			}
			break;
		}

		default:
			switch (opcode) {
					// routins
				case OPC_CALL: {
					[_stack push:*ip];
					*ip = *op1;
					break;
				}
				case OPC_RET: *ip = [_stack pop]; break;
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

					if (![function.returns isEqualToString:YASLBuiltInTypeIdentifierVoid])
						[self setReg:YASLRegisterIR0 value:returnValue];

					if (function.params)
						[_stack popSpace:(YASLInt)(function.params * sizeof(YASLInt))];

					break;
				}

					// branching
				case OPC_TEST: {
					YASLInt delta = *op1 - *op2;
					threadData->zero = delta == 0;
					threadData->sign = delta < 0;
					break;
				}
				case OPC_TESTF: {
					YASLFloat delta = *(YASLFloat *)op1 - *(YASLFloat *)op2;
					threadData->zero = delta == 0;
					threadData->sign = delta < 0;
					break;
				}

				case OPC_JMP: *ip = *op1; break;
				case OPC_JZ: case OPC_JNZ: case OPC_JGT:
				case OPC_JLT: case OPC_JGE: case OPC_JLE:
				{
					BOOL condition = false;
					switch (opcode) {
						case OPC_JZ : condition = threadData->zero; break;
						case OPC_JNZ: condition = !threadData->zero; break;
						case OPC_JGT: condition = !(threadData->zero || threadData->sign); break;
						case OPC_JLT: condition = threadData->sign; break;
						case OPC_JGE: condition = !threadData->sign; break;
						case OPC_JLE: condition = threadData->zero || threadData->sign; break;
						default: ;
					}
					if (condition)
						*ip = *op1;
					break;
				}

				default:
					threadData->halt = true;
					break;
			}
	}
}

- (YASLInt) disassemblyAtIP:(YASLInt)ip instr:(YASLCodeInstruction **)instr opcode1:(YASLInt **)op1 opcode2:(YASLInt **)op2 {
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

	[self registerNativeFunction:YASLNativeCPU_sqrt withParamCount:1 returnType:YASLBuiltInTypeIdentifierFloat withSelector:@selector(n_sqrt:params:)];
	[self registerNativeFunction:YASLNativeCPU_currentThread withParamCount:0 returnType:YASLAPITypeHandle withSelector:@selector(n_threadHandle:params:)];
}

- (YASLInt) n_sqrt:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLFloat p1 = [native floatParam:1 atBase:paramsBase];
	p1 = sqrt(p1);
	return *((YASLInt *)(&p1));
}

- (YASLInt) n_threadHandle:(YASLNativeFunction *)native params:(void *)paramsBase {
	return self.activeThreadHandle;
}

@end
