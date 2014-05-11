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
	NSString *type = self.returnType.name;
	type = type ? type : @"<?>";
	return [NSString stringWithFormat:@"(%@ %@)", type, self.value];
}

#pragma mark - Typecast

- (YASLInt) toInteger {
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

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	YASLOpcode *opcode = OPC_(MOV, REG_(R0), IMM_(self.value));
	[assembly push:opcode];
	return YES;
}

@end
