//
//  YASLWhileExpression.h
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

extern NSString *const YASLReservedWordContinue;
extern NSString *const YASLReservedWordBreak;

@class YASLLocalDeclaration;
@interface YASLWhileExpression : YASLTranslationExpression

@property (nonatomic) YASLLocalDeclaration *continueLabel;
@property (nonatomic) YASLLocalDeclaration *breakLabel;
@property (nonatomic) BOOL doWhile;

+ (instancetype) whileExpressionInScope:(YASLDeclarationScope *)scope;

@end
