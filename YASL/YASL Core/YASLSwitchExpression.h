//
//  YASLSwitchExpression.h
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@class YASLLocalDeclaration;
@interface YASLSwitchExpression : YASLTranslationExpression
@property (nonatomic) YASLLocalDeclaration *breakLabel;

+ (instancetype) switchExpressionInScope:(YASLDeclarationScope *)scope;

@end
