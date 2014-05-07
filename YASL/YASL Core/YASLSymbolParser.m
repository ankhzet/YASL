//
//  YASLSymbolParser.m
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLSymbolParser.h"

@implementation YASLSymbolParser

- (id)init {
	if (!(self = [super init]))
		return self;

	NSMutableCharacterSet *set = [[NSCharacterSet punctuationCharacterSet] mutableCopy];
	[set formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];

	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	[set formIntersectionWithCharacterSet:[whitespace invertedSet]];

	self.beginsWith = set;
	self.charset = set;

	return self;
}

#define CHECK(_symbol) { if (c == _symbol) { data->parsePos++; break; } }



- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	YASLTokenKind kind = YASLTokenKindSymbol;
	unichar c1 = 0, c = 0;
	NSCharacterSet *charset = self.charset;

	while ((c1 = block(self, data)) && [charset characterIsMember:c1]) {
		data->parsePos++;
		if (!(c = block(self, data)))
			break;

		switch (c1) {
			case '+': CHECK('+'); break;
			case '|': CHECK('|'); break;
			case '&': CHECK('&'); break;
			case '!': CHECK('='); break;
			case '=': CHECK('='); break;
			case '-': CHECK('-'); CHECK('>'); break;
			case '>': CHECK('>'); CHECK('='); break;
			case '<': CHECK('<'); CHECK('='); break;

			default:;
		}
		break;
	}

	data->endAtPos = data->parsePos;
	return data->kind = kind;
}

@end
