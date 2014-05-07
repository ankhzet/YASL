//
//  YASLGrammar.m
//  YASL
//
//  Created by Ankh on 02.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammar.h"

@implementation YASLGrammar

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	return [self.rootNode description:circular];
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	return (self.rootNode == child) || ([self.rootNode hasChild:child]);
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	return [self.rootNode match:match andAssembly:assembly];
}

@end
