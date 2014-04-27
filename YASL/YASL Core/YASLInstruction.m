//
//  YASLInstruction.m
//  YASL
//
//  Created by Ankh on 27.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLInstruction.h"
#import "YASLOpcodes.h"

NSString *const OPCODE_NAMES[YASLOpcodesMAX] = {
  [OPC_NOP  ] = @"NOP",

  [OPC_ADD  ] = @"ADD",
  [OPC_SUB  ] = @"SUB",
  [OPC_MUL  ] = @"MUL",
  [OPC_DIV  ] = @"DIV",
  [OPC_INC  ] = @"INC",
  [OPC_DEC  ] = @"DEC",
  [OPC_MOV  ] = @"MOV",

  [OPC_AND  ] = @"AND",
  [OPC_OR   ] = @"DIV",
  [OPC_XOR  ] = @"XOR",
  [OPC_SHL  ] = @"SHL",
  [OPC_SHR  ] = @"SHR",

  [OPC_POP  ] = @"POP",
  [OPC_PUSH ] = @"PUSH",
  [OPC_SAVE ] = @"SAVE",
  [OPC_LOAD ] = @"LOAD",

  [OPC_CALL ] = @"CALL",
  [OPC_RET  ] = @"RET",
  [OPC_NATIV] = @"NATIV",

  [OPC_JMP  ] = @"JMP",
  [OPC_TEST ] = @"TEST",
  [OPC_JZ   ] = @"JZ",
  [OPC_JNZ  ] = @"JNZ",
  [OPC_JGT  ] = @"JGT",
  [OPC_JLT  ] = @"JLT",
  [OPC_JGE  ] = @"JGE",
  [OPC_JLE  ] = @"JLE",
};

NSString *const REGISTER_NAMES[YASLRegisterIMAX + 1] = {
  [YASLRegisterIR0] = @"R0",
  [YASLRegisterIR1] = @"R1",
  [YASLRegisterIR2] = @"R2",
  [YASLRegisterIR3] = @"R3",
  [YASLRegisterIR4] = @"R4",
  [YASLRegisterIIP] = @"IP",
  [YASLRegisterISP] = @"SP",
  [YASLRegisterIBP] = @"BP",
};

@implementation YASLInstruction

+ (instancetype) instruction:(YASLCodeInstruction *)i {
	return [(YASLInstruction *)[self alloc] initWithInstruction:i];
}

- (id)initWithInstruction:(YASLCodeInstruction *)i {
	if (!(self = [super init]))
		return self;

	[self setInstruction:i];
	return self;
}

- (void) setInstruction:(YASLCodeInstruction *)i {
	instruction = i;
}

- (YASLCodeInstruction *) instruction {
	return instruction;
}

- (void) setImmediatePtr:(void *)ptr {
	immediates = ptr;
}

- (NSString *) immediateStr:(YASLInt)immediate withPlusSign:(BOOL)sign {
	if (immediates == NULL)
		return sign ? @"+###" : @"###";

	YASLInt i = *(YASLInt *)((char *)immediates + immediate * sizeof(YASLInt));
	return [NSString stringWithFormat:@"%@%i", ((i > 0) & sign) ? @"+" : @"", i];
}

- (NSString *) description {
	NSString *instr;

	NSString *opcode = OPCODE_NAMES[instruction->opcode];
	if (!opcode) opcode = @"XXX";

	if (instruction->type == YASLOperandCountNone) {
		instr = opcode;
	} else {
		NSString *operand1 = @"";
		NSString *operand2 = @"";
		int operands = instruction->type;
		switch (instruction->type) {
			case YASLOperandCountBinary: {
				YASLOperandType type = instruction->operand2 & (YASLOperandTypePointer ^ 0xFF);
				BOOL isPointer = !!(instruction->operand2 & YASLOperandTypePointer);
				BOOL isRegister = !!(type & YASLOperandTypeRegister);
				BOOL isImmediate = !!(type & YASLOperandTypeImmediate);

				NSString *r2 = isRegister ? REGISTER_NAMES[instruction->r2] : @"";
				NSString *i2 = isImmediate ? [self immediateStr:0 withPlusSign:isRegister] : @"";
				operand2 = [NSString stringWithFormat:@"%@%@", r2, i2];
				if (isPointer) operand2 = [NSString stringWithFormat:@"[%@]", operand2];
				operand2 = [NSString stringWithFormat:@", %@", operand2];
			}
			case YASLOperandCountUnary: {
				YASLOperandType type = instruction->operand1 & (YASLOperandTypePointer ^ 0xFF);
				BOOL isPointer = !!(instruction->operand1 & YASLOperandTypePointer);
				BOOL isRegister = !!(type & YASLOperandTypeRegister);
				BOOL isImmediate = !!(type & YASLOperandTypeImmediate);

				NSString *r1 = isRegister ? REGISTER_NAMES[instruction->r1] : @"";
				NSString *i1 = isImmediate ? [self immediateStr:operands - 1 withPlusSign:isRegister] : @"";
				operand1 = [NSString stringWithFormat:@"%@%@", r1, i1];
				if (isPointer) operand1 = [NSString stringWithFormat:@"[%@]", operand1];
				break;
			}
			default:
				break;
		}
		instr = [NSString stringWithFormat:@"%@ %@%@", opcode, operand1, operand2];
	}
	
	return instr;
}

@end
