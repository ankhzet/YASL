//
//  YASLBNFParser.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTokenizer.h"

@class YASLGrammarNode;
@interface YASLBNFParser : YASLTokenizer

- (YASLGrammarNode *) buildGrammar;

@end
