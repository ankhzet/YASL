//
//  YASLUnaryExpression.m
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnaryExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnaryExpression

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@%@", self.prefix ? self.specifier : [self leftOperand], (!self.prefix) ? self.specifier : [self leftOperand]];
}

/*! Try to fold ternar expression if condition-statement is constant. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *folded = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	[self setNth:0 operand:folded];
	if (folded.expressionType != YASLExpressionTypeConstant)
		return self;

	YASLDataType *returnType = folded.returnType;
	self.returnType = returnType;

	switch ([self expressionOperator]) {
		case YASLExpressionOperatorNot: {
			self.returnType = [self.declarationScope.localDataTypesManager typeByName:YASLBuiltInTypeIdentifierBool];
			YASLTranslationExpression *castToBool = [YASLTypecastExpression typecastInScope:self.declarationScope withType:self.returnType];
			[castToBool addSubNode:[self leftOperand]];
			castToBool = [castToBool foldConstantExpressionWithSolver:solver];
			[self setNth:0 operand:castToBool];
		}
		case YASLExpressionOperatorInv:
		case YASLExpressionOperatorAdd:
		case YASLExpressionOperatorSub: {
			YASLExpressionProcessor *processor = [solver pickProcessor:self];
			return [processor solveExpression:self];
		}
		case YASLExpressionOperatorUnref:
		case YASLExpressionOperatorRef: {
			NSAssert(0, @"& and * unary operators unhandled");
			break;
		}

		default:
			break;
	}

	return self;
}

@end

@implementation YASLUnaryExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLTranslationExpression *target = [self leftOperand];
	[target assemble:assembly unPointered:YES];

	switch ([self expressionOperator]) {
		case YASLExpressionOperatorAdd: break;
		case YASLExpressionOperatorNot: {
			[assembly push:OPC_(NOT, REG_(R0))];
			break;
		}
		case YASLExpressionOperatorInv: {
			[assembly push:OPC_(INV, REG_(R0))];
			break;
		}
		case YASLExpressionOperatorSub: {
			[assembly push:OPC_(NEG, REG_(R0))];
			break;
		}
		case YASLExpressionOperatorUnref:
		case YASLExpressionOperatorRef: {
			NSAssert(0, @"& and * unary operators unhandled");
			break;
		}

		default:
			break;
	}
}

@end
