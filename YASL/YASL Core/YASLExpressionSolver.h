//
//  YASLExpressionSolver.h
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLLocalDeclarations, YASLTranslationExpression, YASLExpressionProcessor;
@interface YASLExpressionSolver : NSObject

@property (nonatomic, readonly, weak) YASLLocalDeclarations *declarationScope;

+ (instancetype) solverInDeclarationScope:(YASLLocalDeclarations *)scope;

- (YASLExpressionProcessor *) pickProcessor:(YASLTranslationExpression *)expression;

@end
