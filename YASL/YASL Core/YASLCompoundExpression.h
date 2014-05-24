//
//  YASLCompoundExpression.h
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLCompoundExpression : YASLTranslationExpression

+ (instancetype) compoundExpressionInScope:(YASLDeclarationScope *)scope;

@end
