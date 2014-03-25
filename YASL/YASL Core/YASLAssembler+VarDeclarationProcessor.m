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
		declaration.dataType = declarationDataType;
		YASLTranslationDeclarator *declarator = declaration.declarator;
		YASLTranslationExpression *variable = [YASLTranslationExpression expressionInScope:scope withType:YASLExpressionTypeVariable andSpecifier:declarator.declaratorIdentifier];
		variable.returnType = declarationDataType;

		if ([declarator.declaratorSpecifiers notEmpty]) {
			YASLAssembly *specifiers = [declarator.declaratorSpecifiers copy];
			while ([specifiers notEmpty]) {
				YASLDeclaratorSpecifier *specifier = [specifiers pop];
				switch (specifier.type) {
					case YASLTranslationNodeTypeArrayDeclarator: {
						NSUInteger count = specifier.param;
						NSArray *elements = specifier.elements;
						YASLArrayDataType *arrayDataType = [YASLArrayDataType typeWithName:@""];
						arrayDataType.parent = declarationDataType;
						arrayDataType.elements = count;
						variable.returnType = arrayDataType;
						declaration.dataType = arrayDataType;
						if ([elements count]) {
							YASLDataType *indexDataType = [self.declarationScope.globalTypesManager typeByName:YASLBuiltInTypeIdentifierInt];
							YASLTranslationNode *elementInits = [YASLTranslationNode nodeInScope:scope withType:YASLTranslationNodeTypeInitializer];

							NSMutableArray *initializers = [NSMutableArray array];
							NSUInteger index = 0;
							for (YASLTranslationExpression *initializer in elements) {
								YASLArrayElementExpression *arrayElement = [YASLArrayElementExpression arrayElementInScope:scope];
								YASLTranslationConstant *elementIndex = [YASLTranslationConstant constantInScope:scope withType:indexDataType andValue:@(index++)];
								[arrayElement addSubNode:variable];
								[arrayElement addSubNode:elementIndex];

								YASLTranslationExpression *expression = [initializer nthOperand:0];
								[initializer setNth:0 operand:arrayElement];
								[initializer setNth:1 operand:expression];
								YASLTranslationExpression *folded = [initializer foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
								[elementInits addSubNode:folded];
								[initializers addObject:folded];
								[a push:folded];
							}
							[declarator setSubNodes:@[elementInits]];
						}
						break;
					}
					case YASLTranslationNodeTypeFunction:
//						[self raiseError:@"Function declarator implementation"];
						break;

					default:
						[self raiseError:@"Unknown declarator type: \"%u\"", specifier.type];
						break;
				}
			}
		} else {
			YASLTranslationExpression *initializer = [declarator nthOperand:0];
			if (initializer) {
				YASLTranslationExpression *expression = [initializer leftOperand];
				[initializer setNth:0 operand:variable];
				[initializer addSubNode:expression];
				initializer = (id)[initializer foldConstantExpressionWithSolver:self.declarationScope.expressionSolver];
				[declarator setNth:0 operand:initializer];
				[a push:initializer];
			}
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
		[declarator addSpecifier:[YASLDeclaratorSpecifier specifierWithType:YASLTranslationNodeTypeArrayDeclarator param:[elements count] andElems:elements]];
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
