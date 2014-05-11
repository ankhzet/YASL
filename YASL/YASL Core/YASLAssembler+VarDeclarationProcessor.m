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
		YASLTranslationExpression *initializer = declaration.declarator.subnodes[0];
		YASLTranslationExpression *variable = [initializer leftOperand];
		variable.returnType = declarationDataType;
		initializer = [initializer foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
		declaration.declarator.subnodes[0] = initializer;
		[a push:declaration.declarator.subnodes[0]];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeInitDeclarator:(YASLGrammarNode *)node {
	id top = [a pop];
	YASLAssignmentExpression *initializer = nil;
	if ([top isKindOfClass:[YASLAssignmentExpression class]]) {
		initializer = top;
		top = [a pop];
	}
	YASLTranslationDeclarator *declarator = top;
	BOOL alreadyDeclared = [self.declarationScope isDeclared:declarator.declaratorIdentifier inLocalScope:YES];
	if (alreadyDeclared) {
		[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
	}

	YASLAssignmentExpression *assignment = (id)[initializer leftOperand];
	initializer.subnodes[0] = [YASLTranslationExpression expressionInScope:self.declarationScope.currentScope withType:YASLExpressionTypeVariable andSpecifier:declarator.declaratorIdentifier];
	[initializer addSubNode:assignment];
	[declarator addSubNode:initializer];

	YASLLocalDeclaration *declaration = [self.declarationScope newLocalDeclaration:declarator.declaratorIdentifier];
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

	YASLAssignmentExpression *initializer = [YASLAssignmentExpression assignmentInScope:self.declarationScope.currentScope withSpecifier:YASLExpressionOperatorUnknown];
	[initializer addSubNode:expression];

	[a push:initializer];
}

- (void) processAssembly:(YASLAssembly *)a nodeInitializerList:(YASLGrammarNode *)node {
	[self raiseError:@"Array initializer implementation pending"];
//	YASLTranslationExpression *expression = [YASLTranslationExpression expressionWithType:YASLExpressionTypeDesignatedInitializer andSpecifier:nil];
//
//	YASLDeclarationInitializer *initializer = [YASLDeclarationInitializer initializerWithType:YASLInitializerTypeArrayInitializer andExpression:expression];
//	YASLDeclarationInitializer *top;
//	NSMutableArray *elements = [@[] mutableCopy];
//	while ((top = [a popTill:a.chunkMarker])) {
//		[elements addObject:top];
//	}
//	for (YASLTranslationNode *element in [elements reverseObjectEnumerator]) {
//		[expression addSubNode:element];
//	}
//
//	[a push:initializer];
}


@end
