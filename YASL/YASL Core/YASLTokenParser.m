//
//  YASLTokenParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTokenParser.h"

@implementation YASLTokenParser

- (BOOL) handles:(unichar)charachter {
	return [_beginsWith characterIsMember:charachter];
}

- (BOOL) parseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	NSUInteger oldPos = data->parsePos;
	data->startFromPos = oldPos;
	data->endAtPos = oldPos;

	[self doParseWithUserData:data andBlock:block];

	return (data->kind != YASLTokenKindEOF) && (oldPos < data->parsePos);
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	return data->kind = YASLTokenKindEOF;
}

@end
