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

- (void) processAssembly:(YASLAssembly *)a nodeVarDeclaration:(YASLAssemblyNode *)node {
	YASLDeclarationScope *scope = [self scope];
	NSArray *declarations = [a pop];
	YASLDataType *declarationDataType = [a pop];

	for (YASLLocalDeclaration *declaration in [declarations reverseObjectEnumerator]) {
		YASLTranslationDeclarator *declarator = declaration.declarator;
		YASLTranslationExpression *variable = [YASLTranslationExpression expressionInScope:scope withType:YASLExpressionTypeVariable andSpecifier:declarator.declaratorIdentifier];


		YASLDataType *specificType = [declarator declareSpecific:variable withDataType:declarationDataType inScope:self.declarationScope];

		declaration.dataType = specificType;
		YASLTranslationExpression *initializer = [declarator nthOperand:0];
		if (initializer) {
			if ([initializer isKindOfClass:[YASLTranslationExpression class]]) {
				YASLTranslationExpression *expression = [initializer leftOperand];
				[initializer setNth:0 operand:variable];
				[initializer addSubNode:expression];
				initializer = (id)[initializer foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
				[declarator setNth:0 operand:initializer];
				[a push:initializer];
			} else
				[self raiseError:@"Unknown initializer \"%@\"", [initializer class]];
		}
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeInitDeclarator:(YASLAssemblyNode *)node {
	YASLAssignmentExpression *initializer = [a pop];
	YASLTranslationDeclarator *declarator = [a popTillChunkMarker];
	if (!declarator) {
		declarator = (id)initializer;
		initializer = nil;
	}

	BOOL alreadyDeclared = [self.declarationScope isDeclared:declarator.declaratorIdentifier inLocalScope:YES];
	if (alreadyDeclared) {
		[self raiseError:@"\"%@\" already declared", declarator.declaratorIdentifier];
	}
	YASLLocalDeclaration *declaration = [self.declarationScope newLocalDeclaration:declarator.declaratorIdentifier];
	declaration.declarator = declarator;
	[a push:declaration];

	if (!initializer)
		return;

	if (![initializer isKindOfClass:[NSArray class]]) {
		[declarator addSubNode:initializer];
	} else {
		NSArray *elements = (id)initializer;
		[declarator addSpecifier:[YASLDeclaratorSpecifier specifierWithType:YASLTranslationNodeTypeArrayDeclarator param:[elements count] andElems:[[elements reverseObjectEnumerator] allObjects]]];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeInitDeclaratorList:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeAssignmentInitializer:(YASLAssemblyNode *)node {
	YASLTranslationExpression *expression = [a pop];

	YASLAssignmentExpression *initializer = [YASLAssignmentExpression assignmentInScope:[self scope] withSpecifier:YASLExpressionOperatorUnknown];
	[initializer addSubNode:expression];

	[a push:initializer];
}

- (void) processAssembly:(YASLAssembly *)a nodeInitializerList:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}


@end
