//
//  YASLTranslationNode.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"
#import "YASLCoreLangClasses.h"

NSString *const YASLTranslationNodeTypeNames[] = {
	[YASLTranslationNodeTypeConstant] = @"const",
	[YASLTranslationNodeTypeExpression] = @"exp",
	[YASLTranslationNodeTypeInitializer] = @"init",
	[YASLTranslationNodeTypeFunction] = @"function",
	[YASLTranslationNodeTypeRoot] = @"unit",
};


@implementation YASLTranslationNode

+ (instancetype) nodeInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type {
	return [(YASLTranslationNode *)[self alloc] initInScope:scope withType:type];
}

- (id)initInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type {
	if (!(self = [super init]))
		return self;

	_type = type;
	_declarationScope = scope;
	_subnodes = [NSMutableArray array];
	return self;
}

- (void) addSubNode:(YASLTranslationNode *)subnode {
	[_subnodes addObject:subnode];
	subnode.parent = self;
}

- (void) removeSubNode:(YASLTranslationNode *)subnode {
	[_subnodes removeObject:subnode];
	subnode.parent = nil;
}

- (NSString *) toString {
	NSString *type = YASLTranslationNodeTypeNames[self.type];
	type = type ? type : [NSString stringWithFormat:@"TN::%u", self.type];
	NSString *subs = @"";
	for (YASLTranslationNode *subnode in self.subnodes) {
    subs = [NSString stringWithFormat:@"%@%@%@", subs, ([subs length] ? @",\n" : @""), [[subnode toString] descriptionTabbed:@"  "]];
	}
	subs = [subs length] ? [NSString stringWithFormat:@": {\n%@\n}", subs] : subs;
	return [[NSString stringWithFormat:@"[%@]%@", type, subs] descriptionTabbed:@""];
}

- (NSString *) description {
	return [self toString];
}

@end

@implementation YASLTranslationNode (Assembling)

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	for (YASLTranslationNode *node in self.subnodes) {
    if (![node assemble:assembly unPointer:unPointer])
			return NO;
	}

	return YES;
}

@end
