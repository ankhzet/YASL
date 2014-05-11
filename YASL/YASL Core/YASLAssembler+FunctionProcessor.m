//
//  YASLAssembler+FunctionProcessor.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+FunctionProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (FunctionProcessor)

- (void) preProcessAssembly:(YASLAssembly *)a nodeFunctionDefinition:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
	self.declarationScope.currentScope.placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] notOfsettedChildsByLocals];
}

- (void) processAssembly:(YASLAssembly *)a nodeFunctionDefinition:(YASLGrammarNode *)node {
	NSArray *body = [a pop];
	YASLTranslationDeclarator *declarator = [a pop];
	YASLDeclarationScope *functionScope = self.declarationScope.currentScope;
	YASLDeclarationScope *outerScope = functionScope.parentScope;
	YASLDeclarationScope *bodyScope = [functionScope.childs firstObject];

	BOOL alreadyDeclared = [outerScope isDeclared:declarator.declaratorIdentifier inLocalScope:YES];
	if (alreadyDeclared) {
		[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
	}

	YASLLocalDeclaration *declaration = [outerScope newLocalDeclaration:declarator.declaratorIdentifier];
	declaration.dataType = [a pop];
	declaration.declarator = declarator;

	YASLTranslationFunction *function = [YASLTranslationFunction functionInScope:functionScope withDeclaration:declaration];
	function.declaratorIdentifier = declarator.declaratorIdentifier;

	if ([declaration.dataType baseType] != YASLBuiltInTypeVoid) {
		YASLLocalDeclaration *result = [bodyScope newLocalDeclaration:[function returnVarIdentifier]];
		result.dataType = declaration.dataType;
	}
	YASLLocalDeclaration *extLabel = [outerScope newLocalDeclaration:[function exitLabelIdentifier]];
	extLabel.dataType = nil;

	for (YASLTranslationNode *statement in body) {
    [function addSubNode:statement];
	}
	[a push:function];

	functionScope.name = [NSString stringWithFormat:@"func:%@", declarator.declaratorIdentifier];
	[self.declarationScope popScope];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeFunctionBody:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
	self.declarationScope.currentScope.name = [NSString stringWithFormat:@"funcBody"];
	self.declarationScope.currentScope.placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] ofsettedByParent];
}

- (void) processAssembly:(YASLAssembly *)a nodeFunctionBody:(YASLGrammarNode *)node {
	[self.declarationScope popScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeMethodParamGroup:(YASLGrammarNode *)node {
	NSArray *group = [a pop];
	YASLDataType *groupTypeSpecifier = [a pop];

	for (YASLTranslationDeclarator *declarator in [group reverseObjectEnumerator]) {
		BOOL alreadyDeclared = [self.declarationScope isDeclared:declarator.declaratorIdentifier inLocalScope:YES];
		if (alreadyDeclared) {
			[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
		}
		YASLLocalDeclaration *declaration = [self.declarationScope newLocalDeclaration:declarator.declaratorIdentifier];
		declaration.declarator = declarator;
		declaration.dataType = groupTypeSpecifier;
		[a push:declaration];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeMethodParamList:(YASLGrammarNode *)node {
	[self fetchArray:a];

	NSArray *params = [a pop];
	NSMutableArray *array = [NSMutableArray array];
	for (id obj in [params reverseObjectEnumerator]) {
    [array addObject:obj];
	}
	[a push:array];
}

@end
