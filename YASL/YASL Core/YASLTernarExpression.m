//
//  YASLTernarExpression.m
//  YASL
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTernarExpression.h"
#import "NSObject+TabbedDescription.h"

@implementation YASLTernarExpression

+ (instancetype) ternarExpression {
	YASLTernarExpression *expression = [self nodeWithType:YASLTranslationNodeTypeExpression];
	expression.expressionType = YASLExpressionTypeTernar;
	expression.specifier = @"?:";
	return expression;
}

- (NSString *) toString {
	NSString *subs = [[NSString stringWithFormat:@"  %@\n? %@\n: %@",
										[self.subnodes[0] toString], [self.subnodes[1] toString], [self.subnodes[2] toString]] descriptionTabbed:@"  "];

	return [NSString stringWithFormat:@"(\n%@\n)", subs];
}


@end
