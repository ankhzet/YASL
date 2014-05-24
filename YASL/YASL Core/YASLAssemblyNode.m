//
//  YASLAssemblyNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssemblyNode.h"
#import "YASLToken.h"
#import "YASLGrammarNode.h"
#import "YASLAssembly.h"
#import "NSObject+TabbedDescription.h"

@implementation YASLAssemblyNode

- (NSString *) descriptionTabbed:(NSString *)tab {
#ifdef VERBOSE_ASSEMBLY
	NSString *stack = [self.tokensAssembly stackToStringFrom:self.bottomToken till:self.topToken withContext:YES];
	stack = [NSString stringWithFormat:@"[%@]", stack];
#else
	NSString *stack = @"";
#endif
	NSString *assembly = self.assembly ? [self.assembly descriptionTabbed:@""] : @"";
	assembly = self.assembly ? [NSString stringWithFormat:@"\n%@", assembly] : assembly;
	return [[NSString stringWithFormat:@"\nAN %@: %@%@\n", self.grammarNode.name, stack, assembly] descriptionTabbed:tab];
}

- (NSString *) description {
	return [self descriptionTabbed:[NSObject progressTab:@""]];
}

@end
