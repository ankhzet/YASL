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

	YASLTranslationConstant *rightOperand = (id)[expression rigthOperand];
	if (![YASLTranslationExpression checkFolding:&rightOperand withSolver:self.solver]) return expression;

	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:expression.specifier];

	YASLBuiltInType returnType = [self.returnType builtInType];
	YASLBuiltInType castType = [self.castType builtInType];
	switch (returnType) {
			DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeInt, YASLInt, castType);
			DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeFloat, YASLFloat, castType);
			DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeBool, YASLBool, castType);
			DECLARE_FOR_RETURN_TYPE(YASLBuiltInTypeChar, YASLChar, castType);
		default:
			break;
	}

	return result;
}

- (YASLInt) intOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand {
	YASLInt left = [leftOperand toInteger], right = [rightOperand toInteger], value;
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
