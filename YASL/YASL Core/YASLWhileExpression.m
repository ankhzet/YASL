//
//  YASLWhileExpression.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLWhileExpression.h"
#import "YASLCoreLangClasses.h"

NSString *const YASLReservedWordContinue = @"continue";
NSString *const YASLReservedWordBreak = @"break";

@implementation YASLWhileExpression

+ (instancetype) whileExpressionInScope:(YASLDeclarationScope *)scope {
	YASLWhileExpression *whileExpression = [YASLWhileExpression expressionInScope:scope withType:YASLExpressionTypeIterational];

	return whileExpression;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"while (%@) {\n%@}\n", [[self leftOperand] toString], [[self rigthOperand] toString]];
}

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
	self.returnType = nil;
	return self;
}

@end

@implementation YASLWhileExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLCodeAddressReference *continueLabel = self.continueLabel.reference;
	YASLOpcodeOperand *continueAddress = [continueLabel addNewOpcodeOperandReferent];

	YASLCodeAddressReference *iterationLabel = [YASLCodeAddressReference new];
	YASLOpcodeOperand *iterationAddress = [iterationLabel addNewOpcodeOperandReferent];

	if (!self.doWhile)
		[assembly push:OPC_(JMP, continueAddress)];

	[assembly push:iterationLabel];
	[[self rigthOperand] assemble:assembly unPointered:NO];
	[assembly push:continueLabel];
	[[self leftOperand] assemble:assembly unPointered:YES];
	[assembly push:OPC_(JNZ, iterationAddress)];
	[assembly push:self.breakLabel.reference];

}

@end
