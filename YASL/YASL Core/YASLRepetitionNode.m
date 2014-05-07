//
//  YASLRepetitionNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLRepetitionNode.h"

NSString *const YASLRepetitionSpecifierNames[YASLRepetitionSpecifierMAX] = {
	[YASLRepetitionSpecifierOnce] = @"?",
	[YASLRepetitionSpecifierAtLeastOnce] = @"+",
	[YASLRepetitionSpecifierAny] = @"*",
};

@implementation YASLRepetitionNode

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	return [NSString stringWithFormat:@"{%@\n}%@", [self.linked description:circular], YASLRepetitionSpecifierNames[self.specifier]];
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	return (self.linked == child) || ([self.linked hasChild:child]);
}

+ (YASLRepetitionSpecifier) parseSpecifier:(NSString *)specifier {
	if ([specifier isEqualToString:YASLRepetitionSpecifierNames[YASLRepetitionSpecifierOnce]]) {
		return YASLRepetitionSpecifierOnce;
	} else
		if ([specifier isEqualToString:YASLRepetitionSpecifierNames[YASLRepetitionSpecifierAtLeastOnce]]) {
			return YASLRepetitionSpecifierAtLeastOnce;
		} else
			if ([specifier isEqualToString:YASLRepetitionSpecifierNames[YASLRepetitionSpecifierAny]]) {
				return YASLRepetitionSpecifierAny;
			} else
				return YASLRepetitionSpecifierNone;
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	BOOL state = [self.linked match:match andAssembly:assembly];

	switch (self.specifier) {
		case YASLRepetitionSpecifierOnce:
			return YES;

		case YASLRepetitionSpecifierAtLeastOnce:
			if (!state)
				return NO;

		case YASLRepetitionSpecifierAny:
			while (state) {
				state = [self.linked match:match andAssembly:assembly];
			}
			return YES;

		default:;
	}
	return NO;
}

- (BOOL) walkTreeWithBlock:(YASLGrammarNodeWalkBlock)walkBlock andUserData:(id)userdata {
	if (![super walkTreeWithBlock:walkBlock andUserData:userdata])
		return YES;

	[self.linked walkTreeWithBlock:walkBlock andUserData:userdata];

	return YES;
}

@end
