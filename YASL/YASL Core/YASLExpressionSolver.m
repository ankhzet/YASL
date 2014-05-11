//
//  YASLExpressionSolver.m
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLExpressionSolver.h"
#import "YASLExpressionProcessor.h"
#import "YASLOperationProductionsAssembler.h"
#import "YASLCoreLangClasses.h"

#import "YASLIntExpressionProcessor.h"
#import "YASLFloatExpressionProcessor.h"
#import "YASLBoolExpressionProcessor.h"
#import "YASLCharExpressionProcessor.h"

NSString *const kProductionResultType = @"kProductionResultType";
NSString *const kProductionCastType = @"kProductionCastType";

@implementation YASLExpressionSolver {
	NSMutableDictionary *processors, *productionMatrix;
	NSDictionary *expressionProcessors;
}

+ (instancetype) solverInDeclarationScope:(YASLLocalDeclarations *)scope {
	return [[self alloc] initWithDeclarationScope:scope];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	productionMatrix = [NSMutableDictionary dictionary];

	expressionProcessors =
	@{
		YASLBuiltInTypeIdentifierInt: [YASLIntExpressionProcessor class],
		YASLBuiltInTypeIdentifierFloat: [YASLFloatExpressionProcessor class],
		YASLBuiltInTypeIdentifierBool: [YASLBoolExpressionProcessor class],
		YASLBuiltInTypeIdentifierChar: [YASLCharExpressionProcessor class],
		};
	return self;
}

- (id)initWithDeclarationScope:(YASLLocalDeclarations *)scope {
	if (!(self = [self init]))
		return self;

	_declarationScope = scope;
	[self loadOperationsProductionMatrix];
	return self;
}

-(void) loadOperationsProductionMatrix {
	NSArray *operationProductions = [[YASLOperationProductionsAssembler new] assembleFile:@"YASLOperationsProduction.opr"];
	//	NSLog(@"%@", operationProductions);
	for (NSDictionary *production in operationProductions) {
		NSArray *operations = production[kProductionOperations];
		NSArray *productionsList = production[kProductions];
		//		NSLog(@"Operations: [%@]", [operations componentsJoinedByString:@", "]);
		for (NSDictionary *productions in productionsList) {
			NSSet *filter = [NSSet setWithArray:productions[kProductionFilter]];
			if (![filter count]) filter = [NSSet setWithArray:operations];

			NSArray *operands = productions[kProductionOperands];
			NSArray *leftProductions = productions[kProductions];
			//			NSLog(@"  Left operands: [%@] not for [%@]", [operands componentsJoinedByString:@", "], [[filter allObjects] componentsJoinedByString:@", "]);
			for (NSDictionary *rightProductions in leftProductions) {
				NSArray *rightOperands = rightProductions[kProductionOperands];
				NSSet *rightFilter = [NSSet setWithArray:rightProductions[kProductionFilter]];
				if (![rightFilter count]) rightFilter = [NSSet setWithArray:operations];

				NSDictionary *productionType = rightProductions[kProductionTypeIdentifier];
				NSString *productionResultType = productionType[kProductionTypeOperand];
				NSString *operandsCast = productionType[kProductionTypeCast];
				//				NSLog(@"    Right operands: [%@]: %@", [rightOperands componentsJoinedByString:@", "], productionType);

				for (NSNumber *opValue in operations) {
					if (![filter member:opValue])
						continue;

					YASLExpressionOperator operator = [opValue unsignedIntegerValue];
					for (NSString *leftOperand in operands) {
						if (![rightFilter member:opValue])
							continue;

						for (NSString *rightOperand in rightOperands) {
							//							NSLog(@"(%@->%@)%@ [%@] %@", operandsCast, productionResultType, leftOperand, [YASLExpressionProcessor operatorToSpecifier:operator], rightOperand);

							[self setProduction:operator result:productionResultType forLeftOperand:leftOperand andRightOperand:rightOperand castedTo:operandsCast];
						}
					}
				}
			}
		}
	}
}

- (void) setProduction:(YASLExpressionOperator)operator
								result:(NSString *)productionResultType
				forLeftOperand:(NSString *)leftOperand
			 andRightOperand:(NSString *)rightOperand
							castedTo:(NSString *)operandsCast
{
	NSMutableDictionary *productions, *leftProductions, *rightProductions;

	productions = productionMatrix[@(operator)];
	if (!productions) {
		productions = productionMatrix[@(operator)] = [NSMutableDictionary dictionary];
	}

	leftProductions = productions[leftOperand];
	if (!leftProductions) {
		leftProductions = productions[leftOperand] = [NSMutableDictionary dictionary];
	}

	rightProductions = leftProductions[rightOperand];
	if (!rightProductions) {
		rightProductions = leftProductions[rightOperand] = [NSMutableDictionary dictionary];
	}

	YASLDataType *castType = [self.declarationScope typeByName:operandsCast];
	YASLDataType *resultType = [self.declarationScope typeByName:productionResultType];


	if (!(resultType && castType))
		@throw [YASLNonfatalException exceptionAtLine:0 andCollumn:0 withMsg:@"Unknown data type: %@", resultType ? operandsCast : productionResultType];

	rightProductions[kProductionCastType] = castType;
	rightProductions[kProductionResultType] = resultType;
}

- (NSDictionary *) pickProductionForOperation:(YASLExpressionOperator)operation
																	leftOperand:(NSString *)left
																 rightOperand:(NSString *)right
{
	NSMutableDictionary *productions, *leftProductions;

	productions = productionMatrix[@(operation)];
	if (!productions)
		return nil;

	leftProductions = productions[left];
	if (!leftProductions)
		return nil;

	return leftProductions[right];
}

- (YASLExpressionProcessor *) pickProcessor:(YASLTranslationExpression *)expression {
	NSUInteger operands = [expression operandsCount];
	switch (operands) {
		case 2: {
			YASLExpressionOperator operator = [YASLTranslationExpression specifierToOperator:expression.specifier];
			NSString *leftOperandType = [YASLDataType builtInTypeToTypeIdentifier:[[[expression leftOperand] returnType] baseType]];
			NSString *rightOperandType = [YASLDataType builtInTypeToTypeIdentifier:[[[expression rigthOperand] returnType] baseType]];

			NSDictionary *operationProduction = [self pickProductionForOperation:operator leftOperand:leftOperandType rightOperand:rightOperandType];

			YASLDataType *returnType = operationProduction[kProductionResultType];
			YASLDataType *castType = operationProduction[kProductionCastType];

			if (!operationProduction) {
				returnType = [[expression leftOperand] returnType];
				castType = [[expression rigthOperand] returnType];
			}
			//			return nil;

			//		YASLDataType *returnType = operationProduction[kProductionResultType];
			//		YASLDataType *castType = operationProduction[kProductionCastType];
			Class processorClass = expressionProcessors[returnType.name];
			return processorClass
			? [[processorClass alloc] initWithDataTypesManager:self.declarationScope.globalTypesManager
																							 forSolver:self
																						withCastType:castType]
			: nil;
			break;
		}
		case 1: {
			YASLDataType *returnType = [[expression leftOperand] returnType];
			Class processorClass = expressionProcessors[returnType.name];

			return processorClass
			? [[processorClass alloc] initWithDataTypesManager:self.declarationScope.globalTypesManager
																							 forSolver:self
																						withCastType:returnType]
			: nil;
			break;
		}
		default:
			break;
	}
	NSLog(@"Can't pick processor for expression: %@", expression);
	return nil;
}

@end
