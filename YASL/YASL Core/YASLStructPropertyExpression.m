//
//  YASLStructPropertyExpression.m
//  YASLVM
//
//  Created by Ankh on 31.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStructPropertyExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLStructPropertyExpression {
	NSUInteger offset;
}

+ (instancetype) structProperty:(NSString *)identifier inScope:(YASLDeclarationScope *)scope {
	YASLStructPropertyExpression *prop = [self expressionInScope:scope withType:YASLExpressionTypeArray andSpecifier:identifier];
	return prop;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@.%@", [[self leftOperand] toString], self.specifier];
}

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *structOperand = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	YASLStructDataType *structType = (id)structOperand.returnType;
	if (structType.isPointer) {
		YASLUnrefExpression *unref = [YASLUnrefExpression unrefExpressionInScope:self.declarationScope];
		[unref addSubNode:structOperand];
		unref.isUnreference = YES;
		[self setSubNodes:@[unref]];
		return [self foldConstantExpressionWithSolver:solver];
	}
	if (![structType isKindOfClass:[YASLStructDataType class]])
		[self raiseError:@"Struct type expected, %@ found", structType.name];

	if (![structType hasProperty:self.specifier])
		[self raiseError:@"Struct %@ has no property %@", structType.name, self.specifier];

	[self setSubNodes:@[structOperand]];
	self.returnType = [structType propertyType:self.specifier];
	offset = [structType propertyOffset:self.specifier];

	return self;
}

@end

@implementation YASLStructPropertyExpression (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	[outAssembly push:OPC_(MOV, REG_(R0), [REG_(R0) asPointer])];
	return YES;
}

- (void) assemble:(YASLAssembly *)assembly {
	YASLTranslationExpression *structOperand = [self leftOperand];
	[structOperand assemble:assembly unPointered:NO];
	if (offset)
		[assembly push:OPC_(ADD, REG_(R0), IMM_(@(offset)))];
}

@end
