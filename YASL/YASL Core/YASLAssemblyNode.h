//
//  YASLAssemblyNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@class YASLGrammarNode, YASLAssembly;
@interface YASLAssemblyNode : NSObject

@property (nonatomic) YASLGrammarNode *grammarNode;
@property (nonatomic) NSUInteger sourceLine;
#ifdef VERBOSE_ASSEMBLY
@property (nonatomic) YASLAssembly *tokensAssembly;
@property (nonatomic) id topToken;
@property (nonatomic) id bottomToken;
#endif
@property (nonatomic) NSRange tokensRange;
@property (nonatomic) YASLAssembly *assembly;

@end
