//
//  YASLExpressionProcessor.m
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLExpressionProcessor.h"
#import "YASLDataType.h"

typedef NS_ENUM(NSUInteger, YASLExpressionOperator) {
	YASLExpressionOperatorUnknown = 0,
	YASLExpressionOperatorAdd,
	YASLExpressionOperatorSub,
	YASLExpressionOperatorMul,
	YASLExpressionOperatorDiv,
	YASLExpressionOperatorRest,

	YASLExpressionOperatorIncrement,
	YASLExpressionOperatorDecrement,

	YASLExpressionOperatorInclusiveOr,
	YASLExpressionOperatorExclusiveOr,
	YASLExpressionOperatorLogicOr,
	YASLExpressionOperatorLogicAnd,
	YASLExpressionOperatorInclusiveAnd,

	YASLExpressionOperatorGreater,
	YASLExpressionOperatorGreaterEqual,
	YASLExpressionOperatorLess,
	YASLExpressionOperatorLessEqual,
	YASLExpressionOperatorNotEqual,
	YASLExpressionOperatorEqual,

	YASLExpressionOperatorSHL,
	YASLExpressionOperatorSHR,
};

@implementation YASLExpressionProcessor

- (YASLExpressionOperator) specifierToOperator:(NSString *)specifier {
	NSDictionary *operators =
	@{
		@"+": @(YASLExpressionOperatorAdd),
		@"-": @(YASLExpressionOperatorSub),
		@"*": @(YASLExpressionOperatorMul),
		@"/": @(YASLExpressionOperatorDiv),
		@"%": @(YASLExpressionOperatorRest),
		@"++": @(YASLExpressionOperatorIncrement),
		@"--": @(YASLExpressionOperatorDecrement),
		@"|": @(YASLExpressionOperatorInclusiveOr),
		@"||": @(YASLExpressionOperatorLogicOr),
		@"&": @(YASLExpressionOperatorInclusiveAnd),
		@"&&": @(YASLExpressionOperatorLogicAnd),
		@"^": @(YASLExpressionOperatorExclusiveOr),
		@">": @(YASLExpressionOperatorGreater),
		@">=": @(YASLExpressionOperatorGreaterEqual),
		@">>": @(YASLExpressionOperatorSHR),
		@"<": @(YASLExpressionOperatorLess),
		@"<=": @(YASLExpressionOperatorLessEqual),
		@"<<": @(YASLExpressionOperatorSHL),
		@"==": @(YASLExpressionOperatorEqual),
		@"!=": @(YASLExpressionOperatorNotEqual),
		};
	NSNumber *operator = operators[specifier];
	return operator ? [operator unsignedIntegerValue] : YASLExpressionOperatorUnknown;
}

- (YASLTranslationExpression *) solveExpression:(YASLTranslationExpression *)expression {
	switch (expression.expressionType) {
		case YASLExpressionTypeConstant:
			return expression;
			break;

		case YASLExpressionTypeAdditive:

			break;

		case YASLExpressionTypeMultiplicative:
			break;

		case YASLExpressionTypeExclusiveOr:
			break;

		case YASLExpressionTypeInclusiveOr:
			break;

		case YASLExpressionTypeLogicalOr:
			break;

		case YASLExpressionTypeInclusiveAnd:
			break;

		case YASLExpressionTypeLogicalAnd:
			break;

		case YASLExpressionTypeRelational:
			break;

		case YASLExpressionTypeTernar:
			break;

		case YASLExpressionTypeShift:
			break;

		case YASLExpressionTypeTypecast:
			break;

		case YASLExpressionTypeUnary:
			break;

		case YASLExpressionTypeVariable:
			break;

		case YASLExpressionTypeSizeOf:
			break;

		case YASLExpressionTypeString:
			break;

		case YASLExpressionTypeStructure:
			break;
			
		case YASLExpressionTypeProperty:
			break;

		case YASLExpressionTypeArray:
			break;

		case YASLExpressionTypeCall:
			break;

		case YASLExpressionTypeDesignatedInitializer:
			break;
			
		default:
			break;
	}
	return expression;
}

@end
