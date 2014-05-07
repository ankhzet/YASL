//
//  YASLBNFParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBNFParser.h"
#import "YASLAssembly.h"
#import "YASLBNFParserException.h"

#import "YASLGrammarNode.h"
#import "YASLAlternationNode.h"
#import "YASLSequenceNode.h"
#import "YASLRepetitionNode.h"
#import "YASLTypedNode.h"
#import "YASLLiteralNode.h"
#import "YASLIdentifierNode.h"
#import "YASLAnyNode.h"
#import "YASLGrammar.h"

static id kBoolYes = @"kBoolYes";
static id kBoolNo = nil;
static id kRuleIdentifiers = @"kRuleIdentifiers";

static id kRootTerm = @"@";
static id kDiscardTerm = @"!";
static id kAssignTerm = @"=";
static id kSemiTerm = @";";
static id kOrTerm = @"|";
static id kLBraceTerm = @"(";
static id kRBraceTerm = @")";

@interface YASLBNFParser () {
	NSDictionary *builtInKinds;
}

@end

@implementation YASLBNFParser

- (id)init {
	if (!(self = [super init]))
		return self;

	builtInKinds =
	@{
		@"Identifier": [[YASLTypedNode alloc] initWithType:YASLTokenKindIdentifier],
		@"Int"       : [[YASLTypedNode alloc] initWithType:YASLTokenKindInteger],
		@"Float"     : [[YASLTypedNode alloc] initWithType:YASLTokenKindFloat],
		@"String"    : [[YASLTypedNode alloc] initWithType:YASLTokenKindString],
		@"Bool"      : [[YASLTypedNode alloc] initWithType:YASLTokenKindBool],
		@"Symbol"    : [[YASLTypedNode alloc] initWithType:YASLTokenKindSymbol],
		@"Any"       : [YASLAnyNode new],
		};

	for (NSString *name in [builtInKinds allKeys]) {
    YASLGrammarNode *node = builtInKinds[name];
		node.name = name;
	}

	return self;
}

- (YASLGrammar *) buildGrammar {
	YASLAssembly *assembly = [YASLAssembly new];

	[self tokenizeAll];
	if ([self trySelector:@selector(_start:) andAssembly:assembly])
		return [assembly pop];

	return nil;
}

- (id) _start:(YASLAssembly *)assembly {
	[self check:kRootTerm];
	NSString *rootRule = [self kCheck:YASLTokenKindIdentifier];
	id parsed = [self _rules:assembly];
	if (!parsed)
		return parsed;

	//TODO: process all rules
	NSDictionary *rules = [assembly pop];
	YASLGrammarNode *root = rules[rootRule];
	if (!root)
		[self raiseError:@"Failed to parse root rule \"%@\"", rootRule];


	__block BOOL link = YES;
	while (link) {
		link = NO;
		for (YASLGrammarNode *node in [rules allValues]) {
			[node walkTreeWithBlock:^BOOL(NSDictionary *rules, YASLGrammarNode *node) {
				if ([node isKindOfClass:[YASLIdentifierNode class]]) {
					YASLIdentifierNode *identifierNode = (id)node;
					if (identifierNode.link)
						return YES;

					NSString *identifier = identifierNode.identifier;
					YASLGrammarNode *builtIn = builtInKinds[identifier];

					YASLGrammarNode *linked;
					if (builtIn) {
						NSLog(@"Built-in rule \"%@\"", identifier);
						linked = builtIn;
					} else
						linked = rules[identifier];

					if (!linked)
						[self raiseError:@"Failed to parse grammar, rule \"%@\" undefined", identifier];

					if (linked) {
						identifierNode.link = linked;
//						NSLog(@"link %@ -> %@", identifier, linked);
						link = YES;
						return NO;
					}
				}
				return YES;
			} andUserData:rules];
		}
	}

	for (NSString *ruleName in [rules allKeys]) {
		YASLGrammarNode *rootNode = (id)rules[ruleName];
    rootNode.name = ruleName;
	}

	YASLGrammar *grammar = [YASLGrammar new];
	grammar.name = root.name;
	grammar.rootNode = root;
	grammar.allRules = rules;

	[assembly push:grammar];
	return kBoolYes;
}

- (id) _rules:(YASLAssembly *)assembly {
	NSMutableDictionary *rules = [NSMutableDictionary dictionary];
	while ([self tokenKind] == YASLTokenKindIdentifier) {
		BOOL parsed = [self trySelector:@selector(_rule:) andAssembly:assembly];
		if (!parsed)
			break;

		id rule = [assembly pop];
		[rules addEntriesFromDictionary:rule];
	}

	[assembly push:rules];
	return kBoolYes;
}

- (id) _rule:(YASLAssembly *)assembly {
	NSString *rule = [self kCheck:YASLTokenKindIdentifier];
	[self nextCheck:kAssignTerm];
	id parsed = [self _ruleBody:assembly];
	if (!parsed)
		return parsed;

	id body = [assembly pop];
	[assembly push:@{rule: body}];

	[self check:kSemiTerm];
	return kBoolYes;
}

- (id) _ruleBody:(YASLAssembly *)assembly {
	return [self _alternation:assembly];
}

- (id) _alternation:(YASLAssembly *)assembly {
	if (![self trySelector:@selector(_sequence:) andAssembly:assembly])
		return kBoolNo;

	NSMutableArray *alts = [NSMutableArray array];
	while ([[self tokenValue] isEqualToString:kOrTerm]) {
		[self nextToken];
		if (![self trySelector:@selector(_sequence:) andAssembly:assembly])
			return kBoolNo;

		YASLGrammarNode *node = [assembly pop];
		[alts addObject:node];
	}

	if ([alts count]) {
		YASLAlternationNode *alternation = [YASLAlternationNode new];
		[alternation addSubNode:[assembly pop]];

		for (YASLGrammarNode *node in alts) {
			[alternation addSubNode:node];
		}
		[assembly push:alternation];
	}
	
	return kBoolYes;
}

- (id) _sequence:(YASLAssembly *)assembly {
	if (![self trySelector:@selector(_repetition:) andAssembly:assembly])
		return kBoolNo;

	NSMutableArray *seq = [NSMutableArray array];

	while ([self trySelector:@selector(_repetition:) andAssembly:assembly]) {
		[seq addObject:[assembly pop]];
	}

	if ([seq count]) {
		YASLSequenceNode *sequence = [YASLSequenceNode new];
		[sequence addSubNode:[assembly pop]];

		for (YASLGrammarNode *node in seq) {
			[sequence addSubNode:node];
		}
		[assembly push:sequence];
	}
	
	return kBoolYes;
}

- (id) _repetition:(YASLAssembly *)assembly {
	if (![self trySelector:@selector(_basic:) andAssembly:assembly])
		return kBoolNo;

	if ([self tokenKind] == YASLTokenKindSymbol) {
		YASLRepetitionSpecifier specifier = [YASLRepetitionNode parseSpecifier:[self tokenValue]];
		if (specifier != YASLRepetitionSpecifierNone) {
			YASLRepetitionNode *repetition = [YASLRepetitionNode new];
			repetition.linked = [assembly pop];
			repetition.specifier = specifier;
			[assembly push:repetition];
			[self nextToken];
		}
	}

	return kBoolYes;
}

- (id) _basic:(YASLAssembly *)assembly {
	if (([self tokenKind] == YASLTokenKindSymbol) && [[self tokenValue] isEqualToString:kLBraceTerm]) {
		[self check:kLBraceTerm];

		id parsed = [self _alternation:assembly];
		if (!parsed)
			return parsed;

		[self check:kRBraceTerm];
		return kBoolYes;
	} else
		return [self _term:assembly];
}

- (id) _term:(YASLAssembly *)assembly {
	BOOL parsed = [self trySelector:@selector(_identifier:) andAssembly:assembly] || [self trySelector:@selector(_literal:) andAssembly:assembly];
	return parsed ? kBoolYes : kBoolNo;
}

- (id) _identifier:(YASLAssembly *)assembly {
	NSString *identifierValue = [self kCheck:YASLTokenKindIdentifier];
	[self nextToken];

	YASLIdentifierNode *identifier = [YASLIdentifierNode new];
	identifier.identifier = identifierValue;

	if (!assembly.userData[kRuleIdentifiers]) {
		assembly.userData[kRuleIdentifiers] = [@{} mutableCopy];
	}
	assembly.userData[kRuleIdentifiers][identifierValue] = identifier;

	[assembly push:identifier];
	
	return kBoolYes;
}

- (id) _literal:(YASLAssembly *)assembly {
	NSString *literalValue = [self kCheck:YASLTokenKindString];
	[self nextToken];

	if (![self trySelector:@selector(_discard:) andAssembly:assembly])
		return kBoolNo;

	NSNumber *discard = [assembly pop];

	YASLLiteralNode *literal = [YASLLiteralNode new];
	literal.literal = literalValue;
	literal.discard = [discard boolValue];
	[assembly push:literal];

	return kBoolYes;
}

- (id) _discard:(YASLAssembly *)assembly {
	BOOL discard = ([self tokenKind] == YASLTokenKindSymbol) && [[self tokenValue] isEqualToString:kDiscardTerm];
	if (discard) {
		[self nextToken];
	}

	[assembly push:@(discard)];

	return kBoolYes;
}



#pragma mark - Utils

- (BOOL) trySelector:(SEL)selector andAssembly:(YASLAssembly *)assembly {
	NSUInteger oldCurrentToken = [self currentToken];
	NSUInteger oldAssemblyState = [assembly pushState];
	NSUInteger oldExceptionStackState = [self pushExceptionStackState];
	@try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id result = [self performSelector:selector withObject:assembly];
#pragma clang diagnostic pop

		if (result != kBoolNo) {
//			NSLog(@"parsed [%@]", [assembly top]);
			[self popExceptionStackState:oldExceptionStackState];
			return YES;
		}
	}
	@catch (NSException *exception) {
	}

	[self setCurrentToken:oldCurrentToken];
	[assembly popState:oldAssemblyState];
	return NO;
}

- (NSString *) getBetween:(NSString *)token1 and:(NSString *)token2 {
	NSString *token = [self check:token1];
	[self nextToken];
	[self check:token2];
	return token;
}

- (NSString *) check:(NSString *)token {
	if ([[self tokenValue] isEqualToString:token])
		return [self nextToken].value;

	[self raiseError:@"Expected \"%@\", but \"%@\" found", token, [self tokenValue]];
	return nil;
}

- (NSString *) nextCheck:(NSString *)token {
	[self nextToken];
	return [self check:token];
}

- (NSString *) kCheck:(YASLTokenKind)kind {
	if ([self tokenKind] == kind) {
		return [self tokenValue];
	}

	[self raiseError:@"Expected token of kind \"%@\", but \"%@(%@)\" found", [YASLToken tokenKindName:kind], [YASLToken tokenKindName:[self tokenKind]], [self tokenValue]];
	return nil;
}

- (NSString *) kCheckAndGetNext:(YASLTokenKind)kind {
	[self kCheck:kind];
	return [self nextToken].value;
}

- (NSException *) prepareExceptionObject:(NSString *)msg {
	return [YASLBNFParserException exceptionAtLine:self.token.line andCollumn:self.token.collumn withMsg:msg];
}

@end

/*

 @start = start-rule rule*;
 start-rule = '@' rule;
 rule = identifier '=' rule-body ';';
 
 rule-body = alternation;

 alternation = sequence ('|' sequence)*;
 sequence = repetition+;
 repetition = basic ('?' | '+' | '*')?;
 basic = term | '(' alternation ')';

 term = Identifier | literal;
 literal = String discard;
 discard = '!'!;

 */
