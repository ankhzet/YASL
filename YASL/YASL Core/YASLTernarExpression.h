//
//  YASLTernarExpression.h
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLTernarExpression : YASLTranslationExpression

+ (instancetype) ternarExpressionInScope:(YASLDeclarationScope *)scope;

@end
