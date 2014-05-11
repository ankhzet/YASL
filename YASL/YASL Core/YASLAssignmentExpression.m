//
//  YASLAssignmentExpression.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssignmentExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssignmentExpression

+ (instancetype) assignmentInScope:(YASLDeclarationScope *)scope withSpecifier:(YASLExpressionOperator)operator {
	YASLAssignmentExpression *expression = [self expressionInScope:scope
																												withType:YASLExpressionTypeAssignment
																										andSpecifier: (operator != YASLExpressionOperatorUnknown) ? [YASLTranslationExpression operatorToSpecifier:operator] : nil];
	expression->_operator = operator;
	return expression;
}

/*! Make sure to typecast if return types differs. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *foldedTarget = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	self.returnType = foldedTarget.returnType;
	self.subnodes[0] = foldedTarget;
	if ([self operandsCount] <= 1) {
//		if (self.operator != YASLExpressionOperatorUnknown) {
//			YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:self.declarationScope withType:	YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:self.operator]];
//			[expression addSubNode:foldedTarget];
//			[expression addSubNode:[YASLTranslationConstant constantInScope:self.declarationScope withType:self.returnType andValue:@1]];
//			_operator = YASLExpressionOperatorUnknown;
//			[self addSubNode:[expression foldConstantExpressionWithSolver:solver]];
//		}
		return self;
	}
	
	YASLTranslationExpression *foldedExpression = [[self rigthOperand] foldConstantExpressionWithSolver:solver];
	if (foldedExpression.returnType != foldedTarget.returnType) {
		YASLTypecastExpression *cast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:foldedTarget.returnType];
		[cast addSubNode:foldedExpression];
		foldedExpression = [cast foldConstantExpressionWithSolver:solver];
	}

	if (self.operator != YASLExpressionOperatorUnknown) {
		YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:self.operator]];
		[expression addSubNode:foldedTarget];
		[expression addSubNode:foldedExpression];
		_operator = YASLExpressionOperatorUnknown;
		foldedExpression = [expression foldConstantExpressionWithSolver:solver];
	}

	self.subnodes[1] = foldedExpression;

	return self;
}

- (NSString *) toString {
	NSString *subs = @"";

	if ([self operandsCount] > 1) {
		NSString *delim = [NSString stringWithFormat:@" %@= ", self.specifier ? self.specifier : @""];
		for (YASLTranslationNode *subnode in self.subnodes) {
			subs = [NSString stringWithFormat:@"%@%@%@", subs, ([subs length] ? delim : @""), [subnode toString]];
		}
	} else {
		NSString *delim = [NSString stringWithFormat:@"%@", self.specifier ? self.specifier : @""];
		subs = [NSString stringWithFormat:@"%@%@", delim, [[self leftOperand] toString]];
	}
	subs = [subs length] ? subs : self.specifier;

	return [NSString stringWithFormat:@"(%@)", subs];
}

@end

@implementation YASLAssignmentExpression (Assembling)

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	YASLTranslationExpression *target = [self leftOperand];
	[target assemble:assembly unPointer:NO];
	if ([self operandsCount] <= 1) {
		YASLOpcodes opcode = [YASLTranslationExpression operationToOpcode:[self expressionOperator]];
		YASLOpcodeOperand *operand = [REG_(R0) asPointer];
		if (self.postfix) {
			[assembly push:OPC_(MOV, REG_(R1), operand)];
		}
		[assembly push:OPC(opcode, operand)];
		if (!self.postfix) {
			[assembly push:OPC_(MOV, REG_(R0), operand)];
		} else {
			[assembly push:OPC_(MOV, REG_(R0), REG_(R1))];
		}
		return YES;
	}

	YASLTranslationExpression *expression = [self rigthOperand];
	[assembly push:OPC_(PUSH, REG_(R0))];
	[expression assemble:assembly unPointer:unPointer];
	[assembly push:OPC_(MOV, REG_(R1), REG_(R0))];
	[assembly push:OPC_(POP, REG_(R0))];
	[assembly push:OPC_(MOV, [REG_(R0) asPointer], REG_(R1))];

	return YES;
}

@end
