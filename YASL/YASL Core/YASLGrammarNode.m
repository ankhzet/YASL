//
//  YASLGrammarNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLGrammarNode.h"
#import "YASLAssembly.h"
#import "YASLAssemblyNode.h"
#import "NSObject+TabbedDescription.h"

NSString *const kAssemblyDataTokensAssembly = @"kAssemblyDataTokensAssembly";

@implementation YASLGrammarNode

- (NSString *) nodeType {
	return NSStringFromClass([self class]);
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	return NO;
}

- (BOOL) walkTreeWithBlock:(YASLGrammarNodeWalkBlock)walkBlock andUserData:(id)userdata {
	return walkBlock(userdata, self);
}

- (BOOL) match:(YASLAssembly *)match andAssembly:(YASLAssembly *)assembly {
	NSUInteger state = [match pushState];
	NSUInteger assemblyState = [assembly pushState];
	id marker = [match top];
	@try {
    if ([self matches:match for:assembly]) {
			if (!self.name) {
				return YES;
			}
			YASLAssembly *tokensAssembly = assembly.userData[kAssemblyDataTokensAssembly];
			if (!tokensAssembly) {
				tokensAssembly = assembly.userData[kAssemblyDataTokensAssembly] = [match copy];
				[tokensAssembly restoreFullStack];
			}

//			NSArray *tokensArray = [match objectsAbove:[match top] belove:marker];

			YASLAssemblyNode *an = [YASLAssemblyNode new];
			[assembly push:an];
			[assembly popState:assemblyState];
			NSArray *assembliesArray = [assembly objectsAbove:[assembly top] belove:an];
			YASLAssembly *assemblies = nil;
			if ([assembliesArray count] > 1) {
				assembliesArray = [assembliesArray mutableCopy];
				[((NSMutableArray *)assembliesArray) removeObject:[assembliesArray firstObject]];
				assemblies = [[YASLAssembly alloc] initWithArray:assembliesArray];
//				[assemblies pop];
//				[assemblies discardPopped];
			}

			an.grammarNode = self;
			an.assembly = assemblies;
			an.tokensAssembly = tokensAssembly;
			an.topToken = [match top];
			an.bottomToken = marker;
			an.tokensRange = NSMakeRange(state, state - [match pushState]);
//			NSLog(@"%@\n%@\n\n", [tokensAssembly stackToStringFrom:an.bottomToken till:an.topToken], [[YASLAssembly alloc] initReverseArray:tokensArray]);
			[assembly discardPopped];
			[assembly push:an];
			return YES;
		}
	}
	@catch (NSException *exception) {
	}
	[match popState:state];

	return NO;
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	NSAssert(false, @"%s should be overriden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
	return NO;
}

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

- (NSString *) description {
	NSMutableSet *circular = [NSMutableSet set];
	return [self description:circular];
}

- (NSString *) description:(NSMutableSet *)circular {
	NSString *description = nil;
	if ([circular member:self]) {
		description = [NSString stringWithFormat:@"<%@:recursion>", self.name ? self.name : [self nodeType]];
	} else {
		[circular addObject:self];
		description = [self unsafeDescription:circular];
		[circular removeObject:self];
	}

	return [[[NSString stringWithFormat:@"%@%@", description, self.discard ? @"!" : @""] descriptionTabbed:@"  "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	return [NSString stringWithFormat:@"(%@)", [self nodeType]];
}

@end
