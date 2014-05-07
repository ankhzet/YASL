//
//  YASLDeclarationInitializer.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDeclarationInitializer.h"
#import "YASLTranslationExpression.h"

@implementation YASLDeclarationInitializer

+ (instancetype) initializerWithType:(YASLInitializerType)type andExpression:(YASLTranslationExpression *)expression {
	YASLDeclarationInitializer *initializer = [self nodeWithType:YASLTranslationNodeTypeInitializer];
	initializer.initializerType = type;
	initializer.initializerExpression = expression;
	return initializer;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"=%@", self.initializerExpression ? self.initializerExpression : @"<dummy initializer>"];
}

@end
