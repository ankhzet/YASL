//
//  YASLOpcode.h
//  YASL
//
//  Created by Ankh on 10.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

#define REG_(_reg) [YASLOpcodeOperand register:YASLRegisterI##_reg]
#define REG_IMM(_reg, _imm) [YASLOpcodeOperand operandInRegister:YASLRegisterI##_reg andImmediate:_imm isPointer:NO]
#define IMM_(_immediate) [YASLOpcodeOperand immediate:(_immediate)]
#define OPC(_opcode, _operands...) [YASLOpcode opcode:_opcode withOperands:@[_operands]]
#define OPC_(_opcode, _operands...) OPC(OPC_##_opcode, _operands)

@interface YASLOpcodeOperand : NSObject <NSCopying> {
	@public
	YASLOperandType type;
	YASLIndexedRegister reg;
	NSNumber *immediate;
}

+ (instancetype) operandInRegister:(YASLIndexedRegister)reg andImmediate:(NSNumber *)value isPointer:(BOOL)isPointer;
+ (instancetype) operandInRegister:(YASLIndexedRegister)reg isPointer:(BOOL)isPointer;
+ (instancetype) operandImmediate:(NSNumber *)value isPointer:(BOOL)isPointer;
+ (instancetype) register:(YASLIndexedRegister)reg;
+ (instancetype) immediate:(NSNumber *)value;
- (id) asPointer;

- (BOOL) isPointer;

@end

@interface YASLOpcode : NSObject {
	@public
	YASLOpcodes opcode;
	YASLOperandCount operandsCount;
	YASLOpcodeOperand *operands[2];
}

+ (instancetype) opcode:(YASLOpcodes)operationCode withOperands:(NSArray *)operands;

/*! Converts into CPU opcode instruction and copies it into memory at `mem` offset, returns new offset> */
- (void *) toCodeInstruction:(void *)mem;

- (YASLOpcodeOperand *) leftOperand;
- (YASLOpcodeOperand *) rightOperand;

@end
