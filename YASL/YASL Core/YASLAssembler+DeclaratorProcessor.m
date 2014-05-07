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

- (void) processAssembly:(YASLAssembly *)a nodeDeclarator:(YASLGrammarNode *)node {
	id top = [a top];
	NSNumber *pointerRef = @0;
	YASLTranslationDeclarator *declarator;
	if ([top isKindOfClass:[YASLTranslationDeclarator class]]) {
		declarator = top;
	} else {
		pointerRef = [a pop];
		declarator = [a top];
	}
	declarator.isPointer = [pointerRef unsignedIntegerValue];
}

- (void) processAssembly:(YASLAssembly *)a nodeDirectDeclarator:(YASLGrammarNode *)node {
	NSMutableArray *specificDeclarators = [@[] mutableCopy];
	id top;
	while ((top = [a popTill:a.chunkMarker])) {
		[specificDeclarators addObject:top];
	}

	YASLToken *token = [specificDeclarators lastObject];
	[specificDeclarators removeObject:token];

	YASLTranslationDeclarator *declarator = [YASLTranslationDeclarator new];
	declarator.declaratorIdentifier = token.value;
	declarator.declaratorSpecifiers = specificDeclarators;
	declarator.isPointer = 0;
	[a push:declarator];
}

- (void) processAssembly:(YASLAssembly *)a nodeArrayDeclarator:(YASLGrammarNode *)node {
	id top = [a popTill:a.chunkMarker];
	if (top) {

	}
	id specifier = @{@0: @"array", @1: top ? top : [NSNull null]};
	[a push:specifier];
}

@end
