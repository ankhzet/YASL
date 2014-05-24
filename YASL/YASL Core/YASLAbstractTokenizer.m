//
//  YASLTokenizer.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAbstractTokenizer.h"
#import "YASLNonfatalException.h"

#import "YASLTokenParser.h"

@interface YASLAbstractTokenizer () {
	NSUInteger pos, len;
	NSCharacterSet *whitespaces, *newlines;
	NSArray *tokenParsers, *fetched;
	NSUInteger currentToken;

	NSString *kTrue, *kFalse;
	NSMutableArray *exceptionsStack;
}

@end

@implementation YASLAbstractTokenizer

#pragma mark - Instantiation

/*! Designated initializer. */
- (id)init {
	if (!(self = [super init]))
		return self;

	exceptionsStack = [NSMutableArray array];
	whitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	newlines = [NSCharacterSet newlineCharacterSet];

	tokenParsers = [self tokenParsers];

	kTrue = @"true";
	kFalse = @"false";
	self.source = nil;
	return self;
}

- (NSArray *) tokenParsers {
	return @[];
}

- (id) initWithSource:(NSString *)source {
	if (!(self = [self init]))
		return self;

	self.source = source;
	return self;
}

+ (instancetype) loadFromFile:(NSString *)fileName {
	NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:fileName withExtension:[self type]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
		NSLog(@"Can't find resource \"%@\"", fileName);
		return nil;
	}

	NSError *error = nil;
	NSString *contents = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:&error];
	if (!contents) {
		NSLog(@"Can't load resource \"%@\": %@", fileName, [error localizedDescription]);
		return nil;
	}

	return [[self alloc] initWithSource:contents];
}

#pragma mark - Implementation

+ (NSString *) type {
	return @"grammar";
}

- (void) setSource:(NSString *)source {
	if ([_source isEqualToString:source])
		return;

	_source = source;
	len = [source length];

	[self fromStart];
}

- (void) fromStart {
	pos = 0;
	fetched = nil;
	[self firstToken];
	[self skipWhitespace];
}

- (unichar) current {
	NSUInteger safe = MIN(MAX(0, pos), len - 1);
	return (safe == pos) ? [_source characterAtIndex:safe] : 0;
}

- (unichar) charAt:(NSUInteger)position {
	NSUInteger safe = MIN(MAX(0, position), len - 1);
	return (safe == position) ? [_source characterAtIndex:safe] : 0;
}

- (BOOL) eof {
	return pos >= len;
}

- (void) skipWhitespace {
	while ((![self eof]) && [whitespaces characterIsMember:[self current]])
		pos++;
}

- (YASLToken *) parseToken {

	NSString *tokenValue;
	NSUInteger tokenPos;
	YASLTokenKind tokenKind;

	parseCycle:
	tokenValue = nil;
	tokenKind = YASLTokenKindEOF;
	tokenPos = pos;

	unichar c = [self current];
	if (!c)
		return nil;

	for (int i = 0; i < [tokenParsers count]; i++) {
		YASLTokenParser *parser = tokenParsers[i];
		if ([parser handles:c]) {
			YASLTokenParseData data = { .parsePos = pos, .kind = YASLTokenKindEOF, };

			if ([parser parseWithUserData:&data andBlock:^unichar(YASLTokenParser *parser, YASLTokenParseData *parseData) {
				return [self charAt:parseData->parsePos];
			}]) {
				NSUInteger start = data.startFromPos, end = data.endAtPos;
				tokenValue = [_source substringWithRange:NSMakeRange(start, end - start)];
				tokenKind = data.kind;
				pos = data.parsePos;

				switch (tokenKind) {
					case YASLTokenKindComment: {
						[self skipWhitespace];
						goto parseCycle;
					}

					case YASLTokenKindIdentifier: {
						NSString *lo = [tokenValue lowercaseString];
						if ([lo isEqualToString:kTrue] || [lo isEqualToString:kFalse]) {
							tokenKind = YASLTokenKindBool;
						}
						break;
					}
					default:;
				}
				break;
			}
		}
	}

	if (tokenValue)
		[self skipWhitespace];

	YASLToken *token = [YASLToken token:tokenValue withKind:tokenKind];
	[self token:token resolvePosition:tokenPos];

	return token;
}

- (void) token:(YASLToken *)token resolvePosition:(NSUInteger)linearPos {
	NSUInteger scanPos = 0;
	NSRange till = NSMakeRange(scanPos, linearPos);
	NSRange found;
	int line = 0;
	do {
		line++;
		found = [_source rangeOfCharacterFromSet:newlines options:NSLiteralSearch range:till];
		if (found.location == NSNotFound) {
			break;
		}

		scanPos = found.location + found.length;
		till.location = scanPos;
		till.length = linearPos - scanPos;
	} while (true);

	token.line = line;
	token.collumn = linearPos - scanPos;
}

- (NSArray *) tokenizeAll {
	[self fromStart];
	NSMutableArray *fetch = [NSMutableArray arrayWithCapacity:len - pos];
	YASLToken *prevToken, *token;
	while (![self eof]) {
		prevToken = token;
		token = [self parseToken];
		NSUInteger oldPos = pos;
		if (token) {
			[fetch addObject:token];
		} else {
			if ([self eof]) {
				break;
			} else
				@throw [YASLNonfatalException exceptionAtLine:prevToken.line andCollumn:prevToken.collumn withMsg:@"Can't parse source at offset %u", oldPos];
		}
	}

	fetched = fetch;
	[self firstToken];
	return fetched;
}

- (NSArray *) toValueArray:(NSArray *)tokens {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[tokens count]];
	for (YASLToken *token in tokens) {
    [result addObject:token.value];
	}
	return result;
}

- (NSArray *) allTokens {
	if (!fetched) {
		[self tokenizeAll];
	}
	return fetched;
}

- (void) firstToken {
	_token = nil;
	_tokenValue = nil;
	_tokenKind = YASLTokenKindEOF;
	[self setCurrentToken:0];
}

- (NSUInteger) currentToken {
	return currentToken;
}

- (void) setCurrentToken:(NSUInteger)tokenIndex {
	currentToken = tokenIndex;
	_token = [self hasTokens] ? fetched[currentToken] : nil;
	_tokenValue = _token.value;
	_tokenKind = _token.kind;
}

- (BOOL) hasTokens {
	return currentToken < [fetched count];
}

- (YASLToken *) nextToken {
	[self setCurrentToken:MIN([fetched count], currentToken + 1)];
	return _token;
}

#pragma mark - Exceptions handling

- (NSException *) prepareExceptionObject:(NSString *)msg {
	return [YASLNonfatalException exceptionAtLine:self.token.line andCollumn:self.token.collumn withMsg:msg];
}

@end
