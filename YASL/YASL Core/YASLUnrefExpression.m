//
//  YASLUnrefExpression.m
//  YASL
//
//  Created by Ankh on 25.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLUnrefExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLUnrefExpression

+ (instancetype) unrefExpressionInScope:(YASLDeclarationScope *)scope {
	YASLUnrefExpression *expression = [self expressionInScope:scope withType:YASLExpressionTypeUnreference];
	expression.isUnreference = YES;
	return expression;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	self.isUnary = YES;
	return self;
}

- (void) setIsUnreference:(BOOL)isUnreference {
	_isUnreference = isUnreference;
	self.specifier = isUnreference ? @"*" : @"&";
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"%@%@", self.specifier, [[self leftOperand] toString]];
}

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	YASLTranslationExpression *operand = [[self leftOperand] foldConstantExpressionWithSolver:solver];
	[self setNth:0 operand:operand];

	YASLDataType *dataType = operand.returnType;
	if (self.isUnreference) { // *expression
		if (dataType.isPointer) {
			dataType = operand.returnType.parent;
		} else {
			[self raiseError:@"Can't unreference non-pointer type \"%@\"", operand.returnType];
		}
	} else { // &expression
		dataType = [YASLDataType typeWithName:@""];
		dataType.isPointer++;
		dataType.parent = operand.returnType;
	}

	self.returnType = dataType;
	return self;
}

@end

@implementation YASLUnrefExpression (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
//	if (self.isUnreference) { // x = *expression
//		[outAssembly push:OPC_(MOV, REG_(R0), [REG_(R0) asPointer])];
//	} else { // x = &expression
//					 // leave as it is
//	}
	return YES;
}

- (void) assemble:(YASLAssembly *)assembly {
	YASLTranslationExpression *operand = [self leftOperand];
	[operand assemble:assembly unPointered:NO];
	if (self.isUnreference) { // x = *expression
		[assembly push:OPC_(MOV, REG_(R0), [REG_(R0) asPointer])];
	} else { // x = &expression
					 // leave as it is
	}
}

@end
