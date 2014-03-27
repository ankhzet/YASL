//
//  YASLOperationProductionsAssembler.m
//  YASL
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLOperationProductionsAssembler.h"
#import "YASLCoreLangClasses.h"
#import "YASLExpressionProcessor.h"

NSString *const YASLOperationProductionsGrammar = @"YASLOP";
NSString *const kProductionOperands = @"kProductionOperands";
NSString *const kProductionOperations = @"kProductionOperations";
NSString *const kProductionFilter = @"kProductionFilter";
NSString *const kProductionTypeIdentifier = @"kProductionTypeIdentifier";
NSString *const kProductions = @"kProductions";
NSString *const kProductionTypeOperand = @"kProductionTypeOperand";
NSString *const kProductionTypeCast = @"kProductionTypeCast";

@implementation YASLOperationProductionsAssembler

- (NSString *) grammarIdentifier {
	return YASLOperationProductionsGrammar;
}

@end

@implementation YASLOperationProductionsAssembler (Processors)

- (void) processAssembly:(YASLAssembly *)a nodeOperand:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	[a push:token.value];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperation:(YASLAssemblyNode *)node {
	YASLToken *token = [a pop];
	YASLExpressionOperator operation = [YASLTranslationExpression specifierToOperator:token.value unary:NO];
	if ((operation == YASLExpressionOperatorUnknown) && (![token.value isEqualToString:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorUnknown]])) {
		[self raiseError:@"Unknown operation identifier: \"%@\"",token.value];
	}
	[a push:@(operation)];
}

- (void) processAssembly:(YASLAssembly *)a nodeRightOperandProductions:(YASLAssemblyNode *)node {
	NSDictionary *productionResult = [a pop];
	NSArray *filter = [a pop];
	NSArray *rightOperands = [a popTillChunkMarker];
	if (!rightOperands) {
		rightOperands = filter;
		filter = @[];
	}


	NSDictionary *production = @{kProductionOperands: rightOperands, kProductionFilter: filter, kProductionTypeIdentifier: productionResult};
	[a push:production];
}

- (void) processAssembly:(YASLAssembly *)a nodeCastOperand:(YASLAssemblyNode *)node {
	NSString *operand = [a pop];
	NSString *cast = [a popTillChunkMarker];
	if (!cast) {
		cast = operand;
	}

	[a push:@{kProductionTypeOperand: operand, kProductionTypeCast: cast}];
}


- (void) processAssembly:(YASLAssembly *)a nodeLeftOperandProductions:(YASLAssemblyNode *)node {
	NSArray *productionsList = [a pop];
	NSArray *filter = [a pop];
	NSArray *leftOperands = [a popTillChunkMarker];
	if (!leftOperands) {
		leftOperands = filter;
		filter = @[];
	}

	NSDictionary *productions = @{kProductionOperands: leftOperands, kProductionFilter: filter, kProductions: productionsList};
	[a push:productions];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperationProduction:(YASLAssemblyNode *)node {
	NSArray *productionsList = [a pop];
	NSArray *operations = [a pop];
	NSDictionary *productions = @{kProductionOperations: operations, kProductions: productionsList};
	[a push:productions];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperandTypesList:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperationList:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperandProductions:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeProductions:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

- (void) processAssembly:(YASLAssembly *)a nodeOperationProductions:(YASLAssemblyNode *)node {
	[self fetchArray:a];
}

@end
