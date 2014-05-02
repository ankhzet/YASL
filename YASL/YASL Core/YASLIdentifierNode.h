//
//  YASLIdentifierNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"

@interface YASLIdentifierNode : YASLGrammarNode

@property (nonatomic) NSString *identifier;
@property (nonatomic, weak) YASLGrammarNode *link;

@end
