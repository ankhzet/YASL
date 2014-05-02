//
//  YASLBNFParserSpec.m
//  YASL
//  Spec for YASLBNFParser
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBNFParser.h"
#import "YASLGrammarNode.h"
#import "YASLSequenceNode.h"
#import "YASLAssembly.h"
#import "YASLCommonAssembler.h"
#import "YASLGrammarFactory.h"
#import "YASLAssembler.h"

@interface BNFTest : YASLCommonAssembler

@end
@implementation BNFTest

- (void) processAssembly:(YASLAssembly *)a nodeRuleId:(YASLGrammarNode *)node {
	YASLToken *token = [a pop];
	[a push:@{token.value: token}];
}

- (void) processAssembly:(YASLAssembly *)a nodeTerm:(YASLGrammarNode *)node {
	id token = [a pop];
	token = nil;
}

@end

SPEC_BEGIN(YASLBNFParserSpec)

describe(@"YASLBNFParser", ^{
	NSString *grammarSrc = @"\
	@start = start-rule rule*;\
	start-rule = '@' rule;\
	rule = Identifier '=' rule-body ';';\
	rule-body = alternation;\
	alternation = sequence ('|' sequence)*;\
	sequence = repetition+;\
	repetition = basic ('?' | '+' | '*')?;\
	basic = term | '(' alternation ')';\
	term = (rule-id | String) discard;\
	rule-id = Identifier;\
	discard = '!'?;\
	";

	NSString *grammarSrc2 = @"\
	@begin = b0 r0*;\
	b0 = '@' r0;\
	r0 = Identifier '=' rbody ';';\
	rbody = r1;\
	r1 = r2 ('|' r2)*;\
	r2 = r3+;\
	r3 = r4 ('?' | '+' | '*')?;\
	r4 = r5 | '(' r1 ')';\
	r5 = itent | String;\
	ident = Identifier a0;\
	a0 = '!'?;\
	";


	it(@"should properly initialize", ^{
		YASLBNFParser *instance = [YASLBNFParser new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLBNFParser class]];
	});

	it(@"should parse it's own grammar", ^{

		YASLBNFParser *parser = [[YASLBNFParser alloc] initWithSource:grammarSrc];

		YASLGrammarNode *grammar = [parser buildGrammar];
		[[grammar shouldNot] beNil];
		[[grammar should] beKindOfClass:[YASLSequenceNode class]];
		[[((YASLSequenceNode *)grammar).subnodes should] haveCountOf:2];
	});

	it(@"should properly parse & process grammars with grammar factory", ^{
		YASLGrammarNode *grammarRoot = [YASLGrammarFactory loadGrammar:@"BNF"];

		[[grammarRoot shouldNot] beNil];
		[[grammarRoot should] beKindOfClass:[YASLGrammarNode class]];
		[[grammarRoot.name should] equal:@"start"];

		YASLGrammarNode *grammarRoot2 = [YASLGrammarFactory loadGrammar:@"BNF"];

		[[grammarRoot2 should] beIdenticalTo:grammarRoot];

		YASLBNFParser *sourceParser = [[YASLBNFParser alloc] initWithSource:grammarSrc2];

		BNFTest *processor = [BNFTest new];
		BOOL state = [processor assembleSource:sourceParser withGrammar:grammarRoot];

		[[theValue(state) should] beYes];

		YASLAssembly *result = [processor processAssembly];
		[[result shouldNot] beNil];
		
	});

	it(@"should properly load YASL grammar", ^{
		YASLGrammarNode *grammarRoot = [YASLGrammarFactory loadGrammar:@"YASL"];

		[[grammarRoot shouldNot] beNil];
		[[grammarRoot should] beKindOfClass:[YASLGrammarNode class]];
		[[grammarRoot.name should] equal:@"start"];

	});

});

SPEC_END
