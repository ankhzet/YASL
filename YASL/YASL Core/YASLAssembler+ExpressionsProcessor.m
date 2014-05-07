//
//  YASLAssembler+ExpressionsProcessor.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+ExpressionsProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (ExpressionsProcessor)

#pragma mark - Expressions

- (YASLTranslationExpression *) fetchExpressionFromAssembly:(YASLAssembly *)assembly
																					forExpressionType:(YASLExpressionType)type
{

	YASLAssembly *operands = [YASLAssembly new];
	YASLAssembly *operators = [YASLAssembly new];

	Class expClass = [YASLTranslationExpression class];
	id top;
	while ((top = [assembly popTillChunkMarker]))
		[([top isKindOfClass:expClass] ? operands : operators) push:top];


	YASLTranslationExpression *expression;

	if ([operators notEmpty]) {
		YASLTranslationExpression *left = [operands pop];

		while ([operators notEmpty]) {
			NSString *operator = [(YASLToken *)[operators pop] value];
			YASLTranslationExpression *right = [operands pop];
			if (!right) {
				right = left;
				left = [YASLTranslationConstant constantWithType:YASLConstantTypeInt andValue:@(0)];
			}
			expression = [YASLTranslationExpression expressionWithType:type andSpecifier:operator];
			[expression addSubNode:left];
			[expression addSubNode:right];
			left = expression;
		}

		expression = left;
	} else
		expression = [operands pop];

	return expression;
}

- (void) processAssembly:(YASLAssembly *)a nodeAdditiveExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeAdditive];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeMultiplicativeExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeMultiplicative];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeLogicalOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeLogicalOr];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeLogicalAndExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeLogicalAnd];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeAndExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeInclusiveAnd];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeExclusiveOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeExclusiveOr];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeInclusiveOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeInclusiveOr];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeShiftExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeShift];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeRelationalExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeRelational];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeEqualityExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeRelational];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeTernarExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *elseExpression = [a pop];
	YASLTranslationExpression *ifExpression = [a popTillChunkMarker];
	if (ifExpression) {
		YASLTranslationExpression *condition = [a pop];
		YASLTranslationExpression *ternar = [YASLTernarExpression ternarExpression];
		[ternar addSubNode:condition];
		[ternar addSubNode:ifExpression];
		[ternar addSubNode:elseExpression];
		elseExpression = ternar;
	}
	[a push:elseExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeConstantExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a top];
	//TODO: constantnes check here
	YASLTranslationExpression *folded = [expression foldConstantExpression];
	if (folded != expression) {
		[a pop];
		[a push:folded];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeTypeCast:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLDataType *castType = [a pop];
	expression.returnType = castType;
	[a push:expression];
}

#pragma mark - Constants

- (void) processAssembly:(YASLAssembly *)a nodeConstant:(YASLGrammarNode *)node {
	NSNumber *constantType = [a pop];
	YASLToken *token = [a pop];

	NSNumber *value;
	YASLConstantType type = [constantType unsignedIntegerValue];
	switch (type) {
		case YASLConstantTypeInt:
			value = @([token asInteger]);
			break;

		case YASLConstantTypeFloat:
			value = @([token asFloat]);
			break;

		case YASLConstantTypeBool:
			value = @([token asBool]);
			break;

		case YASLConstantTypeChar:
			value = @([[token asString] characterAtIndex:0]);
			break;

		case YASLConstantTypeEnum:
			//TODO: Enum handling
//			value = @([someenummanager enumFromIdentifier:token.value]);
			break;

		default:
			break;
	}
	YASLTranslationConstant *constant = [YASLTranslationConstant constantWithType:type andValue:value];
	[a push:constant];
}

- (void) processAssembly:(YASLAssembly *)a nodeIntegerConstant:(YASLGrammarNode *)node {
	[a push:@(YASLConstantTypeInt)];
}

- (void) processAssembly:(YASLAssembly *)a nodeFloatConstant:(YASLGrammarNode *)node {
	[a push:@(YASLConstantTypeFloat)];
}

- (void) processAssembly:(YASLAssembly *)a nodeBooleanConstant:(YASLGrammarNode *)node {
	[a push:@(YASLConstantTypeBool)];
}

- (void) processAssembly:(YASLAssembly *)a nodeCharacterConstant:(YASLGrammarNode *)node {
	[a push:@(YASLConstantTypeChar)];
}

- (void) processAssembly:(YASLAssembly *)a nodeEnumerationConstant:(YASLGrammarNode *)node {
	[a push:@(YASLConstantTypeEnum)];
}

@end
