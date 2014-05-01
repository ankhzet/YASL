//
//  YASLTokenParser.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLToken.h"

@class YASLTokenParser;

typedef struct {
	NSUInteger parsePos, startFromPos, endAtPos;
	YASLTokenKind kind;
} YASLTokenParseData;

typedef unichar (^YASLTokenParseBlock)(YASLTokenParser *parser, YASLTokenParseData *parseData);

@interface YASLTokenParser : NSObject

@property (nonatomic) NSCharacterSet *charset;
@property (nonatomic) NSCharacterSet *beginsWith;

- (BOOL) handles:(unichar)charachter;

- (BOOL) parseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block;

// for subclasses only
- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block;

@end
