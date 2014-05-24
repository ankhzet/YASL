//
//  YASLArrayElementExpression.h
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLArrayElementExpression : YASLTranslationExpression

+ (instancetype) arrayElementInScope:(YASLDeclarationScope *)scope;

@end
