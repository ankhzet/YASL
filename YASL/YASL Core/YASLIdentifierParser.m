//
//  YASLIdentifierParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLIdentifierParser.h"

@implementation YASLIdentifierParser

- (id)init {
	if (!(self = [super init]))
		return self;

	self.beginsWith = [[NSCharacterSet letterCharacterSet] mutableCopy];
	[(id)self.beginsWith addCharactersInString:@"_"];
	self.charset = [self.beginsWith mutableCopy];
	[(id)self.charset formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	[(id)self.charset addCharactersInString:@"-"];

	return self;
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	unichar c = 0;
	NSCharacterSet *charset = self.charset;
	while ((c = block(self, data)) && [charset characterIsMember:c])
			data->parsePos++;

	data->endAtPos = data->parsePos;
	return data->kind = YASLTokenKindIdentifier;
}


@end
