//
//  YASLTypecastExpression.h
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@interface YASLTypecastExpression : YASLTranslationExpression

+ (instancetype) typecastInScope:(YASLDeclarationScope *)scope withType:(YASLDataType *)type;

@end
