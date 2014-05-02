//
//  YASLCompositeNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCompositeNode.h"

@implementation YASLCompositeNode

- (id)init {
	if (!(self = [super init]))
		return self;

	_subnodes = [NSMutableArray array];
	return self;
}

- (void) addSubNode:(YASLGrammarNode *)subnode {
	[_subnodes addObject:subnode];
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	if ([self.subnodes containsObject:child])
		return YES;

	Class composite = [YASLCompositeNode class];
	for (YASLGrammarNode *node in self.subnodes)
		if ([node isKindOfClass:composite] && [(YASLCompositeNode *)node hasChild:child])
			return YES;

	return NO;
}

- (BOOL) walkTreeWithBlock:(YASLGrammarNodeWalkBlock)walkBlock andUserData:(id)userdata {
	if (![super walkTreeWithBlock:walkBlock andUserData:userdata])
		return YES;

	for (YASLGrammarNode *node in self.subnodes) {
    if (![node walkTreeWithBlock:walkBlock andUserData:userdata])
			;
//			return NO;
	}

	return YES;
}

@end
