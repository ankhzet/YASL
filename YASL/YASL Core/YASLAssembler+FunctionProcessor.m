//
//  YASLAssembler+FunctionProcessor.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+FunctionProcessor.h"
#import "YASLCoreLangClasses.h"

typedef NS_ENUM(NSUInteger, YASLFunctionSpecifier) {
	YASLFunctionSpecifierNative = 1 << 0,
};

@implementation YASLAssembler (FunctionProcessor)

- (void) preProcessAssembly:(YASLAssembly *)a nodeFunctionDefinition:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
	[self scope].placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] notOfsettedChildsByLocals];
}

- (void) processAssembly:(YASLAssembly *)a nodeFunctionSpecifier:(YASLGrammarNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeNative:(YASLGrammarNode *)node {
	[a push:@(YASLFunctionSpecifierNative)];
}

- (void) processAssembly:(YASLAssembly *)a nodeFunctionDefinition:(YASLGrammarNode *)node {
	YASLAssembly *nodes = [self reverseFetch:a];
	NSArray *specifiers = [nodes pop];
	YASLDataType *returnType = [nodes pop];
	YASLTranslationDeclarator *declarator = [nodes pop];
	YASLCompoundExpression *body = [nodes pop];

	BOOL isForwardDeclaration = body == nil;

	YASLDeclarationScope *outerScope = [self scope].parentScope;
	YASLDeclarationScope *bodyScope = [[self scope].childs firstObject];

	BOOL alreadyDeclared = [outerScope isDeclared:declarator.declaratorIdentifier inLocalScope:YES];
	if (alreadyDeclared) {
		[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
	}

	YASLLocalDeclaration *declaration = [outerScope newLocalDeclaration:declarator.declaratorIdentifier];
	declaration.dataType = returnType;
	declaration.declarator = declarator;

	YASLTranslationFunction *function = [YASLTranslationFunction functionInScope:[self scope] withDeclaration:declaration];
	function.declaratorIdentifier = declarator.declaratorIdentifier;

	if (!isForwardDeclaration) {
		if ([declaration.dataType baseType] != YASLBuiltInTypeVoid) {
			YASLLocalDeclaration *result = [bodyScope newLocalDeclaration:[function returnVarIdentifier]];
			result.dataType = declaration.dataType;
		}
		YASLLocalDeclaration *extLabel = [outerScope newLocalDeclaration:[function exitLabelIdentifier]];
		extLabel.dataType = nil;

		[function addSubNode:body];
	} else {
		if ([specifiers containsObject:@(YASLFunctionSpecifierNative)]) {
			function.native = [[YASLNativeFunctions sharedFunctions] findByName:function.declaratorIdentifier];
			if (!function.native)
				[self raiseError:@"Unknown native function \"%@\"", function.declaratorIdentifier];
		}
	}

	[a push:function];

	[self scope].name = [NSString stringWithFormat:@"func:%@", declarator.declaratorIdentifier];
	[self.declarationScope popScope];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeFunctionBody:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
	[self scope].name = [NSString stringWithFormat:@"funcBody"];
	[self scope].placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeOnStack] ofsettedByParent];
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
	[a push:[[params reverseObjectEnumerator] allObjects]];
}

@end

@implementation YASLAssembler (JumpStatementProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeJumpReturn:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	YASLJumpExpression *returnExpression = [YASLJumpExpression expressionInScope:[self scope] withType:YASLExpressionTypeReturn];
	[returnExpression addSubNode:expression];
	[a push:returnExpression];
}

@end
