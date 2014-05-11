//
//  YASLMethodCallExpression.h
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@class YASLDeclarationScope;
@interface YASLMethodCallExpression : YASLTranslationExpression

@property (nonatomic) YASLTranslationExpression *methodAddress;

+ (instancetype) methodCallInScope:(YASLDeclarationScope *)scope;

@end
