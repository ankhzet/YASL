//
//  YASLAssignmentExpression.h
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLAssignmentExpression : YASLTranslationExpression

@property (nonatomic) BOOL postfix;

+ (instancetype) assignmentInScope:(YASLDeclarationScope *)scope withSpecifier:(YASLExpressionOperator)operator;

@end
