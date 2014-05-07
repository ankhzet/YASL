//
//  YASLBNFParser.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTokenizer.h"

@class YASLGrammar;
@interface YASLBNFParser : YASLTokenizer

- (YASLGrammar *) buildGrammar;

@end
