//
//  YASLTranslationExpression.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"
#import "YASLCoreLangClasses.h"

NSString *const YASLExpressionOperationSpecifiers[YASLExpressionOperatorMAX] = {
	[YASLExpressionOperatorUnknown] = @"#",
	[YASLExpressionOperatorAdd] = @"+",
	[YASLExpressionOperatorSub] = @"-",
	[YASLExpressionOperatorIncrement] = @"++",
	[YASLExpressionOperatorDecrement] = @"--",
	[YASLExpressionOperatorMul] = @"*",
	[YASLExpressionOperatorDiv] = @"/",
	[YASLExpressionOperatorRest] = @"%",
	[YASLExpressionOperatorSHL] = @"<<",
	[YASLExpressionOperatorSHR] = @">>",
	[YASLExpressionOperatorInclusiveAnd] = @"&",
	[YASLExpressionOperatorInclusiveOr] = @"|",
	[YASLExpressionOperatorExclusiveOr] = @"^",
	[YASLExpressionOperatorLogicAnd] = @"&&",
	[YASLExpressionOperatorLogicOr] = @"||",
	[YASLExpressionOperatorEqual] = @"==",
	[YASLExpressionOperatorNotEqual] = @"!=",
	[YASLExpressionOperatorLess] = @"<",
	[YASLExpressionOperatorLessEqual] = @"<=",
	[YASLExpressionOperatorGreater] = @">",
	[YASLExpressionOperatorGreaterEqual] = @">=",

	[YASLExpressionOperatorNot] = @"!",
	[YASLExpressionOperatorInv] = @"~",
	[YASLExpressionOperatorRef] = @"&",
	[YASLExpressionOperatorUnref] = @"*",
};


@implementation YASLTranslationExpression

+ (instancetype) expressionInScope:(YASLDeclarationScope *)scope withType:(YASLExpressionType)type {
	YASLTranslationExpression *expression = [self nodeInScope:scope withType:YASLTranslationNodeTypeExpression];
	expression.expressionType = type;
	return expression;
}

+ (instancetype) expressionInScope:(YASLDeclarationScope *)scope withType:(YASLExpressionType)type andSpecifier:(NSString *)specifier {
	YASLTranslationExpression *expression = [self expressionInScope:scope withType:type];
	expression.specifier = specifier;
	return expression;
}

+ (YASLExpressionOperator) specifierToOperator:(NSString *)specifier unary:(BOOL)unary {
	for (YASLExpressionOperator o = YASLExpressionOperatorUnknown; o < YASLExpressionOperatorMAX; o++)
		if ([YASLExpressionOperationSpecifiers[o] isEqualToString:specifier]) {
			if (unary)
				switch (o) {
					case YASLExpressionOperatorInclusiveAnd: return YASLExpressionOperatorRef;
					case YASLExpressionOperatorMul: return YASLExpressionOperatorUnref;
					default:;
				}
			return o;
		}

	return YASLExpressionOperatorUnknown;
}

+ (NSString *) operatorToSpecifier:(YASLExpressionOperator)operator {
	return YASLExpressionOperationSpecifiers[operator];
}

- (YASLExpressionOperator) expressionOperator {
	return [YASLTranslationExpression specifierToOperator:self.specifier unary:self.isUnary];
}

/*! Try to evaluate this expression. If it consists from constant operands, then result will be evaluated constant value, else returns self. */
- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	switch (self.expressionType) {
		case YASLExpressionTypeVariable:{
			if (!self.returnType) {
				YASLLocalDeclaration *declaration = [self.declarationScope localDeclarationByIdentifier:self.specifier];

				if (!declaration.dataType) {
					@throw [YASLNonfatalException exceptionAtLine:0 andCollumn:0 withMsg:@"Variable not yet declared: %@", self];
				} else
					self.returnType = declaration.dataType;
			}
			return self;
		}
		case YASLExpressionTypeConstant:
			return self;

		default:;
	}

	NSMutableArray *foldedOperands = [@[] mutableCopy];
	int nonConstants = 0;
	// first, try to fold operands
	for (YASLTranslationExpression *operand in [self nodesEnumerator:NO]) {
		YASLTranslationExpression *folded = [operand foldConstantExpressionWithSolver:solver];
    [foldedOperands addObject:folded];
		if (folded.expressionType != YASLExpressionTypeConstant)
			nonConstants++;
	}

	[self setSubNodes:foldedOperands];

	YASLExpressionProcessor *processor = [solver pickProcessor:self];
	if (!processor) {
		@throw [YASLNonfatalException exceptionAtLine:0 andCollumn:0 withMsg:@"Can't process constant expression: %@", self];
	}

	// there are non-constant operands
	if (nonConstants) {
		self.returnType = processor.returnType;
		YASLDataType *castType = processor.castType;

		for (int i = 0; i < [self nodesCount]; i++) {
			YASLTranslationExpression *operand = [self nthOperand:i];
			if (operand.returnType != castType) {
				YASLTypecastExpression *typecast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:castType];
				[typecast addSubNode:operand];
				[self setNth:i operand:[typecast foldConstantExpressionWithSolver:solver]];
			}
		}

		return self;
	}

	// try evaluate operands
	//TODO: constant expressions evaluation
	YASLTranslationExpression *result = [processor solveExpression:self];

	return result;
}

+ (BOOL) checkFolding:(YASLTranslationExpression **)operand withSolver:(YASLExpressionSolver *)solver {
	if (*operand == nil)
		return NO;

	if ((*operand).expressionType == YASLExpressionTypeConstant)
		return YES;

	YASLTranslationExpression *constantOperand = [*operand foldConstantExpressionWithSolver:solver];
	if (constantOperand == *operand)
		return NO;

	*operand = constantOperand;
	return YES;
}

- (NSString *) toString {
	NSString *subs = @"";
	BOOL unary = [self nodesCount] <= 1;
	if (!unary) {
		NSString *delim = [NSString stringWithFormat:@" %@ ", self.specifier];
		for (YASLTranslationNode *subnode in [self nodesEnumerator:NO]) {
			subs = [NSString stringWithFormat:@"%@%@%@", subs, ([subs length] ? delim : @""), [subnode toString]];
		}
	}
	subs = [subs length] ? subs : self.specifier;

	NSString *type = unary ? @"" : [self.returnType description];
	return [NSString stringWithFormat:(unary ? @"%@%@" : @"%@(%@)"), type, subs];
}


@end

@implementation YASLTranslationExpression (Assembling)

+ (YASLOpcodes) operationToOpcode:(YASLExpressionOperator)operator typed:(YASLBuiltInType)type {
	switch (type) {
		case YASLBuiltInTypeBool:
		case YASLBuiltInTypeChar:
		case YASLBuiltInTypeInt:
			switch (operator) {
				case YASLExpressionOperatorAdd: return OPC_ADD;
				case YASLExpressionOperatorSub: return OPC_SUB;
				case YASLExpressionOperatorMul: return OPC_MUL;
				case YASLExpressionOperatorDiv: return OPC_DIV;
				case YASLExpressionOperatorRest: return OPC_RST;

				case YASLExpressionOperatorSHL: return OPC_SHL;
				case YASLExpressionOperatorSHR: return OPC_SHR;

				case YASLExpressionOperatorLogicOr: return OPC_OR;
				case YASLExpressionOperatorLogicAnd: return OPC_AND;

				case YASLExpressionOperatorInclusiveAnd: return OPC_AND;
				case YASLExpressionOperatorInclusiveOr: return OPC_OR;
				case YASLExpressionOperatorExclusiveOr: return OPC_XOR;

				case YASLExpressionOperatorDecrement: return OPC_DEC;
				case YASLExpressionOperatorIncrement: return OPC_INC;

				case YASLExpressionOperatorEqual: return OPC_JZ;
				case YASLExpressionOperatorNotEqual: return OPC_JNZ;

				case YASLExpressionOperatorGreater: return OPC_JGT;
				case YASLExpressionOperatorGreaterEqual: return OPC_JGE;
				case YASLExpressionOperatorLess: return OPC_JLT;
				case YASLExpressionOperatorLessEqual: return OPC_JLE;

				default:
					break;
			}
			break;
		case YASLBuiltInTypeFloat:
			switch (operator) {
				case YASLExpressionOperatorAdd: return OPC_ADDF;
				case YASLExpressionOperatorSub: return OPC_SUBF;
				case YASLExpressionOperatorMul: return OPC_MULF;
				case YASLExpressionOperatorDiv: return OPC_DIVF;

				case YASLExpressionOperatorNot: return OPC_NOTF;
				case YASLExpressionOperatorLogicOr: return OPC_ORF;
				case YASLExpressionOperatorLogicAnd: return OPC_ANDF;

				case YASLExpressionOperatorDecrement: return OPC_DECF;
				case YASLExpressionOperatorIncrement: return OPC_INCF;
				default:
					break;
			}
			break;
		default:
			break;
	}

	return OPC_NOP;
}

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	BOOL isVariable = self.expressionType == YASLExpressionTypeVariable;
	if (!isVariable)
		return NO;

	[outAssembly push:OPC_(MOV, REG_(R0), [REG_(R0) asPointer])];
	return YES;
}

- (void) assemble:(YASLAssembly *)assembly {
	switch (self.expressionType) {
		case YASLExpressionTypeBinary: {
			[[self leftOperand] assemble:assembly unPointered:YES];
			[assembly push:OPC_(PUSH, REG_(R0))];
			[[self rigthOperand] assemble:assembly unPointered:YES];
			[assembly push:OPC_(MOV, REG_(R1), REG_(R0))];
			[assembly push:OPC_(POP, REG_(R0))];
			YASLOpcodes opcode = [YASLTranslationExpression operationToOpcode:[self expressionOperator] typed:[self.returnType baseType]];
			switch (opcode) {
				case OPC_JZ:
				case OPC_JNZ:
				case OPC_JGE:
				case OPC_JGT:
				case OPC_JLE:
				case OPC_JLT: {
					YASLOpcodeOperand *labTrue = IMM_(0);
					YASLOpcodeOperand *labOut = IMM_(0);
					YASLCodeAddressReference *trueRef = [YASLCodeAddressReference new];
					YASLCodeAddressReference *outRef = [YASLCodeAddressReference new];
					[trueRef addReferent:labTrue];
					[outRef addReferent:labOut];
					YASLTranslationExpression *left = [self leftOperand];
					switch ([left.returnType baseType]) {
						case YASLBuiltInTypeInt:
						case YASLBuiltInTypeBool:
						case YASLBuiltInTypeChar:
							[assembly push:OPC_(SUB, REG_(R0), REG_(R1))];
							break;
						case YASLBuiltInTypeFloat:
							[assembly push:OPC_(SUBF, REG_(R0), REG_(R1))];
							break;
						default: ;
					}
					[assembly push:OPC(opcode, labTrue)];
					[assembly push:OPC_(XOR, REG_(R0), REG_(R0))];
					[assembly push:OPC_(JMP, labOut)];
					[assembly push:trueRef];
					[assembly push:OPC_(XOR, REG_(R0), REG_(R0))];
					[assembly push:OPC_(INC, REG_(R0))];
					[assembly push:outRef];
					break;
				}

				default:
					[assembly push:OPC(opcode, REG_(R0), REG_(R1))];
					break;
			}
			break;
		}

		case YASLExpressionTypeVariable: {
			NSString *declarationIdentifier = self.specifier;
			YASLLocalDeclaration *declaration = [self.declarationScope localDeclarationByIdentifier:declarationIdentifier];
			YASLOpcodeOperand *operand;
			switch ([declaration.parentScope.placementManager placementType]) {
				case YASLDeclarationPlacementTypeInCode:
					operand = IMM_(@0);
					break;
				case YASLDeclarationPlacementTypeOnStack:
					operand = REG_IMM(BP, @0);
					break;

				default:
					break;
			}
			[declaration.reference addReferent:operand];
			[assembly push:OPC_(MOV, REG_(R0), operand)];
			break;
		}
		default:
//			NSAssert(0, @"Unknown expression type, can't assemble");
			break;
	}
	
}

@end

