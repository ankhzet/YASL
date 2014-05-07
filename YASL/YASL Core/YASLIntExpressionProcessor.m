//
//  YASLIntExpressionProcessor.m
//  YASL
//
//  Created by Ankh on 06.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLIntExpressionProcessor.h"
#import "YASLDataType.h"
#import "YASLDataTypesManager.h"

@implementation YASLIntExpressionProcessor
@synthesize leftOperand = _leftOperand;

- (id)initWithDataTypesManager:(YASLDataTypesManager *)manager {
	if (!(self = [super init]))
		return self;

	_leftOperand = [manager typeByName:YASLBuiltInTypeInt];
	return self;
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
