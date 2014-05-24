//
//  YASLReturnExpression.h
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

@class YASLLocalDeclaration;
@interface YASLJumpExpression : YASLTranslationExpression

@property (nonatomic) YASLLocalDeclaration *jumpDeclaration;

@end
