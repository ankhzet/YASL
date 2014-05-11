//
//  YASLIfExpression.m
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLIfExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLIfExpression

+ (instancetype) ifExpressionInScope:(YASLDeclarationScope *)scope {
	YASLIfExpression *expression = [self nodeInScope:scope withType:YASLTranslationNodeTypeExpression];
	expression.expressionType = YASLExpressionTypeTernar;
	expression.specifier = @"if else";
	return expression;
}

/*! Try to fold ternar expression if condition-statement is constant. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	NSMutableArray *foldedOperands = [@[] mutableCopy];
	int nonConstants = 0;
	// first, try to fold operands
	for (YASLTranslationExpression *operand in self.subnodes) {
		YASLTranslationExpression *folded = [operand foldConstantExpressionWithSolver:solver];
    [foldedOperands addObject:folded];
		if (folded.expressionType != YASLExpressionTypeConstant)
			nonConstants++;
	}

	BOOL hasElse = [foldedOperands count] > 2;

	YASLTranslationExpression *condition = foldedOperands[0];
	YASLTranslationExpression *ifExpression = foldedOperands[1];
	YASLTranslationExpression *elseExpression = hasElse ? foldedOperands[2] : nil;

	YASLDataType *returnType = ifExpression.returnType;

	if (hasElse && (returnType != elseExpression.returnType)) {
		YASLTranslationExpression *cast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:returnType];
		[cast addSubNode:elseExpression];
		foldedOperands[2] = elseExpression = [cast foldConstantExpressionWithSolver:solver];
	}

	self.subnodes = foldedOperands;

	if (condition.expressionType == YASLExpressionTypeConstant) {
		NSLog(@"Constant condition in ternar expression: %@", self);
		return [((YASLTranslationConstant *)condition) toBool] ? ifExpression : elseExpression;
	}

	self.returnType = returnType;
	return self;
}

- (NSString *) toString {
	NSString *elseBlock = [self operandsCount] <3 ? @"" : [NSString stringWithFormat:@" else {%@};", [self.subnodes[2] toString]];
	NSString *subs = [NSString stringWithFormat:@"if (%@) {%@};%@", [self.subnodes[0] toString], [self.subnodes[1] toString], elseBlock];

	return [NSString stringWithFormat:@"(%@)", subs];
}

@end

@implementation YASLIfExpression (Assembling)

// condition ? true-block : false-block
//
// asm condition -> mov r0, condition
// test r0, r0
// jnz :falseLabel
// asm true-block -> mov r0, true-block
// jmp :outLabel
//:falseLabel
// asm false-block -> mov r0, false-block
//:outLabel

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	YASLOpcodeOperand *outLabel = IMM_(0);
	YASLOpcodeOperand *elseLabel = IMM_(0);

	YASLCodeAddressReference *outReference = [YASLCodeAddressReference new];
	[outReference addReferent:outLabel];

	// assemble condition
	[[self leftOperand] assemble:assembly unPointer:YES];
	// OPC_TEST r0, r0
//	[assembly push:OPC_(TEST, REG_(R0), REG_(R0))];

	// OPC_JNZ :elseLabel
	[assembly push:OPC_(JZ, elseLabel)];
	// assemble true-block
	[[self rigthOperand] assemble:assembly unPointer:unPointer];

	BOOL hasElseBlock = [self operandsCount] > 2;
	if (hasElseBlock) {
		YASLCodeAddressReference *falseBlockReference = [YASLCodeAddressReference new];
		[falseBlockReference addReferent:elseLabel];

		// OPC_JMP :outLabel
		[assembly push:OPC_(JMP, outLabel)];
		// :falseLabel
		[assembly push:falseBlockReference];
		// assemble false-block
		[[self thirdOperand] assemble:assembly unPointer:unPointer];
	} else
		[outReference addReferent:elseLabel];
	// :outLabel
	[assembly push:outReference];

	return YES;
}

@end

