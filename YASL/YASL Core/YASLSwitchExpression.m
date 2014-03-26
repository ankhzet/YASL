//
//  YASLSwitchExpression.m
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLSwitchExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLSwitchExpression {
	NSMutableDictionary *cases;
	NSMutableArray *caseValues;
}

+ (instancetype) switchExpressionInScope:(YASLDeclarationScope *)scope {
	YASLSwitchExpression *switchExpr = [self expressionInScope:scope withType:YASLExpressionTypeSwitch];
	return switchExpr;
}

/*! Try to fold switch expression. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	NSMutableArray *foldedOperands = [@[] mutableCopy];
	int nonConstants = 0;
	// first, try to fold operands
	for (YASLTranslationExpression *operand in [self nodesEnumerator:NO]) {
		YASLTranslationExpression *folded = [operand foldConstantExpressionWithSolver:solver];
    [foldedOperands addObject:folded];
		if (folded.expressionType != YASLExpressionTypeConstant)
			nonConstants++;
	}

	[self setSubNodes:foldedOperands];
	cases = [NSMutableDictionary dictionary];
	caseValues = [NSMutableArray array];
	YASLTranslationExpression *defaults;
	YASLTranslationExpression *expr = [self nthOperand:0];
	for (YASLTranslationExpression *statement in [self nodesEnumerator:NO]) {
		if (statement == expr)
			continue;

		if ([statement nodesCount] > 1) {
			YASLTranslationConstant *caseExpr = [statement leftOperand];
			YASLTranslationExpression *caseStatement = [statement rigthOperand];
			YASLInt caseValue = [caseExpr toInteger];
			if (cases[@(caseValue)])
				[self raiseError:@"Duplicate case value %@",caseExpr];

			cases[@(caseValue)] = caseStatement;
			[caseValues addObject:@(caseValue)];
		} else {
			if (defaults)
				[self raiseError:@"Duplicate default case"];

			defaults = [statement leftOperand];
			[caseValues addObject:[NSNull null]];
		}
	}
	if (!defaults) {
		defaults = [YASLCompoundExpression compoundExpressionInScope:self.declarationScope];
		NSLog(@"No default case in switch.");
	}

	YASLCompoundExpression *defaultStatement = [YASLCompoundExpression compoundExpressionInScope:self.declarationScope];
	[defaultStatement addSubNode:defaults];
	cases[[NSNull null]] = defaultStatement;

	self.returnType = nil;
	return self;
}

- (NSString *) toString {
	YASLTranslationExpression *expr = [self nthOperand:0];
	NSMutableArray *statements = [@[] mutableCopy];
	if ([self nodesCount] > 1) {
		for (YASLTranslationExpression *statement in [self nodesEnumerator:NO]) {
			if (statement == expr)
				continue;

			YASLTranslationExpression *caseStatement;
			NSString *label;
			if ([statement nodesCount] > 1) {
				label = [NSString stringWithFormat:@"case %@", [statement leftOperand]];
				caseStatement = [statement rigthOperand];
			} else {
				label = @"default";
				caseStatement = [statement leftOperand];
			}
			[statements addObject:[NSString stringWithFormat:@"%@: %@", label, [caseStatement toString]]];
		}
	}
	return [NSString stringWithFormat:@"switch (%@) {\n%@}\n", [expr toString], [[statements componentsJoinedByString:@"\n"] descriptionTabbed:@"\t"]];
}

@end

@implementation YASLSwitchExpression (Assembling)

/*
 
 25
 ----
 
 15
 25 - (15 - 0) = 10
 
 1
 10 - (1 - 15) = 24
 
 10
 24 - (10 - 1) = 15
 
 111
 15 - (111 - 10) = -86
 
 25
 -86 - (25 - 111) = 0
 
 30

 
 */

- (void) assemble:(YASLAssembly *)assembly {
	[[self leftOperand] assemble:assembly unPointered:YES];

	NSMutableArray *statements = [NSMutableArray arrayWithCapacity:[[cases allKeys] count]];
	NSInteger delta = 0;
	YASLTranslationExpression *defaultStatement;
	for (NSNumber *caseValue in caseValues) {
		YASLTranslationExpression *statement = cases[caseValue];
    if (caseValue == (id)[NSNull null]) {
			defaultStatement = statement;
			continue;
		}

		NSInteger value = [caseValue integerValue];
		switch (value - delta) {
			case 1:
				[assembly push:OPC_(DEC, REG_(R0))];
				break;
			case 0:
				break;
			case -1:
				[assembly push:OPC_(INC, REG_(R0))];
				break;
			default:
				[assembly push:OPC_(SUB, REG_(R0), IMM_(@(value - delta)))];
				break;
		}
		delta = value;

		YASLCodeAddressReference *ref = [YASLCodeAddressReference referenceWithName:[NSString stringWithFormat:@"case %@", caseValue]];
		YASLOpcodeOperand *refAddress = [ref addNewOpcodeOperandReferent];
		[statements addObject:@{@0: ref, @1: statement}];
		[assembly push:OPC_(JZ, refAddress)];
	}

	if (defaultStatement) {
		YASLCodeAddressReference *ref = [YASLCodeAddressReference referenceWithName:@"default"];
		YASLOpcodeOperand *refAddress = [ref addNewOpcodeOperandReferent];
		[statements addObject:@{@0: ref, @1: defaultStatement}];
		[assembly push:OPC_(JMP, refAddress)];
	} else {
		[assembly push:OPC_(JMP, [self.breakLabel.reference addNewOpcodeOperandReferent])];
	}

	for (NSDictionary *statement in statements) {
    [assembly push:statement[@0]];
		YASLTranslationExpression *statementExpr = statement[@1];
		[statementExpr assemble:assembly unPointered:NO];
	}

	[assembly push:self.breakLabel.reference];
}

@end
