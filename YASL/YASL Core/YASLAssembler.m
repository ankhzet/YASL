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

- (YASLTranslationUnit *) assembleSource:(NSString *)source {
	YASLTranslationUnit *result = nil;
	@try {
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];
		[tokenizer tokenizeAll];

		if (![tokenizer hasTokens])
			[self raiseError:@"Failed to tokenize YASL source"];

		YASLGrammar *grammarRoot = [YASLGrammarFactory loadGrammar:YASLYASLGrammar];
		if (!grammarRoot)
			[self raiseError:@"Failed to load YASL BNF grammar"];


		YASLAssembly *outAssembly = [self assembleSource:tokenizer withGrammar:grammarRoot];

		if (!(outAssembly && [outAssembly notEmpty]))
			[self raiseError:@"Source assemble failed"];

		result = [outAssembly pop];
	}
	@catch (YASLNonfatalException *exception) {
		NSLog(@"Assemble process halted: %@", exception);
	}
	@finally {
		return result;
	}
}

@end

@implementation YASLAssembler (Processor)

- (void) processAssembly:(YASLAssembly *)a nodeScriptDeclaration:(YASLGrammarNode *)node {
	YASLToken *token = [a pop];
	YASLTranslationUnit *unit = [YASLTranslationUnit new];
	unit.name = token.value;
	[a push:unit];
}

@end
