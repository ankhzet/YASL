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

- (void) processAssembly:(YASLAssembly *)a nodeBuiltInType:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	YASLDataType *type = [self.declarationScope typeByName:[token value]];
	if (!type)
		[self raiseError:@"Unknown type \"%@\"", token.value];

	[a push:type];
}

- (void) processAssembly:(YASLAssembly *)a nodeTypeDeclaration:(YASLAssemblyNode *)node {
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
	newType.specifiers = [[declarator.declaratorSpecifiers enumerator:NO] allObjects];
	newType.isPointer = declarator.isPointer;
	newType.defined = YES;

	[self.declarationScope registerType:newType];
}

- (void) processAssembly:(YASLAssembly *)a nodeTypedefType:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	NSString *typeName = token.value;
	YASLDataType *type = [self.declarationScope typeByName:typeName];
	if (!type) {
		[self raiseError:@"Unknown data type \"%@\"", typeName];
		//		type = [YASLDataType typeWithName:typeName];
	}

	[a push:type];
}

@end

@implementation YASLAssembler (EnumTypeProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeEnumMember:(YASLAssemblyNode *)node {
	YASLTranslationConstant *constant= [a pop];
	YASLToken *identifier = [a popTillChunkMarker];
	if (!identifier) {
		identifier = (id)constant;
		constant = nil;
	}

	[a push:@{@0: identifier.value, @1: constant ? @([constant toInteger]) : [NSNull null]}];
}

- (void) processAssembly:(YASLAssembly *)a nodeEnumMembersList:(YASLAssemblyNode *)node {
	[a push:[self reverseFetch:a]];
}

- (void) processAssembly:(YASLAssembly *)a nodeEnumType:(YASLAssemblyNode *)node {
	YASLAssembly *members = [a pop];
	YASLEnumDataType *enumType = [YASLEnumDataType typeWithName:@""];
	while ([members notEmpty]) {
		NSDictionary *enumMember = [members pop];
    NSString *identifier = enumMember[@0];
		if ([enumType hasEnum:identifier])
			[self raiseError:@"Enum identifier duplicate: \"%@\"", identifier];

		NSNumber *value = enumMember[@1];
		if (value == (id)[NSNull null])
			[enumType addEnum:identifier];
		else {
			[enumType addEnum:identifier value:[value unsignedIntegerValue]];
		}
	}
	[a push:enumType];
}

@end
