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

- (void) processAssembly:(YASLAssembly *)a nodeStatement:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a popTillChunkMarker];
	if (!expression)
		return;
	
	expression = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];

	[a push:expression];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLAssemblyNode *)node {
	[self.declarationScope pushScope];
	[self scope].name = [NSString stringWithFormat:@"%@:inner", [self scope].parentScope.name];
	[self scope].placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] ofsettedByParent];
}

- (void) processAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLAssemblyNode *)node {
	[self fetchArray:a];
	NSArray *expressions = [a pop];
	NSMutableArray *foldedExpressions = [@[] mutableCopy];
	for (YASLTranslationExpression *expression in expressions) {
		YASLTranslationExpression *folded = [expression foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
		[foldedExpressions insertObject:folded atIndex:0];
	}
	YASLCompoundExpression *compound = [YASLCompoundExpression compoundExpressionInScope:[self scope]];
	[compound setSubNodes:foldedExpressions];
	[a push:compound];

	[self.declarationScope popScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentOperator:(YASLAssemblyNode *)node {
	YASLToken *special = [a popTillChunkMarker];
	NSString *specifier = special ? special.value : nil;
	YASLTranslationExpression *expression = [YASLAssignmentExpression expressionInScope:[self scope] withType:YASLExpressionTypeAssignment andSpecifier:specifier];
	[a push:expression];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentExpression:(YASLAssemblyNode *)node {
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

- (void) processAssembly:(YASLAssembly *)a nodeSelectionIf:(YASLAssemblyNode *)node {
	[self fetchArray:a];
	NSMutableArray *operands = [[a pop] mutableCopy];
	YASLTranslationExpression *condition = [operands lastObject];
	[operands removeLastObject];

	YASLIfExpression *expression = [YASLIfExpression ifExpressionInScope:[self scope]];
	[expression addSubNode:condition];
	[expression addSubNode:[operands lastObject]];
	if ([operands count] > 1)
		[expression addSubNode:[operands firstObject]];

	[a push:expression];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeSelectionSwitch:(YASLAssemblyNode *)node {
	YASLDeclarationScope *scope = [self.declarationScope pushScope];
	scope.name = @"switch";
	[scope newLocalDeclaration:YASLReservedWordBreak];
}

- (void) processAssembly:(YASLAssembly *)a nodeSelectionSwitch:(YASLAssemblyNode *)node {
	BOOL hasBreak = [[self scope] isDeclared:YASLReservedWordBreak inLocalScope:YES];
	if (!(hasBreak))
		[self raiseError:@"Break label undefined"];

	YASLAssembly *statements = [a pop];
	YASLTranslationExpression *switchExpr = [a pop];
	YASLSwitchExpression *switchNode = [YASLSwitchExpression switchExpressionInScope:[self scope]];
	switchNode.breakLabel = [[self scope] localDeclarationByIdentifier:YASLReservedWordBreak];
	[switchNode addSubNode:switchExpr];

	NSDictionary *statement;
	while ((statement = [statements pop])) {
		YASLTranslationExpression *caseValue = statement[@0];
		YASLTranslationExpression *caseStatement = statement[@1];
		YASLCompoundExpression *statementNode = [YASLCompoundExpression compoundExpressionInScope:[self scope]];
		if (caseValue != (id)[NSNull null])
			[statementNode addSubNode:caseValue];
		[statementNode addSubNode:caseStatement];
		[switchNode addSubNode:statementNode];
	}

	[a push:switchNode];
	[self.declarationScope popScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeSwitchStatements:(YASLAssemblyNode *)node {
	[a push:[self reverseFetch:a]];
}

- (void) processAssembly:(YASLAssembly *)a nodeSwitchStatement:(YASLAssemblyNode *)node {
	YASLTranslationExpression *statement = [a pop];
	YASLTranslationExpression *caseExpr = [a popTillChunkMarker];
	if (!caseExpr) {
		caseExpr = statement;
		statement = [YASLCompoundExpression compoundExpressionInScope:[self scope]];
	}
	[a push:@{@0: caseExpr, @1: statement}];
}

- (void) processAssembly:(YASLAssembly *)a nodeDefaultSwitchStatement:(YASLAssemblyNode *)node {
	YASLTranslationExpression *statement = [a popTillChunkMarker];
	if (!statement) {
		statement = [YASLCompoundExpression compoundExpressionInScope:[self scope]];
	}
	[a push:@{@0: [NSNull null], @1: statement}];
}

@end

@implementation YASLAssembler (IterationStatementProcessor)

- (void) assembly:(YASLAssembly *)a nodeBreakContinue:(NSString *)reservedWord {
	YASLLocalDeclaration *jumpDecl = [[self scope] localDeclarationByIdentifier:reservedWord];
	if (!jumpDecl)
		[self raiseError:@"\"%@\" statement out of loops/switch", reservedWord];

	YASLJumpExpression *jumpExpression = [YASLJumpExpression expressionInScope:[self scope] withType:YASLExpressionTypeJump andSpecifier:reservedWord];
	jumpExpression.jumpDeclaration = jumpDecl;

	[a push:jumpExpression];
}


- (void) processAssembly:(YASLAssembly *)a nodeBreak:(YASLAssemblyNode *)node {
	[self assembly:a nodeBreakContinue:YASLReservedWordBreak];
}

- (void) processAssembly:(YASLAssembly *)a nodeContinue:(YASLAssemblyNode *)node {
	[self assembly:a nodeBreakContinue:YASLReservedWordContinue];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeIterationStatement:(YASLAssemblyNode *)node {
	YASLDeclarationScope *scope = [self.declarationScope pushScope];
	[scope newLocalDeclaration:YASLReservedWordContinue];
	[scope newLocalDeclaration:YASLReservedWordBreak];
}

- (void) processAssembly:(YASLAssembly *)a nodeIterationStatement:(YASLAssemblyNode *)node {
	[self.declarationScope popScope];
}

- (void) pushWhileStatement:(YASLAssembly *)a withCondition:(YASLTranslationExpression *)condition andStatements:(YASLTranslationExpression *)statements {

	BOOL hasContinue = [[self scope] isDeclared:YASLReservedWordContinue inLocalScope:YES];
	BOOL hasBreak = [[self scope] isDeclared:YASLReservedWordBreak inLocalScope:YES];
	if (!(hasContinue && hasBreak))
		[self raiseError:@"Break or continue labels undefined"];

	YASLWhileExpression *whileExpression = [YASLWhileExpression whileExpressionInScope:[self scope]];
	[whileExpression addSubNode:condition];
	if (statements) [whileExpression addSubNode:statements];
	whileExpression.continueLabel = [[self scope] localDeclarationByIdentifier:YASLReservedWordContinue];
	whileExpression.breakLabel = [[self scope] localDeclarationByIdentifier:YASLReservedWordBreak];

	[a push:whileExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeStraightWhile:(YASLAssemblyNode *)node {
	YASLTranslationExpression *statements = [a pop];
	YASLTranslationExpression *condition = [a popTillChunkMarker];
	if (!condition) {
		condition = statements;
		statements = nil;
	}
	[self pushWhileStatement:a withCondition:condition andStatements:statements];
}

- (void) processAssembly:(YASLAssembly *)a nodeStraightDo:(YASLAssemblyNode *)node {
	YASLTranslationExpression *condition = [a pop];
	YASLTranslationExpression *statements = [a popTillChunkMarker];
	[self pushWhileStatement:a withCondition:condition andStatements:statements];
}

- (void) processAssembly:(YASLAssembly *)a nodeStraightFor:(YASLAssemblyNode *)node {
	YASLTranslationExpression *statements = [a pop];

	YASLTranslationExpression *iterator = [a pop];
	YASLTranslationExpression *condition = [a pop];
	YASLTranslationExpression *initializer = [a pop];

	BOOL hasContinue = [[self scope] isDeclared:YASLReservedWordContinue inLocalScope:YES];
	BOOL hasBreak = [[self scope] isDeclared:YASLReservedWordBreak inLocalScope:YES];
	if (!(hasContinue && hasBreak))
		[self raiseError:@"Break or continue labels undefined"];

	YASLForExpression *forExpression = [YASLForExpression whileExpressionInScope:[self scope]];
	[forExpression setNth:0 operand:initializer];
	[forExpression setNth:1 operand:condition];
	[forExpression setNth:2 operand:iterator];
	[forExpression setNth:3 operand:statements];

	forExpression.continueLabel = [[self scope] localDeclarationByIdentifier:YASLReservedWordContinue];
	forExpression.breakLabel = [[self scope] localDeclarationByIdentifier:YASLReservedWordBreak];

	[a push:forExpression];
}

- (void) processAssembly:(YASLAssembly *)a nodeForInitializer:(YASLAssemblyNode *)node {
	id expression = [a popTillChunkMarker];
	[a push:expression ? expression : [NSNull null]];
}

- (void) processAssembly:(YASLAssembly *)a nodeForCondition:(YASLAssemblyNode *)node {
	id expression = [a popTillChunkMarker];
	[a push:expression ? expression : [NSNull null]];
}

- (void) processAssembly:(YASLAssembly *)a nodeForIterator:(YASLAssemblyNode *)node {
	id expression = [a popTillChunkMarker];
	[a push:expression ? expression : [NSNull null]];
}

- (void) processAssembly:(YASLAssembly *)a nodeForStatements:(YASLAssemblyNode *)node {
	id expression = [a popTillChunkMarker];
	[a push:expression ? expression : [NSNull null]];
}

@end
