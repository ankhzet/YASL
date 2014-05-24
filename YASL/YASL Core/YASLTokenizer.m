//
//  YASLTokenizer.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTokenizer.h"
#import "YASLIdentifierParser.h"
#import "YASLNumericParser.h"
#import "YASLStringParser.h"
#import "YASLGreedyParser.h"
#import "YASLCommentParser.h"
#import "YASLSymbolParser.h"

@implementation YASLTokenizer

- (NSArray *) tokenParsers {
	return @[
					 [YASLIdentifierParser new],
					 [YASLNumericParser new],
					 [YASLStringParser new],
					 [YASLCommentParser new],
					 [YASLSymbolParser new],
					 [YASLGreedyParser new],
					 ];
}

@end
