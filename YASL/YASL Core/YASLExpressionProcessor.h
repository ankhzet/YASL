//
//  YASLExpressionProcessor.h
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YASLTranslationExpression.h"

@class YASLDataType;
@interface YASLExpressionProcessor : NSObject

@property (nonatomic, readonly) YASLDataType *leftOperand;
@property (nonatomic) NSDictionary *rightOperand;

- (YASLTranslationExpression *) solveExpression:(YASLTranslationExpression *)expression;

@end
