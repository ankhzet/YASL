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
			YASLTranslationExpression *right = [operands pop];
			YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:[self scope] withType:type andSpecifier:operator];
			[expression addSubNode:left];
			[expression addSubNode:right];
			left = expression;
		}
	}

	return left;
}

/*!@brief Build espression node for `additive` expression: operand ([+-] operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeAdditiveExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `multiplicative` expression: operand ([*%/] operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeMultiplicativeExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `logical or` expression: operand ('||' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeLogicalOrExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `logical and` expression: operand ('&&' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeLogicalAndExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `aratmetic and` expression: operand ('&' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeAndExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `exclusive or` expression: operand ('^' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeExclusiveOrExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic or` expression: operand ('|' operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeInclusiveOrExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic shift` expression: operand (('<<' | '>>') operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeShiftExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic relational` expression: operand (( '<' | '<=' | '>' | '>=' ) operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeRelationalExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `arithmetic relational` expression: operand (( '!=' | '==' ) operand)* . */
- (void) processAssembly:(YASLAssembly *)a nodeEqualityExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [self fetchExpressionFromAssembly:a forExpressionType:YASLExpressionTypeBinary];
	[a push:expression];
}

/*!@brief Build espression node for `ternar` expression: condition ? true-expression : false-expression . */
- (void) processAssembly:(YASLAssembly *)a nodeTernarExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *elseExpression = [a pop];
	YASLTranslationExpression *ifExpression = [a popTillChunkMarker];
	if (ifExpression) {
		YASLTranslationExpression *condition = [a pop];
		YASLTranslationExpression *ternar = [YASLTernarExpression ternarExpressionInScope:[self scope]];
		[ternar addSubNode:condition];
		[ternar addSubNode:ifExpression];
		[ternar addSubNode:elseExpression];
		elseExpression = ternar;
	}
	[a push:elseExpression];
}

/*!@brief Build espression node for `constant` expression: (numeric | string | boolean) constant . */
- (void) processAssembly:(YASLAssembly *)a nodeConstantExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLTranslationExpression *folded = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
	if (folded.expressionType != YASLExpressionTypeConstant)
		[self raiseError:@"Constant expression expected, \"%@\" found", [expression class]];

	[a push:folded];
}

/*!@brief Build espression node for `typecast` expression: '(' data-type ')' operand . */
- (void) processAssembly:(YASLAssembly *)a nodeTypeCast:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLDataType *castType = [a pop];
	YASLTypecastExpression *castExpression = [YASLTypecastExpression typecastInScope:[self scope] withType:castType];
	[castExpression addSubNode:expression];
	[a push:castExpression];
}

#pragma mark - Unary

- (void) processAssembly:(YASLAssembly *)a nodeUnaryOperator:(YASLAssemblyNode *)node {
	YASLToken *operator = [a pop];
	[a push:operator.value];
}

- (void) processAssembly:(YASLAssembly *)a nodeUnaryIncrement:(YASLAssemblyNode *)node {
	[a push:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorIncrement]];
}

- (void) processAssembly:(YASLAssembly *)a nodeUnaryDecrement:(YASLAssemblyNode *)node {
	[a push:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorDecrement]];
}

- (void) processAssembly:(YASLAssembly *)a nodeUnaryOperatorExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a pop];
	NSString *operatorSymbol = [a pop];

//	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operatorSymbol];
	YASLUnaryExpression *unaryExpression = [YASLUnaryExpression expressionInScope:[self scope] withType:YASLExpressionTypeUnary andSpecifier:operatorSymbol];
	[unaryExpression addSubNode:expression];
	[a push:unaryExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeIncrementDecrementExpression:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a pop];
	NSString *operatorToken = [a pop];
	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operatorToken unary:YES];
	YASLTranslationExpression *unaryExpression = [YASLAssignmentExpression assignmentInScope:[self scope] withSpecifier:operator];
	[unaryExpression addSubNode:expression];
	[a push:unaryExpression];
}

#pragma mark - Variables

- (void) processAssembly:(YASLAssembly *)a nodeVariable:(YASLAssemblyNode *)node {
	YASLToken *variable = [a pop];
	YASLLocalDeclaration *declaration = [self.declarationScope localDeclarationByIdentifier:variable.value];
	if (!declaration) {
		[self raiseError:@"Variable \"%@\" undefined",variable.value];
	}
	YASLTranslationExpression *expression = [YASLTranslationExpression expressionInScope:[self scope] withType:YASLExpressionTypeVariable andSpecifier:variable.value];
	expression.returnType = declaration.dataType;
	[a push:expression];
}

#pragma mark - Constants

typedef NS_ENUM(NSUInteger, YASLConstantType) {
	YASLConstantTypeVoid = YASLBuiltInTypeVoid,
	YASLConstantTypeInt = YASLBuiltInTypeInt,
	YASLConstantTypeFloat= YASLBuiltInTypeFloat,
	YASLConstantTypeBool = YASLBuiltInTypeBool,
	YASLConstantTypeChar = YASLBuiltInTypeChar,
	YASLConstantTypeEnum,
	YASLConstantTypeString,
};


- (void) processAssembly:(YASLAssembly *)a nodeConstant:(YASLAssemblyNode *)node {
	NSNumber *constantType = [a pop];
	YASLToken *token = [a pop];

	NSNumber *value;
	YASLDataType *dataType;
	YASLConstantType type = [constantType unsignedIntegerValue];
	dataType = [self.declarationScope typeByName:[YASLDataType builtInTypeToTypeIdentifier:(YASLBuiltInType)type]];
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
		case YASLConstantTypeString: {
			NSString *string = [token asString];
			value = @([self.declarationScope.stringsManager allocString:string]);
			dataType = [self.declarationScope typeByName:YASLBuiltInTypeIdentifierString];
			break;
		}
		case YASLConstantTypeEnum: { // used for enums, variables, reserved consts
			NSString *identifier = token.value;
			if ([identifier isEqualToString:@"nil"]) {
				value = @0;
				dataType = [[self scope] typeByName:YASLBuiltInTypeIdentifierInt];
				break;
			}

			if ([identifier isEqualToString:@"maxInt"]) {
				value = @((YASLInt)(pow(2, 31) - 1));
				dataType = [[self scope] typeByName:YASLBuiltInTypeIdentifierInt];
				break;
			}

			YASLEnumDataType *enumType = [YASLEnumDataType hasEnum:identifier inManager:[self scope]];
			if (!enumType) { // enum not found, is it a variable name?
				[a push:token];
				[self processAssembly:a nodeVariable:node];
				return;
			}

			value = @([enumType enumValue:identifier]);
			dataType = enumType.parent;
			break;
		}

		default:
			break;
	}
	YASLTranslationConstant *constant = [YASLTranslationConstant constantInScope:[self scope] withType:dataType andValue:value];
	[a push:constant];
}

- (void) processAssembly:(YASLAssembly *)a nodeIntegerConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeInt)];
}

- (void) processAssembly:(YASLAssembly *)a nodeFloatConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeFloat)];
}

- (void) processAssembly:(YASLAssembly *)a nodeBooleanConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeBool)];
}

- (void) processAssembly:(YASLAssembly *)a nodeCharacterConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeChar)];
}

- (void) processAssembly:(YASLAssembly *)a nodeEnumerationConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeEnum)];
}

- (void) processAssembly:(YASLAssembly *)a nodeStringConstant:(YASLAssemblyNode *)node {
	[a push:@(YASLConstantTypeString)];
}

#pragma mark Postfix expression

- (void) processAssembly:(YASLAssembly *)a nodePostfixExpressions:(YASLAssemblyNode *)node {
	[a push:[self reverseFetch:a]];
}

- (void) processAssembly:(YASLAssembly *)a nodePostfixExpression:(YASLAssemblyNode *)node {
	YASLAssembly *postfixes = [a pop];
	YASLTranslationExpression *expression = [a popTillChunkMarker];

	YASLTranslationExpression *postfix;
	while ((postfix = [postfixes pop])) {
		[postfix setSubNodes:[@[expression] arrayByAddingObjectsFromArray:[[postfix nodesEnumerator:NO] allObjects]]];
		expression = postfix;
	}
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodePostfixIncrementDecrement:(YASLAssemblyNode *)node {
	NSString *operatorToken = [a pop];
	YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:operatorToken unary:YES];
	YASLAssignmentExpression *unaryExpression = [YASLAssignmentExpression assignmentInScope:[self scope] withSpecifier:operator];
	unaryExpression.postfix = YES;
	[a push:unaryExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeMethodCallExpr:(YASLAssemblyNode *)node {
	[self fetchArray:a];
	NSArray *params = [a pop];
	YASLMethodCallExpression *methodCall = [YASLMethodCallExpression methodCallInScope:[self scope]];
	for (YASLTranslationExpression *param in params) {
    [methodCall addSubNode:param];
	}
	[a push:methodCall];
}

- (void) processAssembly:(YASLAssembly *)a nodeArrayAccessExpr:(YASLAssemblyNode *)node {
	YASLTranslationExpression *index = [a pop];
	YASLArrayElementExpression *arrayElement = [YASLArrayElementExpression arrayElementInScope:[self scope]];
	[arrayElement addSubNode:index];
	[a push:arrayElement];
}

- (void) processAssembly:(YASLAssembly *)a nodePropAccessExpr:(YASLAssemblyNode *)node {
	YASLToken *property = [a pop];
	YASLStructPropertyExpression *structProperty = [YASLStructPropertyExpression structProperty:property.value inScope:[self scope]];
	[a push:structProperty];
}

@end
