//
//  YASLStructPropertyExpression.h
//  YASLVM
//
//  Created by Ankh on 31.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLStructPropertyExpression : YASLTranslationExpression

+ (instancetype) structProperty:(NSString *)identifier inScope:(YASLDeclarationScope *)scope;

@end
