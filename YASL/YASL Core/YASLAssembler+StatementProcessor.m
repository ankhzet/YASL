//
//  YASLAssembler+StatementProcessor.m
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembler+StatementProcessor.h"
#import "YASLCoreLangClasses.h"

@implementation YASLAssembler (StatementProcessor)

- (void) processAssembly:(YASLAssembly *)a nodeStatement:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	expression = [expression foldConstantExpression];

	[a push:expression];
}

- (void) preProcessAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLGrammarNode *)node {
	[self.declarationScope pushScope];
}

- (void) processAssembly:(YASLAssembly *)a nodeCompoundStatement:(YASLGrammarNode *)node {
	YASLTranslationExpression *expression = [a pop];
	expression = [expression foldConstantExpression];

	[a push:expression];

	[self.declarationScope popScope];
}

@end
