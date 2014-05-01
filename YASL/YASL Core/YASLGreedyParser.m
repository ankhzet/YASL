//
//  YASLGreedyParser.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGreedyParser.h"

@implementation YASLGreedyParser

- (BOOL) handles:(unichar)charachter {
	return YES;
}

- (YASLTokenKind) doParseWithUserData:(YASLTokenParseData *)data andBlock:(YASLTokenParseBlock)block {
	data->endAtPos = ++data->parsePos;
	return data->kind = YASLTokenKindSymbol;
}

@end
