//
//  YASLTranslationNode.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"
#import "NSObject+TabbedDescription.h"

NSString *const YASLTranslationNodeTypeNames[] = {
	[YASLTranslationNodeTypeConstant] = @"const",
	[YASLTranslationNodeTypeExpression] = @"exp",
	[YASLTranslationNodeTypeInitializer] = @"init",
};


@implementation YASLTranslationNode

+ (instancetype) nodeWithType:(YASLTranslationNodeType)type {
	return [(YASLTranslationNode *)[self alloc] initWithType:type];
}

- (id)initWithType:(YASLTranslationNodeType)type {
	if (!(self = [super init]))
		return self;

	_type = type;
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
