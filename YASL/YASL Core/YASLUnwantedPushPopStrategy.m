//
//  YASLUnwantedPushPopStrategy.m
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnwantedPushPopStrategy.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnwantedPushPopStrategy {
	YASLOpcode *firstPush;
}

- (BOOL) applyable {
	firstPush = [self detectOpcode:OPC_PUSH];
	return !!firstPush;
}

/*
 push left
 pop  right
 ->
 mov  right, left
 _____________

 push a
 mov a, b -> fail
 pop c
 --------
 mov a, b
 mov c, a

 push a
 push b -> fail
 pop c
 --------
 push b
 mov c, a

 push a
 mov b, a -> ok
 pop c
 --------
 mov b, a
 mov c, a

 */

- (BOOL) applyStrategy {
	YASLOpcodeOperand *left = [firstPush leftOperand], *right;

	YASLOpcode *pop = [self detectOpcodeInGroup:@[@(OPC_POP)] withFirstOperand:nil];
	NSUInteger poppedAt = [self getCurentStateAndRestoreBaseState];
	if (!pop)
		return NO;

	right = [pop leftOperand];

	[self detectOpcodeInGroup:@[@(OPC_PUSH), @(OPC_NATIV)] withFirstOperand:nil];
	NSUInteger pushedAt = [self getCurentStateAndRestoreBaseState];
	NSUInteger writeAt = [self writes:@[left, REG_(SP)]];
	NSUInteger flowAt = [self impacts];

	if ([self is:[self earliest:@[@(flowAt), @(writeAt), @(pushedAt)]] earlierThan:poppedAt])
		return NO;

//	NSString *before = [self.assembly stackToStringFrom:firstPush till:pop withContext:YES];
	id top;
	while ((top = [self.assembly pop]) && (top != pop));
	YASLOpcode *replacement = OPC_(MOV, right, left);
	[self.assembly push:replacement];
	[self.assembly alwaysDiscard:firstPush inGlobalScope:YES];
	[self.assembly alwaysDiscard:pop inGlobalScope:YES];
//	NSString *after = [self.assembly stackToStringFrom:firstPush till:replacement withContext:YES];
//	NSLog(@"Replaced:\n :%@ :%@->%@\n%@\n=====\n%@", firstPush, pop, replacement, before, after);

	return YES;
}


@end
