//
//  YASLTokenizer.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLToken.h"
#import "YASLExceptionStack.h"

@interface YASLAbstractTokenizer : YASLExceptionStack

@property	(nonatomic) NSString *source;
@property (nonatomic) YASLToken *token;
@property (nonatomic) NSString *tokenValue;
@property (nonatomic) YASLTokenKind tokenKind;

- (id) initWithSource:(NSString *)source;

+ (instancetype) loadFromFile:(NSString *)fileName;

- (NSArray *) tokenParsers;

- (NSArray *) tokenizeAll;
- (NSArray *) allTokens;
- (NSArray *) toValueArray:(NSArray *)tokens;

- (void) firstToken;
- (NSUInteger) currentToken;
- (void) setCurrentToken:(NSUInteger)token;
- (BOOL) hasTokens;
- (YASLToken *) nextToken;

@end
