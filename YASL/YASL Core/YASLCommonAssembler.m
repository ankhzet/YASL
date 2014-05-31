//
//  YASLAssembler.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCommonAssembler.h"
#import "YASLAssemblyNode.h"
#import "YASLGrammarNode.h"
#import "YASLGrammar.h"
#import "YASLGrammarFactory.h"
#import "YASLTokenizer.h"
#import "YASLToken.h"
#import "NSObject+TabbedDescription.h"
#import "YASLTypedNode.h"
#import "YASLTranslationNode.h"
#import "YASLNonfatalException.h"

NSString *const kProcessorSelectorSignature = @"processAssembly:node%@:";
NSString *const kPreProcessorSelectorSignature = @"preProcessAssembly:node%@:";

@interface YASLCommonAssembler () {
	NSMutableDictionary *processSelectors, *preprocessSelectors;
}

@end

@implementation YASLCommonAssembler

- (id)init {
	if (!(self = [super init]))
		return self;

	processSelectors = [NSMutableDictionary dictionary];
	preprocessSelectors = [NSMutableDictionary dictionary];
	return self;
}

@end

@implementation YASLCommonAssembler (Selectors)

- (void) linkProcessorSelectorWithName:(NSString *)ruleName {
	NSString *preSelectorName = [self makePre:YES processorSelectorForRuleName:ruleName];
	NSString *selectorName = [self makePre:NO processorSelectorForRuleName:ruleName];
	SEL preSelector = NSSelectorFromString(preSelectorName);
	SEL selector = NSSelectorFromString(selectorName);
	if (selector) {
		if ([self respondsToSelector:selector])
			processSelectors[ruleName] = [NSValue valueWithPointer:selector];
	} else
		@throw [NSException exceptionWithName:@"YASLAssemblerLinkSelectorError" reason:[NSString stringWithFormat:@"Can't convert rule identifier \"%@\" to valid selector name (%@ selector not supported)", ruleName, selectorName] userInfo:nil];

	if (preSelector) {
		if ([self respondsToSelector:preSelector])
			preprocessSelectors[ruleName] = [NSValue valueWithPointer:preSelector];
	} else
		@throw [NSException exceptionWithName:@"YASLAssemblerLinkSelectorError" reason:[NSString stringWithFormat:@"Can't convert rule identifier \"%@\" to valid selector name (%@ selector not supported)", ruleName, preSelectorName] userInfo:nil];

}

- (NSString *) makePre:(BOOL)pre processorSelectorForRuleName:(NSString *)ruleName {
	ruleName = [ruleName stringByReplacingOccurrencesOfString:@"-" withString:@" "];
	ruleName = [ruleName capitalizedString];
	ruleName = [ruleName stringByReplacingOccurrencesOfString:@" " withString:@""];
	ruleName = [NSString stringWithFormat:pre ? kPreProcessorSelectorSignature : kProcessorSelectorSignature, ruleName];
	return ruleName;
}

- (BOOL) performPre:(BOOL)pre processorSelectorForNode:(YASLAssemblyNode *)assemblyNode andTokensAssembly:(YASLAssembly *)tokens {
	NSValue *selectorHolder;
	NSString *ruleName = assemblyNode.grammarNode.name;
	if (!(ruleName && (selectorHolder = ((!pre) ? processSelectors : preprocessSelectors)[assemblyNode.grammarNode.name])))
		return NO;

	SEL selector = [selectorHolder pointerValue];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self performSelector:selector withObject:tokens withObject:assemblyNode];
	if ([[tokens top] isKindOfClass:[YASLTranslationNode class]]) {
		((YASLTranslationNode *)[tokens top]).sourceLine = assemblyNode.sourceLine;
	}
#pragma clang diagnostic pop

	return YES;
}

@end

@implementation YASLCommonAssembler (AssemblingAndProcessing)

- (NSString *) grammarIdentifier {
	NSAssert(0, @"-[YASLCommonAssembler grammarIdentifier] should be overriden in subclass");
	return nil;
}

- (id) assembleFile:(NSString *)fileName {
	NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@""];
	if (!sourceURL) {
		NSLog(@"Invalid resource name: \"%@\"", fileName);
		return nil;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:[sourceURL path]]) {
		NSLog(@"Resource \"%@\" doesn't exists", fileName);
		return nil;
	}

	NSError *error = nil;
	NSString *source = [NSString stringWithContentsOfURL:sourceURL encoding:NSUTF8StringEncoding error:&error];
	if (!source) {
		NSLog(@"Failed to load \"%@\": %@", fileName, [error localizedDescription]);
		return nil;
	}
	
	return [self assembleSource:source];
}

- (id) assembleSource:(NSString *)source {
	id result = nil;
	@try {
		YASLAbstractTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];
		[tokenizer tokenizeAll];

		if (![tokenizer hasTokens])
			[self raiseError:@"Failed to tokenize YASL source"];

		YASLGrammar *grammarRoot = [YASLGrammarFactory loadGrammar:[self grammarIdentifier]];
		if (!grammarRoot)
			[self raiseError:@"Failed to load \"%@\" BNF grammar",[self grammarIdentifier]];


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

- (YASLAssembly *) assembleSource:(YASLAbstractTokenizer *)tokenized withGrammar:(YASLGrammar *)grammar {
	YASLAssembly *tokensAssembly = [YASLAssembly assembleTokens:tokenized];
	if (![tokensAssembly notEmpty])
		return NO;

	for (YASLGrammarNode *node in [grammar.allRules allValues]) {
		[self linkProcessorSelectorWithName:node.name];
	}

	[self noDiscards];
	[self popExceptionStack];
	BOOL result = [grammar match:tokensAssembly andAssembly:self];

	if (result && ![tokensAssembly notEmpty]) {
		[self popExceptionStack];
		[self foldDiscards];
		YASLAssembly *outAssembly = [YASLAssembly new];
		[outAssembly discardAs:self];
		[self noDiscards];

		if (!([self processInAssembly:tokensAssembly toOutAssembly:outAssembly] && [outAssembly notEmpty]))
			[self raiseError:@"Source assemble failed"];

		[self popExceptionStack];
		return outAssembly;
	} else {
		YASLNonfatalException *e = [self popException], *top = e;
		if (top) {
//			NSLog(@"Stack trace:\n%@\n", [top callStackSymbols]);
		}
		do {
			NSLog(@"Syntax check exception: %@", e);
		} while ((e = [self popException]));

		if (top) {
			@throw top;
		}
	}

	return nil;
}

#pragma mark - Processing assembly

- (BOOL) processInAssembly:(YASLAssembly *)inAssembly toOutAssembly:(YASLAssembly *)outAssembly {
	if (![self notEmpty])
		return NO;

	YASLAssemblyNode *node = [self pop];
	return [self processNode:node withInAssembly:inAssembly outAssembly:outAssembly];
}

- (BOOL) processNode:(YASLAssemblyNode *)node withInAssembly:(YASLAssembly *)inAssembly outAssembly:(YASLAssembly *)outAssembly {
	[self performPre:YES processorSelectorForNode:node andTokensAssembly:outAssembly];

	id marker = [outAssembly top];
	while ([node.assembly notEmpty])
		if (![self processNode:[node.assembly pop] withInAssembly:inAssembly outAssembly:outAssembly])
			return NO;

	[inAssembly popState:node.tokensRange.location];
	id top = [inAssembly top];
	node.sourceLine = (top && [top isKindOfClass:[YASLToken class]]) ? ((YASLToken *)top).line : 0;

	YASLAssembly *discardAssembly = [YASLAssembly new];
	NSUInteger c = node.tokensRange.length;
	while ((c-- > 0) && (top = [inAssembly pop])) {
		if (![outAssembly mustDiscard:top]) {
			[outAssembly push:top];
			[discardAssembly push:top];
		}
	}

	if ([node.grammarNode isKindOfClass:[YASLTypedNode class]]) {
		YASLToken *token = [outAssembly pop];
		if (!node.grammarNode.discard) {
			YASLToken *copy = [token copy];
			[outAssembly push:copy];
			[outAssembly discardPopped:discardAssembly];
		} else
			[outAssembly alwaysDiscard:token inGlobalScope:NO];
	} else {
		BOOL processed = NO;
		if (node.grammarNode.discard) {
			for (id obj in [discardAssembly enumerator:NO])
				[outAssembly alwaysDiscard:obj inGlobalScope:YES];
		}
		@try {
			outAssembly.chunkMarker = marker;
			processed = [self performPre:NO processorSelectorForNode:node andTokensAssembly:outAssembly];
		}
		@catch (YASLNonfatalException *exception) {
			YASLToken *breakToken = [inAssembly pushBack];
			[inAssembly pop];
			exception.atLine = breakToken.line;
			exception.atCollumn = breakToken.collumn;
			NSLog(@"In node \"%@\", processing exception: %@\nOut assembly:\n%@\n", node.grammarNode.name, exception, outAssembly);
			return NO;
		}
		@finally {
			[outAssembly dropPopped];
			[outAssembly discardPopped:discardAssembly];
//				if (processed)
//					NSLog(@"process (%@): \n%@\n\n", node.grammarNode.name, outAssembly);

		}

//		} else {
//			NSLog(@"discard %@", node);
//		}
	}

	return YES;
}

@end

@implementation YASLCommonAssembler (CommonProcessors)


- (void) fetchArray:(YASLAssembly *)assembly {
	NSMutableArray *elements = [NSMutableArray array];
	id top;
	while ((top = [assembly popTillChunkMarker])) {
		[elements addObject:top];
	}
	[assembly push:elements];
}

- (YASLAssembly *) reverseFetch:(YASLAssembly *)assembly {
	[self fetchArray:assembly];
	NSArray *fetched = [assembly pop];
	return [[YASLAssembly alloc] initWithArray:fetched];
}

- (void) pushInt:(YASLAssembly *)assembly {
	[assembly push:@([(YASLToken *)[assembly popTillChunkMarker] asInteger])];
}

- (void) pushFloat:(YASLAssembly *)assembly {
	[assembly push:@([(YASLToken *)[assembly popTillChunkMarker] asFloat])];
}

- (void) pushBool:(YASLAssembly *)assembly {
	[assembly push:@([(YASLToken *)[assembly popTillChunkMarker] asBool])];
}

- (void) pushString:(YASLAssembly *)assembly {
	[assembly push:[(YASLToken *)[assembly popTillChunkMarker] value]];
}



@end
