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
#import "YASLTokenizer.h"
#import "YASLToken.h"
#import "NSObject+TabbedDescription.h"
#import "YASLTypedNode.h"

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
#pragma clang diagnostic pop

	return YES;
}

@end

@implementation YASLCommonAssembler (AssemblingAndProcessing)

- (YASLAssembly *) assembleSource:(YASLTokenizer *)tokenized withGrammar:(YASLGrammar *)grammar {
	YASLAssembly *tokensAssembly = [YASLAssembly assembleTokens:tokenized];
	if (![tokensAssembly notEmpty])
		return NO;

	for (YASLGrammarNode *node in [grammar.allRules allValues]) {
		[self linkProcessorSelectorWithName:node.name];
	}

	[self noDiscards];
	[self popExceptionStackState:0];
	BOOL result = [grammar match:tokensAssembly andAssembly:self];

	if (result) {
		if ([tokensAssembly notEmpty]) {
			YASLNonfatalException *e = [self popException];
			do {
				NSLog(@"Syntax check exception: %@", e);
			} while ((e = [self popException]));
			return nil;
		}

		[self foldDiscards];
		YASLAssembly *outAssembly = [YASLAssembly new];
		[outAssembly discardAs:self];
		[outAssembly setGlobalDiscards:YES];
		[self noDiscards];

		if (!([self processInAssembly:tokensAssembly toOutAssembly:outAssembly] && [outAssembly notEmpty]))
			[self raiseError:@"Source assemble failed"];

		return outAssembly;
	} else
		[self reRaise];

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
	YASLAssembly *discardAssembly = [YASLAssembly new];
	NSUInteger c = node.tokensRange.length;
	id top = nil;
	while ((c-- > 0) && (top = [inAssembly pop])) {
		if (![outAssembly mustDiscard:top]) {
			[outAssembly push:top];
			[discardAssembly push:top];
		}
	}

	if ([node.grammarNode isKindOfClass:[YASLTypedNode class]]) {
		YASLToken *token = [outAssembly pop];
		[outAssembly push:[YASLToken token:token.value withKind:token.kind]];
		[outAssembly discardPopped:discardAssembly];
	} else {
		BOOL processed = NO;
		if (!node.grammarNode.discard) {
			@try {
				outAssembly.chunkMarker = marker;
				processed = [self performPre:NO processorSelectorForNode:node andTokensAssembly:outAssembly];
			}
			@catch (NSException *exception) {
				NSLog(@"Processing exception: %@", exception);
				return NO;
			}
			@finally {
				[outAssembly dropPopped];
				[outAssembly discardPopped:discardAssembly];
//				if (processed)
//					NSLog(@"process (%@): \n%@\n\n", node.grammarNode.name, outAssembly);

			}
		}
	}

	return YES;
}

@end
