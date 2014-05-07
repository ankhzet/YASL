//
//  YASLTranslationExpression.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"
#import "NSObject+TabbedDescription.h"
#import "YASLTranslationConstant.h"

@implementation YASLTranslationExpression

+ (instancetype) expressionWithType:(YASLExpressionType)type andSpecifier:(NSString *)specifier {
	YASLTranslationExpression *expression = [self nodeWithType:YASLTranslationNodeTypeExpression];
	expression.expressionType = type;
	expression.specifier = specifier;
	return expression;
}

/*! Try to evaluate this expression. If it consists from constant operands, then result will be evaluated constant value, else returns self. */
- (YASLTranslationExpression *) foldConstantExpression {
	if (self.expressionType == YASLExpressionTypeConstant)
		return self;

	NSMutableArray *foldedOperands = [@[] mutableCopy];
	int nonConstants = 0;
	// first, try to fold operands
	for (YASLTranslationExpression *operand in self.subnodes) {
		YASLTranslationExpression *folded = [operand foldConstantExpression];
    [foldedOperands addObject:folded];
		if (folded.expressionType != YASLExpressionTypeConstant)
			nonConstants++;
	}
	self.subnodes = foldedOperands;

	// there are non-constant operands
	if (nonConstants)
		return self;

	// try evaluate operands
	//TODO: constant expressions evaluation
	YASLTranslationConstant *result = [YASLTranslationConstant constantWithType:YASLConstantTypeInt andValue:@(0)];
	return result;
}

- (NSString *) toString {
	NSString *delim = [NSString stringWithFormat:@" %@\n", self.specifier];
	NSString *subs = @"";
	for (YASLTranslationNode *subnode in self.subnodes) {
    subs = [NSString stringWithFormat:@"%@%@%@", subs, ([subs length] ? delim : @""), [[subnode toString] descriptionTabbed:@"  "]];
	}
	subs = [subs length] ? subs : self.specifier;

	return [NSString stringWithFormat:@"(\n%@\n)", subs];
}


@end
