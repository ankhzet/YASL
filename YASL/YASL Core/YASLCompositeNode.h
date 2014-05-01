//
//  YASLCompositeNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"

@interface YASLCompositeNode : YASLGrammarNode

@property (nonatomic) NSMutableArray *subnodes;

/*! Add subnode to this node. */
- (void) addSubNode:(YASLGrammarNode *)subnode;

- (BOOL) hasChild:(YASLGrammarNode *)child;

@end
