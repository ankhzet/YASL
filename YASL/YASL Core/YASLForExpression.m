//
//  YASLForExpression.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLForExpression.h"
#import "YASLCoreLangClasses.h"

#define FOR_INIT_OPERAND 0
#define FOR_CONDITION_OPERAND 1
#define FOR_ITERATE_NEXT_OPERAND 2
#define FOR_STATEMENTS_OPERAND 3

@implementation YASLForExpression


+ (instancetype) whileExpressionInScope:(YASLDeclarationScope *)scope {
	YASLForExpression *forExpression = [YASLForExpression expressionInScope:scope withType:YASLExpressionTypeIterational];
	return forExpression;
}

- (NSString *) toString {
	NSString *_init = [self nthOperand:FOR_INIT_OPERAND] ? [[self nthOperand:FOR_INIT_OPERAND] toString] : @"";
	NSString *_check = [self nthOperand:FOR_CONDITION_OPERAND] ? [[self nthOperand:FOR_CONDITION_OPERAND] toString] : @"";
	NSString *_iterate = [self nthOperand:FOR_ITERATE_NEXT_OPERAND] ? [[self nthOperand:FOR_ITERATE_NEXT_OPERAND] toString] : @"";
	NSString *_statements = [[self nthOperand:FOR_STATEMENTS_OPERAND] toString] ? [[self nthOperand:FOR_STATEMENTS_OPERAND] toString] : @"";
	return [NSString stringWithFormat:@"for (%@;%@;%@) {\n%@}\n", _init, _check, _iterate, _statements];
}

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	NSArray *foldOperands = @[@(FOR_INIT_OPERAND), @(FOR_CONDITION_OPERAND), @(FOR_ITERATE_NEXT_OPERAND), @(FOR_STATEMENTS_OPERAND), ];
	for (NSNumber *operandIdx in foldOperands) {
		NSUInteger idx = [operandIdx unsignedIntegerValue];
		YASLTranslationExpression *operand = [self nthOperand:idx];
		if (operand)
			[self setNth:idx operand:[operand foldConstantExpressionWithSolver:solver]];
	}
	self.returnType = nil;
	return self;
}

@end

@implementation YASLForExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLCodeAddressReference *continueLabel = self.continueLabel.reference;
	YASLCodeAddressReference *breakLabel = self.breakLabel.reference;
	YASLCodeAddressReference *iterationLabel = [YASLCodeAddressReference new];
	YASLOpcodeOperand *breakAddress = [breakLabel addNewOpcodeOperandReferent];
	YASLOpcodeOperand *iterationAddress = [iterationLabel addNewOpcodeOperandReferent];

	YASLTranslationExpression *initializer = [self nthOperand:FOR_INIT_OPERAND];
	YASLTranslationExpression *condition = [self nthOperand:FOR_CONDITION_OPERAND];
	YASLTranslationExpression *iterator = [self nthOperand:FOR_ITERATE_NEXT_OPERAND];
	YASLTranslationExpression *statements = [self nthOperand:FOR_STATEMENTS_OPERAND];

	if (initializer) {
		[initializer assemble:assembly];
	}

	[assembly push:iterationLabel];
	if (condition) {
		[condition assemble:assembly unPointered:YES];
		[assembly push:OPC_(JZ, breakAddress)];
	}
	if (statements) {
		[statements assemble:assembly];
	}
	[assembly push:continueLabel];
	if (iterator) {
		[iterator assemble:assembly];
	}
	[assembly push:OPC_(JMP, iterationAddress)];
	[assembly push:breakLabel];
}

@end
