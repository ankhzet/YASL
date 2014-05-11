//
//  YASLAssembler.m
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler.h"

#import "YASLCoreLangClasses.h"

NSString *const YASLYASLGrammar = @"YASL";

@implementation YASLAssembler

- (NSString *) grammarIdentifier {
	return YASLYASLGrammar;
}

- (YASLTranslationUnit *) assembleSource:(NSString *)source {
	return [super assembleSource:source];
}

@end

@implementation YASLAssembler (Processor)

- (void) preProcessAssembly:(YASLAssembly *)a nodeStart:(YASLGrammarNode *)node {
	self.declarationScope.currentScope.placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeInCode] ofsettedByParent];
}

- (void) processAssembly:(YASLAssembly *)a nodeStart:(YASLGrammarNode *)node {
}

- (void) processAssembly:(YASLAssembly *)a nodeScriptDeclaration:(YASLGrammarNode *)node {
	YASLToken *token = [a pop];
	YASLTranslationUnit *unit = [YASLTranslationUnit unitInScope:self.declarationScope.currentScope withName:token.value];
	self.declarationScope.currentScope.name = [NSString stringWithFormat:@"unit:%@", token.value];
	[a push:unit];
}

- (void) processAssembly:(YASLAssembly *)a nodeExternalDeclarations:(YASLGrammarNode *)node {
	[self fetchArray:a];
	NSArray *declarations = [a pop];
	YASLTranslationUnit *unit = [a pop];
	for (YASLTranslationNode *declaration in [declarations reverseObjectEnumerator]) {
    [unit addSubNode:declaration];
	}
	[a push:unit];
	[a dropPopped];
}

@end
