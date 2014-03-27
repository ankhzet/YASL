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
	NSMutableArray *foldedOperands = [[[self nodesEnumerator:NO] allObjects] mutableCopy];

	YASLTranslationExpression *method = [self.methodAddress foldConstantExpressionWithSolver:solver];
  self.methodAddress = method;
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
			YASLTranslationExpression *param = foldedOperands[i];
			YASLDataType *expectedType = params[count - i - 1];
			if (expectedType != param.returnType) {
				YASLTypecastExpression *typecast = [YASLTypecastExpression typecastInScope:self.declarationScope withType:expectedType];
				[typecast addSubNode:param];
				foldedOperands[i] = [typecast foldConstantExpressionWithSolver:solver];
			}
		}
	}

	[self setSubNodes:foldedOperands];

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
