//
//  YASLIdentifierNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLIdentifierNode.h"
#import "YASLToken.h"
#import "YASLAssembly.h"

@implementation YASLIdentifierNode

- (void) dealloc {
	self.link = nil;
}

- (NSString *) nodeType {
	return [NSString stringWithFormat:@"%@:%@", [super nodeType], [self identifier]];
}

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	if (self.link) {
		return [NSString stringWithFormat:@"(<%@> ::= %@)", self.identifier, [self.link description:circular]];
	}

	return [NSString stringWithFormat:@"\n%@", self.identifier];
}

- (BOOL) hasChild:(YASLGrammarNode *)child {
	return (self.link == child) || [self.link hasChild:child];
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	if (!self.link) {
		YASLToken *token = [match pop];
		return token.kind == YASLTokenKindIdentifier;
	}

	return [self.link match:match andAssembly:assembly];
}

- (YASLNonfatalException *) exceptionOnToken:(YASLToken *)token inAssembly:(YASLAssembly *)assembly {
	NSString *identifier = [self.link.name stringByReplacingOccurrencesOfString:@"-" withString:@" "];
	YASLNonfatalException *exception = [YASLNonfatalException exceptionWithMsg:@"Failed to assemble \"%@\"", identifier];
	[assembly pushException:exception];
	return exception;
}

@end
