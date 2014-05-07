//
//  YASLConstantExpression.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"

typedef NS_ENUM(NSUInteger, YASLConstantType) {
	YASLConstantTypeVoid = 0,
	YASLConstantTypeInt,
	YASLConstantTypeFloat,
	YASLConstantTypeBool,
	YASLConstantTypeChar,
	YASLConstantTypeEnum,

	YASLConstantTypeMAX
};

@interface YASLTranslationConstant : YASLTranslationExpression

@property (nonatomic) YASLConstantType constantType;
@property (nonatomic) NSNumber *value;

+ (instancetype) constantWithType:(YASLConstantType)type andValue:(NSNumber *)value;

@end
