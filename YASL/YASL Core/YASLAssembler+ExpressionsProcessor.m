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


	YASLTranslationExpression *left = [operands pop];

	if ([operators notEmpty]) {
		while ([operators notEmpty]) {
			NSString *operator = [(YASLToken *)[operators pop] value];
//			[YASLTranslationExpression ]
			YASLTranslationExpression *right = [operands pop];
			if (!right) {
				right = left;
				left = [YASLTranslationConstant constantInScope:self.declarationScope.currentScope withType:left.returnType andValue:@(0)];
			}
			YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:self.declarationScope.currentScope withType:type andSpecifier:operator];
			[expression addSubNode:left];
			[expression addSubNode:right];
			left = expression;
		}
	}

	return left;
}

/*!@brief Build espression node for `additive` expression: operand ([+-] operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeAdditiveExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `multiplicative` expression: operand ([*%/] operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeMultiplicativeExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `logical or` expression: operand ('||' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeLogicalOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `logical and` expression: operand ('&&' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeLogicalAndExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `aratmetic and` expression: operand ('&' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeAndExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `exclusive or` expression: operand ('^' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeExclusiveOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic or` expression: operand ('|' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeInclusiveOrExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic shift` expression: operand (('<<' | '>>') operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeShiftExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic relational` expression: operand (( '<' | '<=' | '>' | '>=' ) operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeRelationalExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic relational` expression: operand (( '!=' | '==' ) operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeEqualityExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `ternar` expression: condition ? true-expression : false-expression . */
- (void) processAssembly:(YASLAssembly *)a nodeTernarExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *elseExpression = [a pop];
	YASLTranslationExpression *ifExpression = [a popTillChunkMarker];
	if (ifExpression) {
		YASLTranslationExpression *condition = [a pop];
		YASLTranslationExpression *ternar = [YASLTernarExpression ternarExpressionInScope:self.declarationScope.currentScope];
		[ternar addSubNode:condition];
		[ternar addSubNode:ifExpression];
		[ternar addSubNode:elseExpression];
		elseExpression = ternar;
	}
	[a push:elseExpression];
}

/*!@brief Build espression node for `constant` expression: (numeric | string | boolean) constant . */
- (void) processAssembly:(YASLAssembly *)a nodeConstantExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a top];
	//TODO: constantnes check here
	YASLTranslationExpression *folded = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
	if (folded != expression) {
		[a pop];
		[a push:folded];
	}
}

/*!@brief Build espression node for `typecast` expression: '(' data-type ')' operand . */
- (void) processAssembly:(YASLAssembly *)a nodeTypeCast:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLDataType *castType = [a pop];
	YASLTranslationExpression *castExpression = [YASLTranslationExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeTypecast andSpecifier:nil];
	castExpression.returnType = castType;
	[castExpression addSubNode:expression];
	[a push:castExpression];
}

#pragma mark - Unary

- (void) processAssembly:(YASLAssembly *)a nodeUnaryOperatorExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLToken *operator = [a pop];
//	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operator.value];
	YASLTranslationExpression *unaryExpression = [YASLTranslationExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeUnary andSpecifier:operator.value];
	[unaryExpression addSubNode:expression];
	[a push:unaryExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeIncrementDecrementExpression:(YASLGrammarNode *)node {
	YASLToken *operatorToken = [a pop];
	YASLTranslationExpression *expression = [a pop];
	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operatorToken.value];
	YASLTranslationExpression *unaryExpression = [YASLAssignmentExpression assignmentInScope:self.declarationScope.currentScope withSpecifier:operator];
	[unaryExpression addSubNode:expression];
	[a push:unaryExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodePostfixIncrementDecrement:(YASLGrammarNode *)node {
	[a pop];
	YASLToken *operatorToken = [a pop];
	YASLTranslationExpression *expression = [a pop];
	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operatorToken.value];
	YASLAssignmentExpression *unaryExpression = [YASLAssignmentExpression assignmentInScope:self.declarationScope.currentScope withSpecifier:operator];
	[unaryExpression addSubNode:expression];
	unaryExpression.postfix = YES;
	[a push:unaryExpression];
}

#pragma mark - Variables

- (void) processAssembly:(YASLAssembly *)a nodeVariable:(YASLGrammarNode *)node {
	YASLToken *variable = [a pop];
	YASLLocalDeclaration *declaration = [self.declarationScope localDeclarationByIdentifier:variable.value];
	if (!declaration) {
		[YASLGrammarNode raiseMatch:a error:@"Variable \"%@\" undefined",variable.value];
	}
	YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeVariable andSpecifier:variable.value];
	expression.returnType = declaration.dataType;
	[a push:expression];
}

#pragma mark - Constants

- (void) processAssembly:(YASLAssembly *)a nodeConstant:(YASLGrammarNode *)node {
	NSNumber *constantType = [a pop];
	YASLToken *token = [a pop];

	NSNumber *value;
	YASLDataType *dataType;
	YASLBuiltInType type = [constantType unsignedIntegerValue];
	dataType = [self.declarationScope typeByName:[YASLDataType builtInTypeToTypeIdentifier:type]];
	switch (type) {
		case YASLBuiltInTypeInt:
			value = @([token asInteger]);
			break;
		case YASLBuiltInTypeFloat:
			value = @([token asFloat]);
			break;
		case YASLBuiltInTypeBool:
			value = @([token asBool]);
			break;
		case YASLBuiltInTypeChar:
			value = @([[token asString] characterAtIndex:0]);
			break;
//		case YASLConstantTypeEnum:
//			//TODO: Enum handling
////			value = @([someenummanager enumFromIdentifier:token.value]);
//			break;

		default:
			break;
	}
	YASLTranslationConstant *constant = [YASLTranslationConstant constantInScope:self.declarationScope.currentScope withType:dataType andValue:value];
	[a push:constant];
}

- (void) processAssembly:(YASLAssembly *)a nodeIntegerConstant:(YASLGrammarNode *)node {
	[a push:@(YASLBuiltInTypeInt)];
}

- (void) processAssembly:(YASLAssembly *)a nodeFloatConstant:(YASLGrammarNode *)node {
	[a push:@(YASLBuiltInTypeFloat)];
}

- (void) processAssembly:(YASLAssembly *)a nodeBooleanConstant:(YASLGrammarNode *)node {
	[a push:@(YASLBuiltInTypeBool)];
}

- (void) processAssembly:(YASLAssembly *)a nodeCharacterConstant:(YASLGrammarNode *)node {
	[a push:@(YASLBuiltInTypeChar)];
}

- (void) processAssembly:(YASLAssembly *)a nodeEnumerationConstant:(YASLGrammarNode *)node {
	[a push:@(YASLBuiltInTypeInt)];
}

#pragma mark Methods

- (void) processAssembly:(YASLAssembly *)a nodeMethodCallExpr:(YASLGrammarNode *)node {
	[self fetchArray:a];
	NSArray *params = [a pop];
	YASLMethodCallExpression *methodCall = [YASLMethodCallExpression methodCallInScope:self.declarationScope.currentScope];
	for (YASLTranslationExpression *param in params) {
    [methodCall addSubNode:param];
	}
	[a push:methodCall];
}

- (void) processAssembly:(YASLAssembly *)a nodePostfixMethodCall:(YASLGrammarNode *)node {
	YASLMethodCallExpression *methodCall = [a pop];
	YASLTranslationExpression *address = [a pop];
	methodCall.methodAddress = address;
	[a push:methodCall];
}

@end
