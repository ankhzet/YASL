//
//  YASLStringParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStringParser.h"

@interface YASLStringParser () {
	NSCharacterSet *breaks;
}
@end

@implementation YASLStringParser

- (id)init {
	if (!(self = [super init]))
		return self;

	self.beginsWith = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
	self.charset = [NSCharacterSet alphanumericCharacterSet];

	return self;
}

- (id) singleCharMode {
	self.beginsWith = [NSCharacterSet characterSetWithCharactersInString:@"'"];
	self.singleChar = YES;
	return self;
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	BOOL single = self.singleChar;
	YASLTokenKind kind = single ? YASLTokenKindChar : YASLTokenKindString;
	unichar c = 0;
	unichar quoteSymbol = block(self, data);
	data->parsePos++;
	data->startFromPos = data->parsePos;

	while ((c = block(self, data))) {
		data->parsePos++;
		if ((c == quoteSymbol) || single)
			break;
	}

	if (c != quoteSymbol) {
		return YASLTokenKindEOF;
	}

	data->endAtPos = data->parsePos - 1;
	return data->kind = kind;
}

@end
