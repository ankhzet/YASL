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
	YASLTranslationConstant *offsetConstant;
	YASLTranslationExpression *elementAddress;
}

+ (instancetype) arrayElementInScope:(YASLDeclarationScope *)scope {
	YASLArrayElementExpression *element = [YASLArrayElementExpression expressionInScope:scope withType:YASLExpressionTypeArray andSpecifier:@""];
	return element;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@[%@]", [[self leftOperand] toString], [[self rigthOperand] toString]];
}

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
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

	self.returnType = arrayAddres.returnType.parent;

	NSUInteger offset = [self.returnType sizeOf];
	offsetConstant = [YASLTranslationConstant constantInScope:self.declarationScope withType:[self.declarationScope.localDataTypesManager typeByName:YASLBuiltInTypeIdentifierInt] andValue:@(offset)];

	YASLTranslationExpression *indexAddress = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorMul]];

	[indexAddress addSubNode:arrayIndex];
	[indexAddress addSubNode:offsetConstant];

	indexAddress = [indexAddress foldConstantExpressionWithSolver:solver];

	BOOL isConstantIndexOffset = indexAddress.type != YASLTranslationNodeTypeConstant;
	if ((!isConstantIndexOffset) || [((YASLTranslationConstant *)indexAddress).value intValue]) {
		elementAddress = [YASLTranslationExpression expressionInScope:self.declarationScope withType:YASLExpressionTypeBinary andSpecifier:[YASLTranslationExpression operatorToSpecifier:YASLExpressionOperatorAdd]];

		[elementAddress addSubNode:arrayAddres];
		[elementAddress addSubNode:indexAddress];

		elementAddress = [elementAddress foldConstantExpressionWithSolver:solver];
		elementAddress.returnType = self.returnType;
	} else
		elementAddress = arrayAddres;

	return elementAddress;
}

@end

@implementation YASLArrayElementExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	[elementAddress assemble:assembly];
}

@end
