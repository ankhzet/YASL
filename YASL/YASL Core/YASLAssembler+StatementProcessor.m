//
//  YASLAssembler+StatementProcessor.m
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+StatementProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (StatementProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeStatement:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	expression = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];

	[a push:expression];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
	YASLDeclarationScope *scope = self.declarationScope.currentScope;
	scope.name = [NSString stringWithFormat:@"%@:inner", scope.parentScope.name];
	scope.placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] ofsettedByParent];
}

- (void) processAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLGrammarNode *)node {
	[self fetchArray:a];
	NSArray *expressions = [a pop];
	NSMutableArray *foldedExpressions = [@[] mutableCopy];
	for (YASLTranslationExpression *expression in expressions) {
		YASLTranslationExpression *folded = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
		[foldedExpressions insertObject:folded atIndex:0];
	}
	[a push:foldedExpressions];

	[self.declarationScope popScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentOperator:(YASLGrammarNode *)node {
	YASLToken *special = [a popTillChunkMarker];
	NSString *specifier = special ? special.value : nil;
	YASLTranslationExpression *expression = [YASLAssignmentExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeAssignment andSpecifier:specifier];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentExpression:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLTranslationExpression *operation = [a popTillChunkMarker];
	if (operation) {
		YASLTranslationExpression *destination = [a popTillChunkMarker];
		[operation addSubNode:destination];
		[operation addSubNode:expression];
		expression = operation;
	}

	[a push:expression];
}

@end

@implementation YASLAssembler (SelectionStatementProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeSelectionIf:(YASLGrammarNode *)node {
	[self fetchArray:a];
	NSMutableArray *operands = [[a pop] mutableCopy];
	YASLTranslationExpression *condition = [operands lastObject];
	[operands removeLastObject];

	YASLIfExpression *expression = [YASLIfExpression ifExpressionInScope:self.declarationScope.currentScope];
	[expression addSubNode:condition];
	[expression addSubNode:[operands lastObject]];
	if ([operands count] > 1)
		[expression addSubNode:[operands firstObject]];

	[a push:expression];
}

@end

@implementation YASLAssembler (JumpStatementProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeJumpReturn:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLReturnExpression *returnExpression = [YASLReturnExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeReturn];
	[returnExpression addSubNode:expression];
	[a push:returnExpression];
}



@end
