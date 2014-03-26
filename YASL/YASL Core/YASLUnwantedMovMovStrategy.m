//
//  YASLUnwantedMovMovStrategy.m
//  YASL
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnwantedMovMovStrategy.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnwantedMovMovStrategy {
	YASLOpcode *firstMov;
}

- (BOOL) applyable {
	firstMov = [self detectOpcode:OPC_MOV];
	return !!firstMov;
}

/*
 mov left, right
 mov left2, [left]
 ->
 mov left2, [right]
 _____________
 mov left, right
 ...
 not read, write (left, right)
 not impacts execution flow
 left2 and right can't both be []
 can't read left before write left
 ...
 mov left2, [right]

 =============
 mov left, right
 mov left2, left
 ->
 mov left2, right
 _____________
 mov left, right
 ...
 not read, write (left, right)
 not impacts execution flow
 left2 and right can't both be []
 can't read left before write left
 ...
 mov left2, right

 */
- (BOOL) applyStrategy {
	YASLOpcodeOperand *left = [firstMov leftOperand], *right = [firstMov rightOperand];
	BOOL rightIsMem = [right isPointer];
	BOOL mustUnref = NO;

	NSArray *readWrites = [self opcodesByAccessType:YASLOperandAccessTypeReadFirst|YASLOperandAccessTypeReadSecond|YASLOperandAccessTypeWriteFirst strict:NO];

	YASLOpcode *secondMov = [self detectOpcodeWithFilter:^BOOL(YASLOpcode *opcode) {
		if (![readWrites containsObject:@(opcode->opcode)])
			return NO;

		switch (opcode->operandsCount) {
			case YASLOperandCountBinary: {
				if ([opcode->operands[1] isEqual:left])
					break;
			}
			default:
				return NO;
		}

		// right is mem operand ([r0]), cant unref it anyway
		if (rightIsMem) {
			if (opcode->operands[1]->type & YASLOperandTypePointer)
				return NO;
		}

		return YES;
	}];
	NSUInteger secondAt = [self getCurentStateAndRestoreBaseState];
	if (!secondMov)
		return NO;

	mustUnref = [[secondMov rightOperand] isPointer];

	YASLOpcodeOperand *left2 = [secondMov leftOperand];

	NSUInteger readAt = [self reads:@[left, right]];
	NSUInteger writeAt = [self writes:@[left, right]];
	NSUInteger impactedAt = [self impacts];
	if ([self is:[self earliest:@[@(impactedAt), @(readAt), @(writeAt)]] earlierThan:secondAt])
		return NO;

//	NSString *before = [self.assembly stackToStringFrom:firstMov till:secondMov withContext:YES];
	id top;
	while ((top = [self.assembly pop]) != secondMov);

	NSUInteger readLeft = [self reads:@[left]];
	NSUInteger writeLeft = [self writes:@[left]];

	if ((readLeft == writeLeft) || [self is:readLeft earlierThan:writeLeft])
		return NO;

	while ((top = [self.assembly pop]) != secondMov);
	YASLOpcode *replacement = OPC(secondMov->opcode, left2, mustUnref ? [right asPointer] : right);
	[self.assembly push:replacement];
	[self.assembly alwaysDiscard:firstMov inGlobalScope:YES];
	[self.assembly alwaysDiscard:secondMov inGlobalScope:YES];
//	NSString *after = [self.assembly stackToStringFrom:firstMov till:replacement withContext:YES];
//	NSLog(@"Replaced:\n :%@ :%@->%@\n%@\n=====\n%@", firstMov, secondMov, replacement, before, after);

	return YES;
}


@end
