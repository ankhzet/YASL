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
#import "YASLToken.h"
#import "YASLNonfatalException.h"
#import "YASLAPI.h"

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
	id tokensMarker = [match top];

	NSUInteger assemblyState = [assembly pushState];
#ifndef VERBOSE_SYNTAX_ERRORS
	NSUInteger errorState = [assembly pushExceptionStackState];
#endif

	@try {
#ifdef VERBOSE_SYNTAX
		if (self.name) {
			NSLog(@"%@:", self.name);
		}
#endif
		BOOL matches = [self matches:match for:assembly];
#ifdef VERBOSE_SYNTAX
		if (self.name && matches) {
			NSString *matchedTokensStr = [match stackToStringFrom:tokensMarker till:[match top] withContext:YES];
			if ([matchedTokensStr length]) {
				NSDictionary *YN = @{@YES: @"+", @NO: @" "};
				NSLog(@"%@%@: %@\n%@\n", YN[@(matches)], self.name, matchedTokensStr, match);
			}
		}
#endif
    if (matches) {
#ifndef VERBOSE_SYNTAX_ERRORS
			[assembly popExceptionStackState:errorState];
#endif
			if (self.discard) {
				NSArray *tokensArray = [match objectsAbove:[match top] belove:tokensMarker];
				if ([tokensArray count]) {
//					NSLog(@"discard: %@ -> %@", tokensArray, assembly->discards);
					[assembly pushDiscards:[match total] - state];
					for (id object in tokensArray)
						[assembly alwaysDiscard:object inGlobalScope:NO];
//					NSLog(@"discard: %@ -> %@", tokensArray, assembly->discards);
				}
			}

			if (!self.name)
				return YES;

			id topMarker = [NSObject new];
			[assembly push:topMarker];
			[assembly popState:assemblyState];
			id bottommarker = [assembly top];

			NSArray *assembliesArray = [assembly objectsAbove:bottommarker belove:topMarker];
			YASLAssembly *assemblies = nil;
			NSInteger c = [assembliesArray count] - 1;
			if (c > 0) {
				assembliesArray = [assembliesArray subarrayWithRange:NSMakeRange(1, c)];
				assemblies = [[YASLAssembly alloc] initWithArray:assembliesArray];
			}

			YASLAssemblyNode *an = [YASLAssemblyNode new];
			an.grammarNode = self;
			an.assembly = assemblies;
			an.tokensRange = NSMakeRange(state, state - [match pushState]);
#ifdef VERBOSE_ASSEMBLY
			an.tokensAssembly = match;
			an.topToken = [match top];
			an.bottomToken = tokensMarker;
#endif
			[assembly dropPopped];
			[assembly push:an];
			return YES;
		} else {
			[match popState:state];
			[self raiseAtAssembly:assembly match:match];
		}
	}
	@catch (YASLNonfatalException *exception) {

	}

	[assembly popState:assemblyState];
	[assembly dropDiscardsAfterState:[match total] - state - 1];
	[assembly dropPopped];

	return NO;
}

- (void) raiseAtAssembly:(YASLAssembly *)assembly match:(YASLAssembly *)match {
	id token = [match top];
	while (token && ![token isKindOfClass:[YASLToken class]]) {
		token = [match pushBack];
	}

	YASLNonfatalException *exception = [self exceptionOnToken:token inAssembly:assembly];
	if (token) {
		exception.atLine = ((YASLToken *)token).line;
		exception.atCollumn = ((YASLToken *)token).collumn;
		exception.atToken = ((YASLToken *)token).value;
	}

	@throw exception;
}

- (YASLNonfatalException *) exceptionOnToken:(YASLToken *)token inAssembly:(YASLAssembly *)assembly {
	YASLNonfatalException *exception = [YASLNonfatalException exceptionWithMsg:@"Failed to assemble node"];
	return exception;
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	NSAssert(false, @"%s should be overriden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
	return NO;
}

- (id) copyWithZone:(NSZone *)zone {
	return self;
}

@end

@implementation YASLGrammarNode (StringRepresentation)

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
