//
//  YASLDeclarationInitializer.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"

typedef NS_ENUM(NSUInteger, YASLInitializerType) {
	YASLInitializerTypeConstantInitializer,
	YASLInitializerTypeExpressionInitializer,
	YASLInitializerTypeArrayInitializer,
};

@class YASLTranslationExpression;
@interface YASLDeclarationInitializer : YASLTranslationNode

@property (nonatomic) YASLInitializerType initializerType;
@property (nonatomic) id initializerExpression;

+ (instancetype) initializerWithType:(YASLInitializerType)type andExpression:(YASLTranslationExpression *)expression;

@end
