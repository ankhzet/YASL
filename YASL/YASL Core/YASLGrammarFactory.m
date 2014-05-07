//
//  YASLGrammarFactory.m
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarFactory.h"
#import "YASLGrammar.h"
#import "YASLBNFParser.h"

YASLUnifiedFileType const YASLUnifiedFileTypeGrammar = @"grammar";

@interface YASLGrammarFactory () {
	NSMutableDictionary *grammars;
}
@end

@implementation YASLGrammarFactory

- (id)init {
	if (!(self = [super init]))
		return self;

	grammars = [NSMutableDictionary dictionary];
	return self;
}

+ (instancetype) sharedFactory {
	static YASLGrammarFactory *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
	});
	return instance;
}

- (YASLGrammar *) getGrammar:(NSString *)grammarName {
	return grammars[grammarName];
}

+ (YASLGrammar *) loadGrammar:(NSString *)grammarName {
	YASLGrammarFactory *factory = [self sharedFactory];

	YASLGrammar *grammar = [factory getGrammar:grammarName];
	if (!grammar) {
		YASLGrammar *bnfGrammar = grammar = [factory loadBNF:grammarName];
		if (!bnfGrammar)
			bnfGrammar = (id)[NSNull null];

		[factory addGrammar:bnfGrammar withName:grammarName];
	} else
		if (![grammar isKindOfClass:[YASLGrammar class]]) {
			return nil;
		}

	return grammar;
}

- (YASLGrammar *) addGrammar:(YASLGrammar *)grammar withName:(NSString *)grammarName {
	YASLGrammar *old = [self getGrammar:grammarName];
	grammars[grammarName] = grammar;
	return old;
}

- (YASLGrammar *) loadBNF:(NSString *)grammarName {
	NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:grammarName withExtension:YASLUnifiedFileTypeGrammar];
	if (!sourceURL) {
		NSLog(@"Invalid resource name: \"%@\"", grammarName);
		return nil;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:[sourceURL path]]) {
		NSLog(@"Resource \"%@.%@\" doesn't exists", grammarName, YASLUnifiedFileTypeGrammar);
		return nil;
	}

	NSError *error = nil;
	NSString *source = [NSString stringWithContentsOfURL:sourceURL encoding:NSUTF8StringEncoding error:&error];
	if (!source) {
		NSLog(@"Failed to load \"%@.%@\": %@", grammarName, YASLUnifiedFileTypeGrammar, [error localizedDescription]);
		return nil;
	}

	YASLBNFParser *parser = [[YASLBNFParser alloc] initWithSource:source];
	YASLGrammar *grammarRoot = [parser buildGrammar];
	if (!grammarRoot) {
		NSException *e;
		while ((e = [parser popException])) {
			NSLog(@"Parse exception: %@", e);
		}

	}
	return grammarRoot;
}

@end
