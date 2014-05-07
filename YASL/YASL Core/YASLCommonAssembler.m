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

NSString *const kProcessorSelectorSignature = @"processAssembly:node%@:";

@interface YASLCommonAssembler () {
	NSMutableDictionary *selectors;
}

@end

@implementation YASLCommonAssembler

- (id)init {
	if (!(self = [super init]))
		return self;

	selectors = [NSMutableDictionary dictionary];
	return self;
}

- (void) linkProcessorSelectorWithName:(NSString *)ruleName {
	NSString *selectorName = [self makeProcessorSelectorForRuleName:ruleName];
	SEL selector = NSSelectorFromString(selectorName);
	if (selector) {
		if ([self respondsToSelector:selector])
			selectors[ruleName] = [NSValue valueWithPointer:selector];
	} else
		@throw [NSException exceptionWithName:@"YASLAssemblerLinkSelectorError" reason:[NSString stringWithFormat:@"Can't convert rule identifier \"%@\" to valid selector name (%@ selector not supported)", ruleName, selectorName] userInfo:nil];

}

- (NSString *) makeProcessorSelectorForRuleName:(NSString *)ruleName {
	ruleName = [ruleName stringByReplacingOccurrencesOfString:@"-" withString:@" "];
	ruleName = [ruleName capitalizedString];
	ruleName = [ruleName stringByReplacingOccurrencesOfString:@" " withString:@""];
	ruleName = [NSString stringWithFormat:kProcessorSelectorSignature, ruleName];
	return ruleName;
}

- (BOOL) performProcessorSelectorForNode:(YASLAssemblyNode *)assemblyNode andTokensAssembly:(YASLAssembly *)tokens {
	NSValue *selectorHolder;
	NSString *ruleName = assemblyNode.grammarNode.name;
	if (!(ruleName && (selectorHolder = selectors[assemblyNode.grammarNode.name])))
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

	BOOL result = [grammar match:tokensAssembly andAssembly:self];

	if (result) {
		if ([tokensAssembly notEmpty]) {
			return nil;
		}

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
	while ([node.assembly notEmpty])
		if (![self processNode:[node.assembly pop] withInAssembly:inAssembly outAssembly:outAssembly])
			return NO;

	YASLAssembly *tokensAssembly = node.tokensAssembly;

//	NSLog(@"\n%@ -> %@\n", node.node.name, [tokensAssembly stackToStringFrom:node.bottomToken till:node.topToken]);
	[tokensAssembly popState:node.tokensRange.location];
	id top = nil;
	YASLAssembly *t = [YASLAssembly new];
	int c = node.tokensRange.length;
	while ((c-- > 0) && (top = [tokensAssembly pop])) {
//		NSString *token = [[NSString stringWithFormat:@"\n(%@:%@\n)", node.node.name, top] descriptionTabbed:@"  "];
//		[t push:token];

		[t push:top];
	}
	while ([t notEmpty]) {
		[tokensAssembly push:[t pop]];
	}
//	NSLog(@"%@\n\n%@\n\n\n", tokensAssembly, t);

	if (!node.grammarNode.discard)
		@try {
			[self performProcessorSelectorForNode:node andTokensAssembly:tokensAssembly];
		}
		@catch (NSException *exception) {
 	    NSLog(@"Processing exception: %@", exception);
	  	return NO;
		}

	return YES;
}

@end
