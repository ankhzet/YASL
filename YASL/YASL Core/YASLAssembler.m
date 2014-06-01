//
//  YASLAssembler.m
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler.h"

#import "YASLCoreLangClasses.h"
#import "YASLCompiler.h"
#import "YASLCompiledUnit.h"
#import "YASLCodeSource.h"

NSString *const YASLYASLGrammar = @"YASL";

@implementation YASLAssembler

- (NSString *) grammarIdentifier {
	return YASLYASLGrammar;
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
	YASLDeclarationScope *unitScope = [self scope];
	NSArray *declarations = [unitScope localDeclarations];
	NSArray *typedefs = [[unitScope enumTypes] allObjects];
	[self.declarationScope popScope];
	if ([self scope] && ([self scope] != unitScope)) {
		for (YASLLocalDeclaration *declaration in declarations) {
			[[self scope] addLocalDeclaration:declaration];
			[unitScope removeDeclaration:declaration];
		}
		for (YASLDataType *type in typedefs) {
			[[self scope] registerType:type];
		}
	}
}

- (void) processAssembly:(YASLAssembly *)a nodeScriptDeclaration:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	YASLTranslationUnit *unit = [YASLTranslationUnit unitInScope:[self scope] withName:token.value];
	[self scope].name = [NSString stringWithFormat:@"unit:%@", token.value];
	[a push:unit];
}

- (void) processAssembly:(YASLAssembly *)a nodeUseScript:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	NSString *usesIdentifier = token.value;
	YASLCodeSource *source = [YASLCodeSource codeSourceFromResource:usesIdentifier withExtension:@"yasl"];
	if (!source)
		[self raiseError:@"Script \"%@\" not found", usesIdentifier];

	YASLCompiledUnit *usesUnit = [self.parentCompiler compileScript:source];
	if (usesUnit.stage != YASLUnitCompilationStageCompiled)
		[self raiseError:@"Failed to use \"%@\" script", usesIdentifier];

	[[self scope].parentScope includeDeclarations:usesUnit.declarations];
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
