//
//  YASLDiscards.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDiscards.h"

@implementation YASLDiscards

+ (instancetype) discardsForParent:(YASLDiscards *)parent andState:(NSUInteger)state {
	YASLDiscards *discards = [[self alloc] init];
	discards->parent = parent;
	discards->state = state;
	return discards;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	discardsSet = [NSMutableSet set];
	return self;
}

- (void) detouch {
	if (child) [child detouch];
	if (parent) parent->child = nil;
	child = nil;
	parent = nil;
}

- (YASLDiscards *) pushDiscards:(NSUInteger)pushState {
	if (pushState == state)
		return self;

	return child = [YASLDiscards discardsForParent:self andState:pushState];
}

- (YASLDiscards *) popDiscards:(NSUInteger)tillState {
	YASLDiscards *discard = self, *parentDiscard;
	while (discard && (discard->state > tillState)) {
		parentDiscard = discard->parent;
		if (!parentDiscard)
			break;

		[discard detouch];
		discard = parentDiscard;
	}

	return discard;
}



/*! Always ignore specified object, when pushing it onto the stack. If it was pushed before marked for discard - it will be ignored in next -[pop]. */
- (void) alwaysDiscard:(id)object inGlobalScope:(BOOL)global {
	[discardsSet addObject:object];
	if (global)
		[parent alwaysDiscard:object inGlobalScope:YES];
	else
		[child alwaysDiscard:object inGlobalScope:NO];
}

/*! Returns YES, if specified object marked for discard. */
- (BOOL) mustDiscard:(id)object {
	return [discardsSet member:object] || [parent mustDiscard:object];
}

/*! Clear all discard markers. */
- (void) noDiscards {
	[discardsSet removeAllObjects];
	[self dropDiscardsAfterState:0];
}

/*! Discard markers affects only state, when they had been made, or later. Folding will force current markers to affect any state.  */
- (YASLDiscards *) foldDiscards {
	YASLDiscards *p = parent;
	if (p) {
		[p->discardsSet unionSet:discardsSet];
		return [p foldDiscards];
	}

	if (child) [child detouch];
	return self;
}

- (YASLDiscards *) dropDiscardsAfterState:(NSUInteger)stateToDrop {
	if (state > stateToDrop)
		return [self popDiscards:stateToDrop];

	if (child) {
		if (child->state >= stateToDrop) {
			[child detouch];
		} else
			return [child dropDiscardsAfterState:stateToDrop];
	}
	return [self popDiscards:stateToDrop];
}

- (BOOL) hasDiscards {
	return [discardsSet count] || [child hasDiscards];
}

- (id) copyWithZone:(NSZone *)zone {
	YASLDiscards *copy = [YASLDiscards discardsForParent:nil andState:state];
	if (child) {
		copy->child = [child copy];
		copy->child->parent = child;
	}

	copy->discardsSet = [discardsSet mutableCopy];
	return copy;
}

- (void) dealloc {
	[self detouch];
}

- (NSString *) description {
	NSString *r = [@"" mutableCopy];
	for (id object in discardsSet) {
    [(NSMutableString *)r appendFormat:@"%@`%@`", [r length] ? @"\u00B7" : @"", object];
	}
	r = [r length] ? [NSString stringWithFormat:@"%@ ", r] : @"";

	NSString *p = parent ? [parent description] : @"";
	p = ([p length] && [r length]) ? [NSString stringWithFormat:@"[%@]", p] : p;

	return ([r length] || [p length]) ? [NSString stringWithFormat:@"%@%@", r, p] : @"";
}

@end
