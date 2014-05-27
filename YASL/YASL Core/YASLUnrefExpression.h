//
//  YASLUnrefExpression.h
//  YASL
//
//  Created by Ankh on 25.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLUnrefExpression : YASLTranslationExpression
@property (nonatomic) BOOL isUnreference;

+ (instancetype) unrefExpressionInScope:(YASLDeclarationScope *)scope;

@end
