//
//  YASLUnwantedMovCallStrategy.m
//  YASL
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnwantedMovCallStrategy.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnwantedMovCallStrategy {
	YASLOpcode *firstMov;
}

- (BOOL) applyable {
	firstMov = [self detectOpcode:OPC_MOV];
	return !!firstMov;
}

- (BOOL) applyStrategy {
	YASLOpcodeOperand *left = [firstMov leftOperand], *right = [firstMov rightOperand];
	YASLOpcode *call = [self detectOpcodeInGroup:@[@(OPC_CALL)] withFirstOperand:left];
	NSUInteger calledByOpcode = [self getCurentStateAndRestoreBaseState];
	if (!call)
		return NO;

	[self whoReads:left];
	NSUInteger readAt = [self getCurentStateAndRestoreBaseState];
	[self whoWrites:left];
	NSUInteger writeAt = [self getCurentStateAndRestoreBaseState];
	[self whoImpactsExecutionFlow];
	NSUInteger flowAt = [self getCurentStateAndRestoreBaseState];

	if ([self is:[self earliest:@[@(flowAt), @(readAt), @(writeAt)]] earlierThan:calledByOpcode])
		return NO;
	
	id top;
	while ((top = [self.assembly pop]) != call);
	YASLOpcode *replacement = OPC_(CALL, right);
	[self.assembly push:replacement];
	[self.assembly alwaysDiscard:firstMov inGlobalScope:YES];
	[self.assembly alwaysDiscard:call inGlobalScope:YES];
//	NSLog(@"Replaced:\n :%@ :%@->%@\n%@", firstMov, call, replacement, [self.assembly stackToStringFrom:firstMov till:replacement withContext:YES]);

	return YES;
}

@end
