//
//  YASLMethodCallExpression.h
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@class YASLDeclarationScope, YASLLocalDeclaration;
@interface YASLMethodCallExpression : YASLTranslationExpression

@property (nonatomic) YASLLocalDeclaration *associatedMethod;

+ (instancetype) methodCallInScope:(YASLDeclarationScope *)scope;

@end
