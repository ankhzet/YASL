//
//  YASLExpressionProcessor.m
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLExpressionProcessor.h"
#import "YASLDataType.h"
#import "YASLDataTypesManager.h"
#import "YASLCoreLangClasses.h"

@implementation YASLExpressionProcessor
@synthesize returnType = _returnType;

- (id)init {
	if (!(self = [super init]))
		return self;

	_returnType = nil;
	_solver = nil;
	_castType = nil;
	return self;
}

- (id) initWithDataTypesManager:(YASLDataTypesManager *)manager forSolver:(YASLExpressionSolver *)solver withCastType:(YASLDataType *)castType {
	if (!(self = [self initWithDataTypesManager:manager]))
		return self;

	_solver = solver;
	_castType = castType;
	return self;
}

- (id)initWithDataTypesManager:(YASLDataTypesManager *)manager {
	if (!(self = [self init]))
		return self;

	_returnType = [manager typeByName:[[self class] returnTypeIdentifier]];
	return self;
}

+ (NSString *) returnTypeIdentifier {
	return YASLBuiltInTypeIdentifierVoid;
}

- (YASLTranslationExpression *) solveExpression:(YASLTranslationExpression *)expression {
	if (expression.expressionType == YASLExpressionTypeConstant)
		return expression;

	YASLTranslationExpression *result;
	YASLTranslationConstant *leftOperand = (id)[expression leftOperand];
	if (![YASLTranslationExpression checkFolding:&leftOperand withSolver:self.solver]) return expression;

	YASLBuiltInType returnType = [self.returnType builtInType];
	YASLBuiltInType castType = [self.castType builtInType];

	if ([expression nodesCount] > 1) {
		YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:expression.specifier unary:NO];
		YASLTranslationConstant *rightOperand = (id)[expression rigthOperand];
		if (![YASLTranslationExpression checkFolding:&rightOperand withSolver:self.solver]) return expression;

		switch (returnType) {
				DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeInt, YASLInt, castType);
				DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeFloat, YASLFloat, castType);
				DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeBool, YASLBool, castType);
				DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeChar, YASLChar, castType);
			default:
				break;
		}
	} else {
		YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:expression.specifier unary:YES];
		switch (returnType) {
				DECLARE_UNARY_FOR_RETURN_TYPE(YASLBuiltInTypeInt, YASLInt, castType);
				DECLARE_UNARY_FOR_RETURN_TYPE(YASLBuiltInTypeFloat, YASLFloat, castType);
				DECLARE_UNARY_FOR_RETURN_TYPE(YASLBuiltInTypeBool, YASLBool, castType);
				DECLARE_UNARY_FOR_RETURN_TYPE(YASLBuiltInTypeChar, YASLChar, castType);
			default:
				break;
		}
	}

	return result;
}

- (YASLInt) intUnaryOperation:(YASLExpressionOperator)operator resultForOperand:(YASLTranslationConstant *)leftOperand {
	YASLInt value;
	YASLInt operand = [leftOperand toInteger];
	switch (operator) {
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorNot, !);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorInv, ~);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLFloat) floatUnaryOperation:(YASLExpressionOperator)operator resultForOperand:(YASLTranslationConstant *)leftOperand {
	YASLFloat value;
	YASLFloat operand = [leftOperand toFloat];
	switch (operator) {
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorNot, !);
//			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorNeg, ~);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLBool) boolUnaryOperation:(YASLExpressionOperator)operator resultForOperand:(YASLTranslationConstant *)leftOperand {
	YASLBool value;
	YASLBool operand = [leftOperand toBool];
	switch (operator) {
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorNot, !);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorInv, ~);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLChar) charUnaryOperation:(YASLExpressionOperator)operator resultForOperand:(YASLTranslationConstant *)leftOperand {
	YASLChar value;
	YASLChar operand = [leftOperand toChar];
	switch (operator) {
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorNot, !);
			DECLARE_PREFIX_OPERATION(YASLExpressionOperatorInv, ~);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLInt) intOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand {
	YASLInt value;
	YASLInt left = [leftOperand toInteger];
	YASLInt right = [rightOperand toInteger];
	switch (operator) {
			DECLARE_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_OPERATION(YASLExpressionOperatorMul, *);
			DECLARE_OPERATION(YASLExpressionOperatorDiv, /);
			DECLARE_OPERATION(YASLExpressionOperatorRest, %);

			DECLARE_OPERATION(YASLExpressionOperatorSHL, <<);
			DECLARE_OPERATION(YASLExpressionOperatorSHR, >>);

			DECLARE_OPERATION(YASLExpressionOperatorExclusiveOr, ^);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveOr, |);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveAnd, &);

			DECLARE_OPERATION(YASLExpressionOperatorEqual, ==);
			DECLARE_OPERATION(YASLExpressionOperatorNotEqual, !=);
			DECLARE_OPERATION(YASLExpressionOperatorGreater, >);
			DECLARE_OPERATION(YASLExpressionOperatorGreaterEqual, >=);
			DECLARE_OPERATION(YASLExpressionOperatorLess, <);
			DECLARE_OPERATION(YASLExpressionOperatorLessEqual, <=);

			DECLARE_OPERATION(YASLExpressionOperatorLogicAnd, &&);
			DECLARE_OPERATION(YASLExpressionOperatorLogicOr, ||);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLFloat) floatOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand {
	YASLFloat left = [leftOperand toFloat], right = [rightOperand toFloat], value;
	switch (operator) {
			DECLARE_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_OPERATION(YASLExpressionOperatorMul, *);
			DECLARE_OPERATION(YASLExpressionOperatorDiv, /);
//			DECLARE_OPERATION(YASLExpressionOperatorRest, %);
//
//			DECLARE_OPERATION(YASLExpressionOperatorSHL, <<);
//			DECLARE_OPERATION(YASLExpressionOperatorSHR, >>);
//
//			DECLARE_OPERATION(YASLExpressionOperatorExclusiveOr, ^);
//			DECLARE_OPERATION(YASLExpressionOperatorInclusiveOr, |);
//			DECLARE_OPERATION(YASLExpressionOperatorInclusiveAnd, &);

			DECLARE_OPERATION(YASLExpressionOperatorEqual, ==);
			DECLARE_OPERATION(YASLExpressionOperatorNotEqual, !=);
			DECLARE_OPERATION(YASLExpressionOperatorGreater, >);
			DECLARE_OPERATION(YASLExpressionOperatorGreaterEqual, >=);
			DECLARE_OPERATION(YASLExpressionOperatorLess, <);
			DECLARE_OPERATION(YASLExpressionOperatorLessEqual, <=);

			DECLARE_OPERATION(YASLExpressionOperatorLogicAnd, &&);
			DECLARE_OPERATION(YASLExpressionOperatorLogicOr, ||);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLBool) boolOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand {
	YASLBool left = [leftOperand toBool], right = [rightOperand toBool], value;
	switch (operator) {
			DECLARE_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_OPERATION(YASLExpressionOperatorMul, *);
			DECLARE_OPERATION(YASLExpressionOperatorDiv, /);
			DECLARE_OPERATION(YASLExpressionOperatorRest, %);

			DECLARE_OPERATION(YASLExpressionOperatorSHL, <<);
			DECLARE_OPERATION(YASLExpressionOperatorSHR, >>);

			DECLARE_OPERATION(YASLExpressionOperatorExclusiveOr, ^);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveOr, |);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveAnd, &);

			DECLARE_OPERATION(YASLExpressionOperatorEqual, ==);
			DECLARE_OPERATION(YASLExpressionOperatorNotEqual, !=);
			DECLARE_OPERATION(YASLExpressionOperatorGreater, >);
			DECLARE_OPERATION(YASLExpressionOperatorGreaterEqual, >=);
			DECLARE_OPERATION(YASLExpressionOperatorLess, <);
			DECLARE_OPERATION(YASLExpressionOperatorLessEqual, <=);

			DECLARE_OPERATION(YASLExpressionOperatorLogicAnd, &&);
			DECLARE_OPERATION(YASLExpressionOperatorLogicOr, ||);
		default:
			value = 0;
			break;
	}
	return value;
}

- (YASLChar) charOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand {
	YASLChar left = [leftOperand toChar], right = [rightOperand toChar], value;
	switch (operator) {
			DECLARE_OPERATION(YASLExpressionOperatorAdd, +);
			DECLARE_OPERATION(YASLExpressionOperatorSub, -);
			DECLARE_OPERATION(YASLExpressionOperatorMul, *);
			DECLARE_OPERATION(YASLExpressionOperatorDiv, /);
			DECLARE_OPERATION(YASLExpressionOperatorRest, %);

			DECLARE_OPERATION(YASLExpressionOperatorSHL, <<);
			DECLARE_OPERATION(YASLExpressionOperatorSHR, >>);

			DECLARE_OPERATION(YASLExpressionOperatorExclusiveOr, ^);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveOr, |);
			DECLARE_OPERATION(YASLExpressionOperatorInclusiveAnd, &);

			DECLARE_OPERATION(YASLExpressionOperatorEqual, ==);
			DECLARE_OPERATION(YASLExpressionOperatorNotEqual, !=);
			DECLARE_OPERATION(YASLExpressionOperatorGreater, >);
			DECLARE_OPERATION(YASLExpressionOperatorGreaterEqual, >=);
			DECLARE_OPERATION(YASLExpressionOperatorLess, <);
			DECLARE_OPERATION(YASLExpressionOperatorLessEqual, <=);

			DECLARE_OPERATION(YASLExpressionOperatorLogicAnd, &&);
			DECLARE_OPERATION(YASLExpressionOperatorLogicOr, ||);
		default:
			value = 0;
			break;
	}
	return value;
}

@end
