//
//  YASLUnwantedMovPushStrategy.m
//  YASL
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnwantedMovPushStrategy.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnwantedMovPushStrategy {
	YASLOpcode *firstMov;
}

- (BOOL) applyable {
	firstMov = [self detectOpcode:OPC_MOV];
	return !!firstMov;
}

/*
 mov left, right
 push left
 ->
 push right
 _____________
 mov left, right
 ...
 not read, write (x, y)
 not impacts execution flow
 ...
 push right
 
 */

- (BOOL) applyStrategy {
	YASLOpcodeOperand *left = [firstMov leftOperand], *right = [firstMov rightOperand];
	
	YASLOpcode *push = [self detectOpcodeInGroup:@[@(OPC_PUSH)] withFirstOperand:left];
	NSUInteger pushedAt = [self getCurentStateAndRestoreBaseState];
	if ((!push) || (left->type != [push leftOperand]->type)) // exact match, no r0 == [r0]
		return NO;

	NSUInteger readAt = [self reads:@[left, right]];
	NSUInteger writeAt = [self writes:@[left, right]];
	NSUInteger flowAt = [self impacts];

	if ([self is:[self earliest:@[@(flowAt), @(readAt), @(writeAt)]] earlierThan:pushedAt])
		return NO;

//	NSString *before = [self.assembly stackToStringFrom:firstMov till:push withContext:YES];
	id top;
	while ((top = [self.assembly pop]) && (top != push));
	YASLOpcode *replacement = OPC_(PUSH, right);
	[self.assembly push:replacement];
	[self.assembly alwaysDiscard:firstMov inGlobalScope:YES];
	[self.assembly alwaysDiscard:push inGlobalScope:YES];
//	NSString *after = [self.assembly stackToStringFrom:firstMov till:replacement withContext:YES];
//	NSLog(@"Replaced:\n :%@ :%@->%@\n%@\n=====\n%@", firstMov, push, replacement, before, after);

	return YES;
}

@end
