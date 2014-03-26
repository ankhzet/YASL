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

- (YASLDeclarationScope *) scope {
	return self.declarationScope.currentScope;
}

@end

@implementation YASLAssembler (Processor)

- (void) preProcessAssembly:(YASLAssembly *)a nodeStart:(YASLAssemblyNode *)node {
	[self scope].placementManager = [[YASLDeclarationPlacement placementWithType:YASLDeclarationPlacementTypeInCode] ofsettedByParent];
	[self.declarationScope pushScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeStart:(YASLAssemblyNode *)node {
	YASLTranslationUnit *unit = [a top];
	[self scope].name = unit ? unit.name : @"<anonymuous unit>";
	YASLLocalDeclaration *mainMethod = [[self scope] localDeclarationByIdentifier:@"main"];
	[self.declarationScope popScope];
	if (mainMethod) {
		[[self scope] addLocalDeclaration:mainMethod];
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeScriptDeclaration:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	YASLTranslationUnit *unit = [YASLTranslationUnit unitInScope:[self scope] withName:token.value];
	[self scope].name = [NSString stringWithFormat:@"unit:%@", token.value];
	[a push:unit];
}

- (void) processAssembly:(YASLAssembly *)a nodeExternalDeclarations:(YASLAssemblyNode *)node {
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
