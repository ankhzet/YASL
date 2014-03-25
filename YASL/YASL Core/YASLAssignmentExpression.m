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
	return expression;
}

/*! Make sure to typecast if return types differs. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *foldedTarget = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	self.returnType = foldedTarget.returnType;
	[self setNth:0 operand:foldedTarget];
	if ([self nodesCount] <= 1) {
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

	if ([self expressionOperator] != YASLExpressionOperatorUnknown) {
		YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:[self expressionOperator]]];
		[expression addSubNode:foldedTarget];
		[expression addSubNode:foldedExpression];
		self.specifier = nil;// = YASLExpressionOperatorUnknown;
		foldedExpression = [expression foldConstantExpressionWithSolver:solver];
	}

	[self setNth:1 operand:foldedExpression];

	return self;
}

- (NSString *) toString {
	NSString *subs = @"";

	if ([self nodesCount] > 1) {
		NSString *delim = [NSString stringWithFormat:@" %@= ", self.specifier ? self.specifier : @""];
		for (YASLTranslationNode *subnode in [self nodesEnumerator:NO]) {
			subs = [NSString stringWithFormat:@"%@%@%@", subs, ([subs length] ? delim : @""), [subnode toString]];
		}
	} else {
		NSString *delim = [NSString stringWithFormat:@"%@", self.specifier ? self.specifier : @""];
		subs = [NSString stringWithFormat:@"%@%@", self.postfix ? [[self leftOperand] toString] : delim, (!self.postfix) ? [[self leftOperand] toString] : delim];
	}
	subs = [subs length] ? subs : self.specifier;

	return [NSString stringWithFormat:@"(%@)", subs];
}

@end

@implementation YASLAssignmentExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLExpressionOperator operator = [self expressionOperator];
	YASLOpcodes opcode = [YASLTranslationExpression operationToOpcode:operator];

	YASLTranslationExpression *target = [self leftOperand];
	[target assemble:assembly unPointered:NO];
	if ([self nodesCount] <= 1) {
		YASLOpcodeOperand *targetValue = [REG_(R0) asPointer];
		if (self.postfix) {
			[assembly push:OPC_(MOV, REG_(R1), targetValue)];
		}
		[assembly push:OPC(opcode, targetValue)];
		if (!self.postfix) {
			[assembly push:OPC_(MOV, REG_(R0), targetValue)];
		} else {
			[assembly push:OPC_(MOV, REG_(R0), REG_(R1))];
		}
		return;
	}

	YASLOpcodeOperand *assignmentTarget = REG_(R1);
	YASLOpcodeOperand *assignedValue = REG_(R0);
	YASLOpcodeOperand *targetValue = [REG_(R1) asPointer];

	YASLTranslationExpression *expression = [self rigthOperand];
	[assembly push:OPC_(PUSH, assignedValue)];
	[expression assemble:assembly unPointered:YES];
	[assembly push:OPC_(POP, assignmentTarget)];

	if (operator != YASLExpressionOperatorUnknown) {
		[assembly push:OPC (opcode, targetValue, assignedValue)];
		[assembly push:OPC_(MOV, REG_(R0), targetValue)];
	} else {
		[assembly push:OPC_(MOV, targetValue, assignedValue)];
	}
}

@end
