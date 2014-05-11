//
//  YASLIfExpression.h
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLIfExpression : YASLTranslationExpression

+ (instancetype) ifExpressionInScope:(YASLDeclarationScope *)scope;

@end
