//
//  YASLRepetitionNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"

typedef NS_ENUM(NSUInteger, YASLRepetitionSpecifier) {
	YASLRepetitionSpecifierNone = 0, // rule
	YASLRepetitionSpecifierOnce, // rule?
	YASLRepetitionSpecifierAtLeastOnce, // rule+
	YASLRepetitionSpecifierAny, // rule*

	YASLRepetitionSpecifierMAX
};

@interface YASLRepetitionNode : YASLGrammarNode

@property (nonatomic) YASLGrammarNode *linked;
@property (nonatomic) YASLRepetitionSpecifier specifier;

+ (YASLRepetitionSpecifier) parseSpecifier:(NSString *)specifier;

@end
