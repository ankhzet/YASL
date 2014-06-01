//
//  YASLArrayElementExpression.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLArrayElementExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLArrayElementExpression {
	YASLTranslationExpression *elementAddress;
	BOOL isFolded;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	isFolded = NO;
	return self;
}

- (void) setNth:(NSUInteger)idx operand:(YASLTranslationNode *)operand {
	[super setNth:idx operand:operand];
	isFolded = NO;
}

- (void) setSubNodes:(NSArray *)array {
	[super setSubNodes:array];
	isFolded = NO;
}

+ (instancetype) arrayElementInScope:(YASLDeclarationScope *)scope {
	YASLArrayElementExpression *element = [YASLArrayElementExpression expressionInScope:scope withType:YASLExpressionTypeArray andSpecifier:@""];
	return element;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@[%@]", [[self leftOperand] toString], [[self rigthOperand] toString]];
}

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	if (isFolded)
		return self;

	NSMutableArray *foldedOperands = [@[] mutableCopy];
	int nonConstants = 0;
	// first, try to fold operands
	for (YASLTranslationExpression *operand in [self nodesEnumerator:NO]) {
		YASLTranslationExpression *folded = [operand foldConstantExpressionWithSolver:solver];
    [foldedOperands addObject:folded];
		if (folded.expressionType != YASLExpressionTypeConstant)
			nonConstants++;
	}

	YASLTranslationExpression *arrayAddres = foldedOperands[0];
	YASLTranslationExpression *arrayIndex = foldedOperands[1];

	YASLArrayDataType *arrayType = (id)arrayAddres.returnType;
	BOOL isArray = [arrayType isKindOfClass:[YASLArrayDataType class]];
	BOOL isPointer = !!arrayType.isPointer;
	if (isPointer) {
		YASLUnrefExpression *unref = [YASLUnrefExpression unrefExpressionInScope:self.declarationScope];
		[unref addSubNode:arrayAddres];
		unref.isUnreference = YES; // *array + idx * elementSize
		[self setSubNodes:@[unref, arrayIndex]];
		return [self foldConstantExpressionWithSolver:solver];
	}

	self.returnType = (isArray || isPointer) ? arrayType.parent : arrayType;

	NSUInteger offset = [self.returnType sizeOf];
	YASLTranslationConstant *offsetConstant = [YASLTranslationConstant constantInScope:self.declarationScope withType:[self.declarationScope typeByName:YASLBuiltInTypeIdentifierInt] andValue:@(offset)];

	YASLTranslationExpression *indexAddress = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorMul]];

	[indexAddress addSubNode:arrayIndex];
	[indexAddress addSubNode:offsetConstant];

	indexAddress = [indexAddress foldConstantExpressionWithSolver:solver];

	BOOL isConstantIndexOffset = indexAddress.expressionType == YASLExpressionTypeConstant;
	if (isConstantIndexOffset && ![(YASLTranslationConstant *)indexAddress toInteger])
		elementAddress = arrayAddres;
	else {
		elementAddress = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorAdd]];

		YASLUnrefExpression *addrRef = [YASLUnrefExpression unrefExpressionInScope:self.declarationScope];
		addrRef.isUnreference = NO; // &expression
		[addrRef addSubNode:arrayAddres];
		YASLTypecastExpression *typecast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:[self typeByName:YASLBuiltInTypeIdentifierInt]];
		[typecast addSubNode:addrRef];
		[elementAddress addSubNode:typecast];
		[elementAddress addSubNode:indexAddress];

		elementAddress = [elementAddress foldConstantExpressionWithSolver:solver];
		elementAddress.returnType = self.returnType;
	}

	isFolded = YES;
	return self;
}

@end

@implementation YASLArrayElementExpression (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	[outAssembly push:OPC_(MOV, REG_(R0), [REG_(R0) asPointer])];
	return YES;
}

- (void) assemble:(YASLAssembly *)assembly {
	[elementAddress assemble:assembly unPointered:NO];
}

@end
