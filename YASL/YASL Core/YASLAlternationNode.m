//
//  YASLAlternationNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAlternationNode.h"

@implementation YASLAlternationNode

- (NSString *) description {
	return [NSString stringWithFormat:@"(%@)", [self.subnodes componentsJoinedByString:@" | "]];
}

//

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	for (YASLGrammarNode *node in self.subnodes) {
    BOOL state = [node match:match andAssembly:assembly];
		if (state)
			return YES;
	}
	return NO;
}

@end
