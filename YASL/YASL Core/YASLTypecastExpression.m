//
//  YASLTypecastExpression.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTypecastExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTypecastExpression {
	BOOL hasCast;
}

+ (instancetype) typecastInScope:(YASLDeclarationScope *)scope withType:(YASLDataType *)type {
	YASLTypecastExpression *expression = [self expressionInScope:scope withType:YASLExpressionTypeTypecast andSpecifier:type.name];
	expression.returnType = type;
	return expression;
}

/*! Try to evaluate this typecast if subnode is constant. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationConstant *folded = (id)[[self leftOperand] foldConstantExpressionWithSolver:solver];
	[self setNth:0 operand:folded];
	if (folded.expressionType != YASLExpressionTypeConstant)
		return self;

	switch ([self.returnType builtInType]) {
		case YASLBuiltInTypeInt:
			return [YASLTranslationConstant constantInScope:self.declarationScope withType:self.returnType andValue:@([folded toInteger])];
		case YASLBuiltInTypeFloat:
			return [YASLTranslationConstant constantInScope:self.declarationScope withType:self.returnType andValue:@([folded toFloat])];
		case YASLBuiltInTypeBool:
			return [YASLTranslationConstant constantInScope:self.declarationScope withType:self.returnType andValue:@([folded toBool])];
		case YASLBuiltInTypeChar:
			return [YASLTranslationConstant constantInScope:self.declarationScope withType:self.returnType andValue:@([folded toChar])];

		default:
			break;
	}

	return self;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"(%@)%@", self.specifier, [self leftOperand]];
}

@end

@implementation YASLTypecastExpression (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	return hasCast ? NO :[[self leftOperand] unPointer:outAssembly];
}

- (void) assemble:(YASLAssembly *)assembly {
	hasCast = NO;
	YASLTranslationExpression *expression = [self leftOperand];
	[expression assemble:assembly unPointered:NO];

	YASLDataType *sourceType = expression.returnType;
	if (![sourceType isSubclassOf:self.returnType]) {
		YASLBuiltInType source = [sourceType baseType];
		YASLBuiltInType cast = [self.returnType baseType];
		YASLOpcodes opcode = OPC_NOP;
		switch (source) {
			case YASLBuiltInTypeInt:
				switch (cast) {
					case YASLBuiltInTypeFloat: opcode = OPC_CVIF; break;
					case YASLBuiltInTypeBool : opcode = OPC_CVIB; break;
					default: break;
				}
				break;
			case YASLBuiltInTypeFloat:
				switch (cast) {
					case YASLBuiltInTypeInt  : opcode = OPC_CVFI; break;
					case YASLBuiltInTypeBool : opcode = OPC_CVFB; break;
					case YASLBuiltInTypeChar : opcode = OPC_CVFC; break;
					default: break;
				}
				break;
			case YASLBuiltInTypeChar:
				switch (cast) {
					case YASLBuiltInTypeFloat: opcode = OPC_CVCF; break;
					case YASLBuiltInTypeBool : opcode = OPC_CVCB; break;
					default: break;
				}
				break;

			default:
				break;
		}

		hasCast = opcode != OPC_NOP;
		if (hasCast) {
			[expression unPointer:assembly];
			[assembly push:OPC(opcode, REG_(R0))];
		}
	}
}

@end
