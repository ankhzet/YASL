//
//  YASLTranslationExpression.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"

typedef NS_ENUM(NSUInteger, YASLExpressionType) {
	YASLExpressionTypeMin = 0,
	YASLExpressionTypeAdditive,
	YASLExpressionTypeMultiplicative,

	YASLExpressionTypeTernar,

	YASLExpressionTypeLogicalOr,
	YASLExpressionTypeLogicalAnd,
	YASLExpressionTypeInclusiveOr,
	YASLExpressionTypeExclusiveOr,
	YASLExpressionTypeInclusiveAnd,
	YASLExpressionTypeRelational,
	YASLExpressionTypeShift,

	YASLExpressionTypeTypecast,
	YASLExpressionTypeUnary,
	YASLExpressionTypeSizeOf,

	YASLExpressionTypeVariable,
	YASLExpressionTypeConstant,
	YASLExpressionTypeString,

	YASLExpressionTypeArray,
	YASLExpressionTypeCall,
	YASLExpressionTypeProperty,
	YASLExpressionTypeStructure,

	YASLExpressionTypeDesignatedInitializer,

};

@class YASLDataType;
@interface YASLTranslationExpression : YASLTranslationNode

@property (nonatomic) YASLExpressionType expressionType;
@property (nonatomic) NSString *specifier;
@property (nonatomic) YASLDataType *returnType;

+ (instancetype) expressionWithType:(YASLExpressionType)type andSpecifier:(NSString *)specifier;

- (YASLTranslationExpression *) foldConstantExpression;

@end
