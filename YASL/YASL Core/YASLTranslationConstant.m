//
//  YASLConstantExpression.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationConstant.h"

NSString *const YASLConstantTypeNames[YASLConstantTypeMAX] = {
	[YASLConstantTypeVoid] = @"void",
	[YASLConstantTypeInt] = @"int",
	[YASLConstantTypeFloat] = @"float",
	[YASLConstantTypeBool] = @"bool",
	[YASLConstantTypeChar] = @"char",
	[YASLConstantTypeEnum] = @"enum",
};

@implementation YASLTranslationConstant

+ (instancetype) constantWithType:(YASLConstantType)type andValue:(NSNumber *)value {
	YASLTranslationConstant *constant = [self expressionWithType:YASLExpressionTypeConstant andSpecifier:nil];
	constant.constantType = type;
	constant.value = value;
	return constant;
}

- (NSString *) toString {
	NSString *type = YASLConstantTypeNames[self.constantType];
	type = type ? type : @"<?>";
	return [NSString stringWithFormat:@"(%@ %@)", type, self.value];
}

@end
