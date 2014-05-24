//
//  YASLCompoundExpression.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCompoundExpression.h"

@implementation YASLCompoundExpression

+ (instancetype) compoundExpressionInScope:(YASLDeclarationScope *)scope {
	YASLCompoundExpression *expression = [self expressionInScope:scope withType:YASLExpressionTypeAssignment];
	return expression;
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
	[self setSubNodes:foldedOperands];
	return self;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"{\n%@\n}", [[[self nodesEnumerator:NO] allObjects] componentsJoinedByString:@";\n"]];
}

@end

@implementation YASLCompoundExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	for (YASLTranslationNode *statement in [self nodesEnumerator:NO])
		[statement assemble:assembly];
}

@end
