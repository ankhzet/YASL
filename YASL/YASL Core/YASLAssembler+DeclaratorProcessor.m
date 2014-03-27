//
//  YASLAssembler+DeclaratorProcessor.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+DeclaratorProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (DeclaratorProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeDeclarator:(YASLAssemblyNode *)node {
	YASLTranslationDeclarator *declarator = [a pop];
	NSNumber *pointerRef = [a popTillChunkMarker];
	if (!pointerRef) pointerRef = @0;

	declarator.isPointer = [pointerRef unsignedIntegerValue];
	[a push:declarator];
}

- (void) processAssembly:(YASLAssembly *)a nodePointer:(YASLAssemblyNode *)node {
	NSNumber *pointer = [a popTillChunkMarker];
	NSInteger newValue = pointer ? [pointer integerValue] + 1 : 1;
	[a push:@(newValue)];
}

- (void) processAssembly:(YASLAssembly *)a nodeDirectDeclarator:(YASLAssemblyNode *)node {
	YASLAssembly *fetched = [self reverseFetch:a];
	YASLToken *identifier = [fetched pop];

	YASLTranslationDeclarator *declarator = [YASLTranslationDeclarator nodeInScope:[self scope] withType:YASLTranslationNodeTypeInitializer];
	declarator.declaratorIdentifier = identifier.value;

	while ([fetched notEmpty]) {
		YASLDeclaratorSpecifier *specifier = [fetched pop];
		[declarator addSpecifier:specifier];
	}
	declarator.isPointer = 0;
	[a push:declarator];
}

- (void) processAssembly:(YASLAssembly *)a nodeArrayDeclarator:(YASLAssemblyNode *)node {
	NSUInteger elements = 0;
	id top = [a popTill:a.chunkMarker];
	if (top) {
		if (![top isKindOfClass:[YASLTranslationExpression class]])
			[self raiseError:@"Expression expected, \"%@\" found", [top class]];

		elements = [(YASLTranslationConstant *)top toInteger];
	}

	if (elements) {
		YASLDeclaratorSpecifier *specifier = [YASLDeclaratorSpecifier specifierWithType:YASLTranslationNodeTypeArrayDeclarator param:elements andElems:@[]];
		[a push:specifier];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeDeclaratorList:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

@end
