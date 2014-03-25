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
	[YASLTranslationNodeTypeExpression] = @"exp",
	[YASLTranslationNodeTypeInitializer] = @"init",
	[YASLTranslationNodeTypeFunction] = @"function",
	[YASLTranslationNodeTypeRoot] = @"unit",
};

@interface YASLTranslationNode ()
@end

@implementation YASLTranslationNode {
	@protected
	NSMutableArray *subnodes;
}

+ (instancetype) nodeInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type {
	return [(YASLTranslationNode *)[self alloc] initInScope:scope withType:type];
}

- (id)initInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type {
	if (!(self = [super init]))
		return self;

	_type = type;
	_declarationScope = scope;
	subnodes = [NSMutableArray array];
	return self;
}

@end

@implementation YASLTranslationNode (SubNodesManagement)

- (void) addSubNode:(YASLTranslationNode *)subnode {
	[subnodes addObject:subnode];
	subnode.parent = self;
}

- (void) removeSubNode:(YASLTranslationNode *)subnode {
	[subnodes removeObject:subnode];
	subnode.parent = nil;
}

- (NSEnumerator *) nodesEnumerator:(BOOL)reverse {
	return [YASLNoNullsEnumerator enumeratorWithArray:subnodes reverse:reverse];
}

- (NSUInteger) nodesCount {
	return [[[self nodesEnumerator:NO] allObjects] count];
}

- (id) nthOperand:(NSUInteger)idx {
	id e = [subnodes count] > idx ? subnodes[idx] : nil;
	if (e != [NSNull null]) {
		return e;
	}
	return nil;
}

- (void) setNth:(NSUInteger)idx operand:(YASLTranslationExpression *)operand {
	if (!operand)
		operand = (id)[NSNull null];

	NSUInteger count = [subnodes count];
	while (count < idx) {
		[self setNth:count++ operand:nil];
	}

	if (count == idx)
		[subnodes addObject:operand];
	else
		subnodes[idx] = operand;
}

- (id) leftOperand {
	return [self nthOperand:0];
}

- (id) rigthOperand {
	return [self nthOperand:1];
}

- (id) thirdOperand {
	return [self nthOperand:2];
}

- (void) setSubNodes:(NSArray *)array {
	subnodes = [array mutableCopy];
	for (YASLTranslationNode *subnode in subnodes) {
    subnode.parent = self;
	}
}

@end

@implementation YASLTranslationNode (Debug)

- (NSString *) toString {
	NSString *type = YASLTranslationNodeTypeNames[self.type];
	type = type ? type : [NSString stringWithFormat:@"TN::%u", self.type];
	NSString *subs = @"";
	for (YASLTranslationNode *subnode in [self nodesEnumerator:NO]) {
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

- (BOOL) unPointer:(YASLAssembly *)outAssembly {
	return NO;
}

- (void) assemble:(YASLAssembly *)assembly unPointered:(BOOL)unPointered {
	if (self.sourceLine) {
		[assembly push:[YASLCodeAddressReference referenceWithName:[NSString stringWithFormat:@"Line #%u", self.sourceLine]]];
	}
	[self assemble:assembly];
	if (unPointered)
		[self unPointer:assembly];
}

- (void) assemble:(YASLAssembly *)assembly {
	for (YASLTranslationNode *node in [self nodesEnumerator:NO])
    [node assemble:assembly unPointered:NO];
}

@end
