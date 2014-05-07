//
//  YASLAssembler.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembly.h"

@class YASLGrammar;
@interface YASLCommonAssembler : YASLAssembly

@end

@interface YASLCommonAssembler (AssemblingAndProcessing)

/*! Assemble tokenized source with specified grammar.
 @return Resulting assembly.
 */
- (YASLAssembly *) assembleSource:(YASLTokenizer *)tokenized withGrammar:(YASLGrammar *)grammar;

@end
