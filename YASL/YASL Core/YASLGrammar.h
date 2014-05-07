//
//  YASLGrammar.h
//  YASL
//
//  Created by Ankh on 02.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"

@interface YASLGrammar : YASLGrammarNode

@property (nonatomic) YASLGrammarNode *rootNode;
@property (nonatomic) NSDictionary *allRules;

@end
