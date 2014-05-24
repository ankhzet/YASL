//
//  YASLASMOptimizationStrategy.m
//  YASL
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLASMOptimizationStrategy.h"
#import "YASLCoreLangClasses.h"

@implementation YASLASMOptimizationStrategy

+ (instancetype) strategyForAssembly:(YASLAssembly *)assembly withHelper:(id<YASLOptimizationStrategyHelper>)helper {
	YASLASMOptimizationStrategy *s = [self new];
	s.assembly = assembly;
	s.helper = helper;
	return s;
}

- (NSUInteger) optimize {
	NSUInteger applied = [self optimizationPass];
	[_assembly restoreFullStack];
	return applied;
}

- (NSUInteger) optimizationPass {
	NSUInteger applied = 0;
	while ([_assembly notEmpty]) {
		if (![self applyable])
			break;

		self.baseState = [_assembly pushState];

		if ([self applyStrategy]) {
			[_assembly popState:self.baseState];
			[_assembly pushBack];
			applied++;
		}
	}
	return applied;
}

- (BOOL) applyable {
	return NO;
}

- (BOOL) applyStrategy {
	return NO;
}

@end

@implementation YASLASMOptimizationStrategy (HelperMethods)

- (NSUInteger) getCurentStateAndRestoreBaseState {
	NSUInteger current = [_assembly pushState];
	[_assembly popState:self.baseState];
	return current;
}

- (BOOL) is:(NSUInteger)opcodeIdx earlierThan:(NSUInteger)otherOpcode {
	return opcodeIdx > otherOpcode;
}

- (NSUInteger) earliest:(NSArray *)states {
	NSUInteger result = 0;
	for (NSNumber *s in states) {
		if ([s unsignedIntegerValue] > result)
			result = [s unsignedIntegerValue];
	}

	return result;
}

- (NSArray *) opcodesByAccessType:(YASLOperandAccessType)type strict:(BOOL)strictMatch {
	if (self.helper)
		return [self.helper opcodesWithType:type strictMatch:strictMatch];

	return @[];
}

- (NSUInteger) reads:(NSArray *)operands {
	NSUInteger offset = 0;
	for (YASLOpcodeOperand *operand in operands) {
    if ([self whoReads:operand]) {
			NSUInteger current = [self getCurentStateAndRestoreBaseState];
			if ([self is:current earlierThan:offset]) {
				offset = current;
			}
		}
	}
	[self getCurentStateAndRestoreBaseState];
	return offset;
}

- (NSUInteger) writes:(NSArray *)operands {
	NSUInteger offset = 0;
	for (YASLOpcodeOperand *operand in operands) {
    if ([self whoWrites:operand]) {
			NSUInteger current = [self getCurentStateAndRestoreBaseState];
			if ([self is:current earlierThan:offset]) {
				offset = current;
			}
		}
	}
	[self getCurentStateAndRestoreBaseState];
	return offset;
}

- (NSUInteger) impacts {
	if ([self whoImpactsExecutionFlow])
		return [self getCurentStateAndRestoreBaseState];
	[self getCurentStateAndRestoreBaseState];
	return 0;
}

- (YASLOpcode *) whoImpactsExecutionFlow {
	NSArray *impacts = [self opcodesByAccessType:YASLOperandAccessTypeImpactsFlow strict:NO];

	return [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		return [impacts containsObject:@(opcode->opcode)];
	}];
}

- (YASLOpcode *) whoReads:(YASLOpcodeOperand *)operand {
	BOOL isSP = [operand isEqual:REG_(SP)];
	BOOL isIP = [operand isEqual:REG_(IP)];
	YASLOperandAccessType filter = YASLOperandAccessTypeReadFirst|YASLOperandAccessTypeReadSecond|YASLOperandAccessTypeReadAll;
	if (isSP) filter |= YASLOperandAccessTypeImpactsStack;
	if (isIP) filter |= YASLOperandAccessTypeImpactsFlow;
	NSArray *reads = [self opcodesByAccessType:filter strict:NO];

	return [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		if (![reads containsObject:@(opcode->opcode)])
			return NO;

		YASLOperandAccessType access = [self.helper opcodeOperandAccessType:opcode->opcode];
		if (isSP && (access & YASLOperandAccessTypeImpactsStack))
			return YES;
		if (isIP && (access & YASLOperandAccessTypeImpactsFlow))
			return YES;

		switch (opcode->operandsCount) {
			case YASLOperandCountBinary: {
				if ((access & YASLOperandAccessTypeReadSecond) && [opcode->operands[1] isEqual:operand])
					return YES;
			}
			case YASLOperandCountUnary: {
				if ((access & YASLOperandAccessTypeReadFirst) && [opcode->operands[0] isEqual:operand])
					return YES;
			}
			default:
				break;
		}
		return NO;
	}];
}

- (YASLOpcode *) whoWrites:(YASLOpcodeOperand *)operand {
	BOOL isR0 = [operand isEqual:REG_(R0)];
	BOOL isSP = [operand isEqual:REG_(SP)];
	BOOL isIP = [operand isEqual:REG_(IP)];
	YASLOperandAccessType filter = YASLOperandAccessTypeWriteFirst|YASLOperandAccessTypeWriteAll;
	if (isR0) filter |= YASLOperandAccessTypeModifiesR0;
	if (isSP) filter |= YASLOperandAccessTypeImpactsStack;
	if (isIP) filter |= YASLOperandAccessTypeImpactsFlow;

	NSArray *writes = [self opcodesByAccessType:filter strict:NO];

	return [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		if (![writes containsObject:@(opcode->opcode)])
			return NO;

		YASLOperandAccessType access = [self.helper opcodeOperandAccessType:opcode->opcode];
		if (isSP && (access & YASLOperandAccessTypeImpactsStack)) return YES;
		if (isIP && (access & YASLOperandAccessTypeImpactsFlow)) return YES;
		if (isR0 && (access & YASLOperandAccessTypeModifiesR0)) return YES;
		switch (opcode->operandsCount) {
			case YASLOperandCountBinary:
			case YASLOperandCountUnary: {
				if ((access & YASLOperandAccessTypeWriteFirst) && [opcode->operands[0] isEqual:operand])
					return YES;
			}
			default:
				break;
		}
		return NO;
	}];
}

- (YASLOpcode *) detectOpcodeInGroup:(NSArray *)group withFirstOperand:(YASLOpcodeOperand *)operand {
	return [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		if (![group containsObject:@(opcode->opcode)])
			return NO;

		if (!operand)
			return YES;

		if (opcode->operandsCount < YASLOperandCountUnary)
			return NO;

		YASLOpcodeOperand *firstOperand = opcode->operands[0];
		return [firstOperand isEqual:operand];
	}];
}

- (YASLOpcode *) detectOpcode:(YASLOpcodes)opCode {
	return [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		return opcode->opcode == opCode;
	}];
}

- (YASLOpcode *) detectOpcodeWithFilter:(BOOL(^)(YASLOpcode *opcode))filter {
	Class opcodeClass = [YASLOpcode class];
	while ([_assembly notEmpty]) {
		id top = [_assembly pop];
		if (![top isKindOfClass:opcodeClass])
			continue;

		if (!filter(top))
			continue;

		return top;
	}

	return nil;
}

@end
