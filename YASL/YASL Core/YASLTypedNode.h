//
//  YASLTypedNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"
#import "YASLToken.h"

@interface YASLTypedNode : YASLGrammarNode

@property (nonatomic) YASLTokenKind type;
@property (nonatomic) NSString *suppliedData;

- (id) initWithType:(YASLTokenKind)type;

@end
