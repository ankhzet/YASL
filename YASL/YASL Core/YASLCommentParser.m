//
//  YASLCommentParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCommentParser.h"

@implementation YASLCommentParser

- (id)init {
	if (!(self = [super init]))
		return self;

	self.beginsWith = [NSCharacterSet characterSetWithCharactersInString:@"/"];

	return self;
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	YASLTokenKind kind = YASLTokenKindComment;
	data->parsePos++;
	unichar c = block(self, data);
	if (c == '*') {
		// multiline comment

		unichar o = 0;
		do {
			data->parsePos++;
			while ((c = block(self, data)) && (c != '/')) {
				data->parsePos++;
				o = c;
			}
		} while (c && ((o != '*') || (c != '/')));

		if (c == '/') {
			data->parsePos++;
		}

	} else {
		// proubably, singleline
		if (c != '/')
			return YASLTokenKindEOF;

		do {
			data->parsePos++;
		} while ((c = block(self, data)) && (c != '\n'));
	}

	data->endAtPos = data->parsePos;
	return data->kind = kind;
}

@end
