//
//  YASLAssembler.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembly.h"

@class YASLGrammarNode;
@interface YASLCommonAssembler : YASLAssembly

- (BOOL) assembleSource:(YASLTokenizer *)tokenized withGrammar:(YASLGrammarNode *)grammar;

- (YASLAssembly *) processAssembly;

@end
