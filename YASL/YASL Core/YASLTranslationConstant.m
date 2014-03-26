//
//  YASLConstantExpression.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationConstant.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTranslationConstant

+ (instancetype) constantInScope:(YASLDeclarationScope *)scope withType:(YASLDataType *)type andValue:(NSNumber *)value {
	YASLTranslationConstant *constant = [self expressionInScope:scope withType:YASLExpressionTypeConstant andSpecifier:nil];
	constant.returnType = type;
	constant.value = value;
	return constant;
}

- (NSString *) toString {
//	NSString *type = self.returnType ? [self.returnType description] : @"<?>";
//	return [NSString stringWithFormat:@"%@%@", type, self.value];
	return [NSString stringWithFormat:@"%@", self.value];
}

#pragma mark - Typecast

- (YASLInt) toInteger {
	switch ([self.returnType builtInType]) {
		case YASLBuiltInTypeInt:
			return (YASLInt)[self.value integerValue];
			break;
		case YASLBuiltInTypeFloat:
			return [self.value floatValue];
			break;
		case YASLBuiltInTypeBool:
			return [self.value boolValue];
			break;
		case YASLBuiltInTypeChar:
			return (YASLInt)[self.value unsignedIntegerValue];
			break;
		default:
			break;
	}
	return 0;
}

- (YASLFloat) toFloat {
	switch ([self.returnType builtInType]) {
		case YASLBuiltInTypeInt:
			return [self.value integerValue];
			break;
		case YASLBuiltInTypeFloat:
			return [self.value floatValue];
			break;
		case YASLBuiltInTypeBool:
			return [self.value boolValue];
			break;
		case YASLBuiltInTypeChar:
			return [self.value unsignedIntegerValue];
			break;
		default:
			break;
	}
	return 0;
}

- (YASLBool) toBool {
	switch ([self.returnType builtInType]) {
		case YASLBuiltInTypeInt:
			return (YASLBool)[self.value integerValue];
			break;
		case YASLBuiltInTypeFloat:
			return [self.value floatValue];
			break;
		case YASLBuiltInTypeBool:
			return [self.value boolValue];
			break;
		case YASLBuiltInTypeChar:
			return (YASLBool)[self.value unsignedIntegerValue];
			break;
		default:
			break;
	}
	return 0;
}

- (YASLChar) toChar {
	switch ([self.returnType builtInType]) {
		case YASLBuiltInTypeInt:
			return [self.value integerValue];
			break;
		case YASLBuiltInTypeFloat:
			return [self.value floatValue];
			break;
		case YASLBuiltInTypeBool:
			return [self.value boolValue];
			break;
		case YASLBuiltInTypeChar:
			return [self.value unsignedIntegerValue];
			break;
		default:
			break;
	}
	return 0;
}

@end

@implementation YASLTranslationConstant (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	return NO;
}

- (void) assemble:(YASLAssembly *)assembly {
	[assembly push:OPC_(MOV, REG_(R0), IMM_(self.value))];
}

@end
