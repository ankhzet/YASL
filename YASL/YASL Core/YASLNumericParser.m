//
//  YASLNumericParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNumericParser.h"

@implementation YASLNumericParser

- (id)init {
	if (!(self = [super init]))
		return self;

	self.beginsWith = [NSCharacterSet decimalDigitCharacterSet];
	self.charset = self.beginsWith;

	return self;
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	YASLTokenKind kind = YASLTokenKindInteger;
	unichar c = 0;
	NSCharacterSet *charset = self.charset;
	while ((c = block(self, data)) && [charset characterIsMember:c])
		data->parsePos++;

	if (c == '.') {
		data->parsePos++;
		while ((c = block(self, data)) && [charset characterIsMember:c])
			data->parsePos++;

		kind = YASLTokenKindFloat;
	}

	data->endAtPos = data->parsePos;
	return data->kind = kind;
}


@end
