//
//  YASLTernarExpression.m
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTernarExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTernarExpression

+ (instancetype) ternarExpressionInScope:(YASLDeclarationScope *)scope {
	YASLTernarExpression *expression = [self nodeInScope:scope withType:YASLTranslationNodeTypeExpression];
	expression.expressionType = YASLExpressionTypeTernar;
	expression.specifier = @"?:";
	return expression;
}

/*! Try to fold ternar expression if condition-statement is constant. */
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

	YASLTranslationExpression *condition = foldedOperands[0];
	YASLTranslationExpression *ifExpression = foldedOperands[1];
	YASLTranslationExpression *elseExpression = foldedOperands[2];

	YASLDataType *returnType = ifExpression.returnType;

	if (returnType != elseExpression.returnType) {
		YASLTranslationExpression *cast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:returnType];
		[cast addSubNode:elseExpression];
		elseExpression = [cast foldConstantExpressionWithSolver:solver];
	}

	if (condition.expressionType == YASLExpressionTypeConstant) {
		NSLog(@"Constant condition in ternar expression: %@", self);
		return [((YASLTranslationConstant *)condition) toBool] ? ifExpression : elseExpression;
	}

	[self setSubNodes:@[condition, ifExpression, elseExpression]];

	self.returnType = returnType;
	return self;
}

- (NSString *) toString {
	NSString *subs = [NSString stringWithFormat:@"%@ ? %@ : %@", [[self nthOperand:0] toString], [[self nthOperand:1] toString], [[self nthOperand:2] toString]];

	return [NSString stringWithFormat:@"(%@)", subs];
}

@end

@implementation YASLTernarExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLCodeAddressReference *falseLabel = [YASLCodeAddressReference new];
	YASLCodeAddressReference *outLabel = [YASLCodeAddressReference new];

	YASLOpcodeOperand *falseAddress = [falseLabel addNewOpcodeOperandReferent];
	YASLOpcodeOperand *outAddress = [outLabel addNewOpcodeOperandReferent];

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

	// assemble condition
	[[self leftOperand] assemble:assembly unPointered:YES];
	// OPC_TEST r0, r0
//	[assembly push:OPC_(TEST, REG_(R0), REG_(R0))];

	// OPC_JNZ :elseLabel
	[assembly push:OPC_(JZ, falseAddress)];
	// assemble true-block
	[[self rigthOperand] assemble:assembly unPointered:YES];
	// OPC_JMP :outLabel
	[assembly push:OPC_(JMP, outAddress)];
	// :falseLabel
	[assembly push:falseLabel];
	// assemble false-block
	[[self thirdOperand] assemble:assembly unPointered:YES];
	// :outLabel
	[assembly push:outLabel];
}

@end


