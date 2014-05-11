//
//  YASLOpcode.m
//  YASL
//
//  Created by Ankh on 10.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLOpcode.h"

@implementation YASLOpcodeOperand

+ (instancetype) register:(YASLIndexedRegister)reg {
	return [self operandInRegister:reg isPointer:NO];
}

+ (instancetype) immediate:(NSNumber *)value {
	return [self operandImmediate:value isPointer:NO];
}

+ (instancetype) operandInRegister:(YASLIndexedRegister)reg andImmediate:(NSNumber *)value isPointer:(BOOL)isPointer {
	return [[self alloc] initWithType:YASLOperandTypeRegister|YASLOperandTypeImmediate register:reg immediate:value isPointer:isPointer];
}

+ (instancetype) operandInRegister:(YASLIndexedRegister)reg isPointer:(BOOL)isPointer {
	return [[self alloc] initWithType:YASLOperandTypeRegister register:reg immediate:@0 isPointer:isPointer];
}

+ (instancetype) operandImmediate:(NSNumber *)value isPointer:(BOOL)isPointer {
	return [[self alloc] initWithType:YASLOperandTypeImmediate register:0 immediate:value isPointer:isPointer];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	type = YASLOperandTypeStraight | YASLOperandTypeRegister;
	reg = YASLRegisterIR0;
	immediate = @0;
	return self;
}

- (id)initWithType:(YASLOperandType)t register:(YASLIndexedRegister)r immediate:(NSNumber *)val isPointer:(BOOL)pointer {
	if (!(self = [self init]))
		return self;

	type = t;
	reg = r;
	immediate = val;
	type = pointer ? type | YASLOperandTypePointer : type;
	return self;
}

- (id) asPointer {
	self->type |= YASLOperandTypePointer;
	return self;
}

@end

@implementation YASLOpcode

+ (instancetype) opcode:(YASLOpcodes)operationCode withOperands:(NSArray *)operands {
	YASLOpcode *opcode = [self new];
	opcode->opcode = operationCode;
	int i = 0;
	for (YASLOpcodeOperand *operand in operands) {
    opcode->operands[i++] = operand;
		if (i > 2)
			break;
	}
	switch (i) {
		case 0:
			opcode->operandsCount = YASLOperandCountNone;
			break;
		case 1:
			opcode->operandsCount = YASLOperandCountUnary;
			break;
		default:
			opcode->operandsCount = YASLOperandCountBinary;
			break;
	}
	return opcode;
}

- (void *) toCodeInstruction:(void *)mem {
	YASLCodeInstruction *i = mem;
	mem = ((char *) mem) + sizeof(YASLCodeInstruction);

	*i = (YASLCodeInstruction){
		.opcode = opcode,
		.type = operandsCount,
		.operand1 = 0,
		.operand2 = 0,
		.r1 = 0,
		.r2 = 0,
	};

	switch (operandsCount) {
		case YASLOperandCountBinary: {
			YASLOpcodeOperand *op = operands[1];
			i->operand2 = op->type;
			i->r2 = op->reg;
		}
		case YASLOperandCountUnary: {
			YASLOpcodeOperand *op = operands[0];
			i->operand1 = op->type;
			i->r1 = op->reg;
			break;
		}
		default:
			break;
	}

	switch (operandsCount) {
		case YASLOperandCountBinary: {
			YASLOpcodeOperand *op = operands[1];
			if (op->type & YASLOperandTypeImmediate) {
				YASLInt val = [op->immediate intValue];
				if ((!val) && (op->type & YASLOperandTypeRegister)) {
					i->operand2 = op->type ^ YASLOperandTypeImmediate;
				} else {
					*((YASLInt *)mem) = val;
					mem = ((char *) mem) + sizeof(YASLInt);
				}
			}
		}
		case YASLOperandCountUnary: {
			YASLOpcodeOperand *op = operands[0];
			if (op->type & YASLOperandTypeImmediate) {
				YASLInt val = [op->immediate intValue];
				if ((!val) && (op->type & YASLOperandTypeRegister)) {
					i->operand1 = op->type ^ YASLOperandTypeImmediate;
				} else {
					*((YASLInt *)mem) = val;
					mem = ((char *) mem) + sizeof(YASLInt);
				}
			}
			break;
		}
		default:
			break;
	}

	return mem;
}

@end
