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

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	NSMutableArray *foldedOperands = [[[self nodesEnumerator:NO] allObjects] mutableCopy];
	[foldedOperands removeObjectAtIndex:0];

	YASLTranslationExpression *method = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	self.returnType = method.returnType;


	if (method.expressionType == YASLExpressionTypeVariable) {
		YASLLocalDeclaration *functionPrototype = [method.declarationScope localDeclarationByIdentifier:method.specifier];
		YASLAssembly *specifiers = functionPrototype.declarator.declaratorSpecifiers;
		NSMutableArray *params = [NSMutableArray array];
		YASLAssembly *specifiersCopy = [specifiers copy];
		while ([specifiersCopy notEmpty]) {
			YASLDeclaratorSpecifier *specifier = [specifiersCopy pop];
			if (specifier.type == YASLTranslationNodeTypeFunction) {
				for (YASLLocalDeclaration *param in specifier.elements) {
					[params addObject:param.dataType];
				}
			}
		}
		if ([params count] != [foldedOperands count])
			[self raiseError:@"Method parameters count mismatch, %lu expected, %lu provided", [params count], [foldedOperands count]];

		NSUInteger count = [foldedOperands count];
		for (int i = 0; i < count; i++) {
			YASLTranslationExpression *param = [foldedOperands[i] foldConstantExpressionWithSolver:solver];
			YASLDataType *expectedType = params[count - i - 1];
			if (expectedType != param.returnType) {
				YASLTypecastExpression *typecast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:expectedType];
				[typecast addSubNode:param];
				foldedOperands[i] = [typecast foldConstantExpressionWithSolver:solver];
			}
		}
	}

	[self setSubNodes:[@[method] arrayByAddingObjectsFromArray:foldedOperands]];

	return self;
}

- (NSString *) toString {
	NSMutableArray *operands = [[[self nodesEnumerator:YES] allObjects] mutableCopy];
	YASLTranslationExpression *method = [operands lastObject];
	[operands removeLastObject];
	NSString *params = [operands componentsJoinedByString:self.specifier];
	return [NSString stringWithFormat:@"%@(%@)", method, params];
}

@end

@implementation YASLMethodCallExpression (Assembling)

- (void) assemble:(YASLAssembly *)assembly {
	YASLTranslationExpression *method = [self leftOperand];
	for (YASLTranslationExpression *param in [self nodesEnumerator:YES])
		if (param == method)
			continue;
	else {
		[param assemble:assembly unPointered:YES];
		[assembly push:OPC_(PUSH, REG_(R0))];
	}

	NSString *functionIdentifier = method.specifier;
	YASLNativeFunction *native = [[YASLNativeFunctions sharedFunctions] findByName:functionIdentifier];
	if (native) {
		[assembly push:OPC_(NATIV, IMM_(@(native.GUID)))];
	} else {
		[method assemble:assembly unPointered:NO];
		[assembly push:OPC_(CALL, REG_(R0))];
	}
}

@end
