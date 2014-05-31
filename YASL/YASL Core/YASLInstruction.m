//
//  YASLInstruction.m
//  YASL
//
//  Created by Ankh on 27.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLInstruction.h"
#import "YASLOpcodes.h"
#import "YASLCodeAddressReference.h"
#import "YASLNativeFunctions.h"
#import "YASLNativeFunction.h"
#import "YASLStrings.h"

NSString *const OPCODE_NAMES[YASLOpcodesMAX] = {
  [OPC_NOP  ] = @"NOP",

  [OPC_ADD  ] = @"ADD",
  [OPC_SUB  ] = @"SUB",
  [OPC_MUL  ] = @"MUL",
  [OPC_DIV  ] = @"DIV",
  [OPC_INC  ] = @"INC",
  [OPC_DEC  ] = @"DEC",
  [OPC_MOV  ] = @"MOV",
  [OPC_INV  ] = @"INV",
  [OPC_NEG  ] = @"NEG",
  [OPC_RST  ] = @"RST",

  [OPC_NOT  ] = @"NOT",
  [OPC_AND  ] = @"AND",
  [OPC_OR   ] = @"DIV",
  [OPC_XOR  ] = @"XOR",
  [OPC_SHL  ] = @"SHL",
  [OPC_SHR  ] = @"SHR",

  [OPC_ADDF ] = @"ADDF",
  [OPC_SUBF ] = @"SUBF",
  [OPC_MULF ] = @"MULF",
  [OPC_DIVF ] = @"DIVF",
  [OPC_INCF ] = @"INCF",
  [OPC_DECF ] = @"DECF",
  [OPC_NEGF ] = @"NEGF",

  [OPC_NOTF ] = @"NOTF",
  [OPC_ANDF ] = @"ANDF",
  [OPC_ORF  ] = @"DIVF",

	[OPC_POP  ] = @"POP",
  [OPC_PUSH ] = @"PUSH",
  [OPC_SAVE ] = @"SAVE",
  [OPC_LOAD ] = @"LOAD",

  [OPC_CALL ] = @"CALL",
  [OPC_RET  ] = @"RET",
  [OPC_RETV ] = @"RETV",
  [OPC_NATIV] = @"NATIV",

  [OPC_JMP  ] = @"JMP",
  [OPC_TEST ] = @"TEST",
  [OPC_TESTF] = @"TESTF",
  [OPC_JZ   ] = @"JZ",
  [OPC_JNZ  ] = @"JNZ",
  [OPC_JGT  ] = @"JGT",
  [OPC_JLT  ] = @"JLT",
  [OPC_JGE  ] = @"JGE",
  [OPC_JLE  ] = @"JLE",

  [OPC_CVCB  ] = @"CVCB",
  [OPC_CVCF  ] = @"CVCF",
  [OPC_CVFB  ] = @"CVFB",
  [OPC_CVFC  ] = @"CVFC",
  [OPC_CVFI  ] = @"CVFI",
  [OPC_CVIB  ] = @"CVIB",
  [OPC_CVIF  ] = @"CVIF",

  [OPC_HALT  ] = @"HALT",
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

@implementation YASLInstruction {
	NSArray *labelRefs;
	YASLStrings *stringsManager;
}

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

- (void) setLabelRefs:(NSArray *)refs {
	labelRefs = refs;
}

- (void) setStringsManager:(YASLStrings *)strings {
	stringsManager = strings;
}

- (NSString *) associatedLabel:(YASLInt)ip {
	NSMutableSet *result = [NSMutableSet set];
	NSMutableDictionary *groups = [NSMutableDictionary dictionary];
	for (NSArray *refOffs in labelRefs) {
		YASLCodeAddressReference * ref = refOffs[0];
    if (ip == ref.address) {
			NSString *label = [NSString stringWithFormat:@":%@",ref.name ? ref.name : @"?"];
			if ([label hasPrefix:@":Line"] || [label hasPrefix:@":case"]) {
				NSString *prefix = [label substringToIndex:5];
				NSMutableSet *group = groups[prefix];
				if (!group)
					group = groups[prefix] = [NSMutableSet set];
				[group addObject:[label substringFromIndex:[label rangeOfString:@" "].location + 1]];
			} else
				[result addObject:label];
		}
	}
	NSMutableString *labels = [@"" mutableCopy];
	for (NSString *group in [groups allKeys]) {
    [labels appendFormat:@"%@ %@", group, [[groups[group] allObjects] componentsJoinedByString:@","]];
	}
	[labels appendString:[[result allObjects] componentsJoinedByString:@""]];
	return [labels length] ? labels : nil;
}

- (NSString *) associatedString:(YASLInt)address {
	NSString *string = [stringsManager stringAt:address];
	return string ? [NSString stringWithFormat:@"\"%@\"", string] : nil;
}

- (YASLInt) immediateValue:(YASLInt)immediate {
	return *(YASLInt *)((char *)immediates + immediate * sizeof(YASLInt));
}

- (NSString *) immediateStr:(YASLInt)immediate withPlusSign:(BOOL)sign {
	if (immediates == NULL)
		return sign ? @"+###" : @"###";

	YASLInt i = [self immediateValue:immediate];
	NSString *label = [self associatedLabel:i];
	if (!label)
		label = [self associatedString:i];

	NSString *immediateStr = [NSString stringWithFormat:@"%@%d", ((i >= 0) & sign) ? @"+" : @"", i];
	return label ? [NSString stringWithFormat:@"%@(%@)",label,immediateStr] : immediateStr;
}

- (NSString *) description {
	NSString *instr;

	NSString *opcode = OPCODE_NAMES[instruction->opcode];
	if (!opcode) opcode = @"XXXXX"; else opcode = [opcode stringByPaddingToLength:5 withString:@" " startingAtIndex:0];

	if (instruction->type == YASLOperandCountNone) {
		instr = opcode;
	} else {
		NSString *operand1 = @"";
		NSString *operand2 = @"";
		int operand = 0;
		switch (instruction->type) {
			case YASLOperandCountBinary: {
				YASLOperandType type = instruction->operand2 & (YASLOperandTypePointer ^ 0xFF);
				BOOL isPointer = !!(instruction->operand2 & YASLOperandTypePointer);
				BOOL isRegister = !!(type & YASLOperandTypeRegister);
				BOOL isImmediate = !!(type & YASLOperandTypeImmediate);

				NSString *r2 = isRegister ? REGISTER_NAMES[instruction->r2] : @"";
				NSString *i2 = isImmediate ? [self immediateStr:operand++ withPlusSign:isRegister] : @"";
				operand2 = [NSString stringWithFormat:@"%@%@", r2, i2];
				if (isPointer) operand2 = [NSString stringWithFormat:@"[%@]", operand2];
				operand2 = [NSString stringWithFormat:@", %@", operand2];
			}
			case YASLOperandCountUnary: {
				if (instruction->opcode == OPC_NATIV) {
					YASLNativeFunctions *natives = [YASLNativeFunctions sharedFunctions];
					YASLNativeFunction *native = [natives findByGUID:[self immediateValue:0]];
					operand1 = native.name;
				} else {
					YASLOperandType type = instruction->operand1 & (YASLOperandTypePointer ^ 0xFF);
					BOOL isPointer = !!(instruction->operand1 & YASLOperandTypePointer);
					BOOL isRegister = !!(type & YASLOperandTypeRegister);
					BOOL isImmediate = !!(type & YASLOperandTypeImmediate);

					NSString *r1 = isRegister ? REGISTER_NAMES[instruction->r1] : @"";
					NSString *i1 = isImmediate ? [self immediateStr:operand++ withPlusSign:isRegister] : @"";
					operand1 = [NSString stringWithFormat:@"%@%@", r1, i1];
					if (isPointer) operand1 = [NSString stringWithFormat:@"[%@]", operand1];
				}
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
