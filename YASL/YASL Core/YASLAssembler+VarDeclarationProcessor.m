//
//  YASLAssembler+VarDeclarationProcessor.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+VarDeclarationProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (VarDeclarationProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeVarDeclaration:(YASLGrammarNode *)node {
	NSArray *declarations = [a pop];
	YASLDataType *declarationDataType = [a pop];

	for (YASLLocalDeclaration *declaration in declarations) {
		declaration.dataType = declarationDataType;
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeInitDeclarator:(YASLGrammarNode *)node {
	id top = [a pop];
	YASLDeclarationInitializer *initializer = nil;
	if ([top isKindOfClass:[YASLDeclarationInitializer class]]) {
		initializer = top;
		top = [a pop];
	}
	YASLTranslationDeclarator *declarator = top;
	YASLLocalDeclaration *declaration = [self.declarationScope localDeclarationByIdentifier:declarator.declaratorIdentifier];
	if (declaration) {
		[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
	}

	declaration = [self.declarationScope newLocalDeclaration:declarator.declaratorIdentifier];
	declaration.declarationInitializer = initializer;
	declaration.declarator = declarator;

	[a push:declaration];
}

- (void) processAssembly:(YASLAssembly *)a nodeInitDeclaratorList:(YASLGrammarNode *)node {
	NSMutableArray *declarations = [NSMutableArray array];
	id top;
	while ((top = [a popTill:a.chunkMarker])) {
		[declarations addObject:top];
	}

	[a push:declarations];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentInitializer:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];

	YASLDeclarationInitializer *initializer = [YASLDeclarationInitializer initializerWithType:YASLInitializerTypeConstantInitializer andExpression:expression];

	[a push:initializer];
}

- (void) processAssembly:(YASLAssembly *)a nodeInitializerList:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [YASLTranslationExpression expressionWithType:YASLExpressionTypeDesignatedInitializer andSpecifier:nil];

	YASLDeclarationInitializer *initializer = [YASLDeclarationInitializer initializerWithType:YASLInitializerTypeArrayInitializer andExpression:expression];
	YASLDeclarationInitializer *top;
	NSMutableArray *elements = [@[] mutableCopy];
	while ((top = [a popTill:a.chunkMarker])) {
		[elements addObject:top];
	}
	for (YASLTranslationNode *element in [elements reverseObjectEnumerator]) {
		[expression addSubNode:element];
	}

	[a push:initializer];
}


@end
