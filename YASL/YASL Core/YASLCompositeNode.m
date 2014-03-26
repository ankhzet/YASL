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

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	NSString *description = @"";
	for (YASLGrammarNode *node in self.subnodes) {
		description = [NSString stringWithFormat:@"%@%@%@", description, [description length] ? @"\n" : @"", [node description:circular]];
	}
	return [NSString stringWithFormat:@"\n%@", description];
}

- (void) addSubNode:(YASLGrammarNode *)subnode {
	[_subnodes addObject:subnode];
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	NSLog(@"hasChild: %p -> %p", self, child);
	for (YASLGrammarNode *node in self.subnodes)
		if ((node == child) || [node hasChild:child])
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

- (void) raiseMatch:(YASLAssembly *)match error:(NSString *)msg, ... {
}

@end
