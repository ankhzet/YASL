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

- (id)init {
	if (!(self = [super init]))
		return self;

	self.isUnary = YES;
	return self;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@%@", self.specifier, [self leftOperand]];
}

/*! Try to fold ternar expression if condition-statement is constant. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *folded = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	[self setNth:0 operand:folded];

	YASLExpressionOperator operator = [self expressionOperator];
	switch (operator) {
		case YASLExpressionOperatorNot: {
			self.returnType = [self.declarationScope typeByName:YASLBuiltInTypeIdentifierBool];
			YASLTranslationExpression *castToBool = [YASLTypecastExpression typecastInScope:self.declarationScope withType:self.returnType];
			[castToBool addSubNode:[self leftOperand]];
			castToBool = [castToBool foldConstantExpressionWithSolver:solver];
			[self setNth:0 operand:castToBool];
		}
		case YASLExpressionOperatorInv:
		case YASLExpressionOperatorAdd:
		case YASLExpressionOperatorSub: {
			break;
		}
		case YASLExpressionOperatorUnref:
		case YASLExpressionOperatorRef: {
			YASLUnrefExpression *unref = [YASLUnrefExpression unrefExpressionInScope:self.declarationScope];
			[unref addSubNode:[self nthOperand:0]];
			unref.isUnreference = operator == YASLExpressionOperatorUnref;
			unref = (id)[unref foldConstantExpressionWithSolver:solver];
			return unref;
			break;
		}

		default:
			break;
	}

	folded = (YASLTranslationExpression *)[self nthOperand:0];

	YASLDataType *returnType = [folded returnType];
	self.returnType = returnType;

	if (folded.expressionType != YASLExpressionTypeConstant)
		return self;


	switch ([self expressionOperator]) {
		case YASLExpressionOperatorNot: {
//			self.returnType = [self.declarationScope.localDataTypesManager typeByName:YASLBuiltInTypeIdentifierBool];
//			YASLTranslationExpression *castToBool = [YASLTypecastExpression typecastInScope:self.declarationScope withType:self.returnType];
//			[castToBool addSubNode:[self leftOperand]];
//			castToBool = [castToBool foldConstantExpressionWithSolver:solver];
//			[self setNth:0 operand:castToBool];
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

	switch ([self.returnType baseType]) {
		case YASLBuiltInTypeInt:
		case YASLBuiltInTypeBool:
		case YASLBuiltInTypeChar:
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
				default: ;
			}
			break;
		case YASLBuiltInTypeFloat:
			switch ([self expressionOperator]) {
				case YASLExpressionOperatorAdd: break;
				case YASLExpressionOperatorNot: {
					[assembly push:OPC_(NOTF, REG_(R0))];
					break;
				}
				case YASLExpressionOperatorSub: {
					[assembly push:OPC_(NEGF, REG_(R0))];
					break;
				}
				case YASLExpressionOperatorUnref:
				case YASLExpressionOperatorRef: {
					NSAssert(0, @"& and * unary operators unhandled");
					break;
				}
				default: ;
			}
			break;
		default:;
	}
}

@end
