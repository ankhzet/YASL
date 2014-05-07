//
//  YASLAssembler+TypeDeclarationProcessor.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+TypeDeclarationProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (TypeDeclarationProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeBuiltInType:(YASLGrammarNode *)node {
	YASLToken *token = [a pop];
	YASLDataType *type = [self.declarationScope typeByName:[token value]];
	[a push:type];
}

- (void) processAssembly:(YASLAssembly *)a nodeTypeDeclaration:(YASLGrammarNode *)node {
	YASLTranslationDeclarator *declarator = [a pop];

	NSString *declaredTypeName = declarator.declaratorIdentifier;
	YASLDataType *newType = [self.declarationScope typeByName:declaredTypeName];
	if (!newType)
		newType = [YASLDataType typeWithName:declaredTypeName];

	if (newType.defined) {
		[self raiseError:@"Type \"%@\" already defined", newType.name];
	}

	YASLDataType *definedType = [a pop];
	if (definedType.defined) {
		newType.parent = definedType;
	} else {
		definedType.name = newType.name;
		newType = definedType;
	}
	newType.specifiers = declarator.declaratorSpecifiers;
	newType.isPointer = declarator.isPointer;
	newType.defined = YES;

	[self.declarationScope registerType:newType];
}

- (void) processAssembly:(YASLAssembly *)a nodeTypedefType:(YASLGrammarNode *)node {
	YASLToken *token = [a pop];
	NSString *typeName = token.value;
	YASLDataType *type = [self.declarationScope typeByName:typeName];
	if (!type)
		type = [YASLDataType typeWithName:typeName];

	[a push:type];
}


@end
