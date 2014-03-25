//
//  YASLMethodCallExpression.m
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLMethodCallExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLMethodCallExpression

+ (instancetype) methodCallInScope:(YASLDeclarationScope *)scope {
	YASLMethodCallExpression *methodCall = [YASLMethodCallExpression expressionInScope:scope withType:YASLExpressionTypeCall andSpecifier:@", "];
	return methodCall;
}

- (void) setMethodAddress:(YASLTranslationExpression *)methodAddress {
	if (_methodAddress == methodAddress)
		return;

	_methodAddress = methodAddress;
	self.returnType = methodAddress.returnType;
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

	self.methodAddress = [self.methodAddress foldConstantExpressionWithSolver:solver];
	self.returnType = self.methodAddress.returnType;

	return self;
}

- (NSString *) toString {
	NSString *params = [[[self nodesEnumerator:NO] allObjects] componentsJoinedByString:self.specifier];
	return [NSString stringWithFormat:@"%@(%@)", self.methodAddress, params];
}

@end

@implementation YASLMethodCallExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	for (YASLTranslationExpression *param in [self nodesEnumerator:YES]) {
		[param assemble:assembly unPointered:YES];
		[assembly push:OPC_(PUSH, REG_(R0))];
	}

	NSString *functionIdentifier = self.methodAddress.specifier;
//	YASLLocalDeclaration *function = [self.declarationScope localDeclarationByIdentifier:functionIdentifier];
	YASLNativeFunction *native = [[YASLNativeFunctions sharedFunctions] findByName:functionIdentifier];
	if (native) {
		[assembly push:OPC_(NATIV, IMM_(@(native.GUID)))];
	} else {
		[self.methodAddress assemble:assembly unPointered:NO];
		[assembly push:OPC_(CALL, REG_(R0))];
	}
}

@end
