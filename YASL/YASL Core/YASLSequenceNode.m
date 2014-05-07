//
//  YASLSequenceNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLSequenceNode.h"

@implementation YASLSequenceNode

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	for (YASLGrammarNode *node in self.subnodes) {
    BOOL state = [node match:match andAssembly:assembly];
		if (!state)
			return NO;
	}
	return YES;
}

@end
