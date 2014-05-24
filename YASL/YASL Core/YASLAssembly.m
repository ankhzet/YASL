//
//  YASLAssembly.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembly.h"
#import "YASLAbstractTokenizer.h"

@interface YASLAssembly () {
	NSMutableArray *stack, *popped;
//	YASLDiscards *discards;
}

@end

@implementation YASLAssembly (Initialization)

#pragma mark - Instantiation

- (id)init {
	if (!(self = [super init]))
		return self;

	stack = [NSMutableArray array];
	popped = [NSMutableArray array];

	discards = [YASLDiscards discardsForParent:nil andState:0];

	self.userData = [NSMutableDictionary dictionary];
	return self;
}

- (void) fillWithArray:(NSEnumerator *)enumerator {
	[self clear:YES];
	for (id o in enumerator)
		[self push:o];
}


- (id) initReverseAssembly:(YASLAssembly *)source {
	if (!(self = [self init]))
		return self;

	NSUInteger state = [source pushState];
	[self fillWithArray:[source enumerator:YES]];
	[source popState:state];

	return self;
}

- (id) initWithArray:(NSArray *)source {
	if (!(self = [self init]))
		return self;

	[self fillWithArray:[source objectEnumerator]];

	return self;
}

- (id) initReverseArray:(NSArray *)source {
	if (!(self = [self init]))
		return self;

	[self fillWithArray:[source reverseObjectEnumerator]];

	return self;
}

- (id) initWithTokenizer:(YASLAbstractTokenizer *)tokenizer {
	if (!(self = [self init]))
		return self;

	NSArray *tokens = [tokenizer allTokens];

	[self fillWithArray:[tokens reverseObjectEnumerator]];
	return self;
}

#pragma mark - Tokenizer assembly

+ (YASLAssembly *) assembleTokens:(YASLAbstractTokenizer *)tokenizer {
	return [[self alloc] initWithTokenizer:tokenizer];
}

@end

@implementation YASLAssembly

/*! Copies assembly. Objects in stack will be shared. */
- (id) copyWithZone:(NSZone *)zone {
	YASLAssembly *copy = [[[self class] alloc] init];
	copy->stack = [stack mutableCopy];
	copy->popped = [popped mutableCopy];
	return copy;
}

@end

#pragma mark - Discards

@implementation YASLAssembly (Discards)

- (void) discardAs:(YASLAssembly *)sourceAssembly {
	[discards dropDiscardsAfterState:0];
	discards = [sourceAssembly->discards copy];
}

- (void) discardPopped:(YASLAssembly *)sourceAssembly {
	for (id object in [sourceAssembly enumerator:NO])
		if (![stack containsObject:object])
			[discards alwaysDiscard:object inGlobalScope:NO];

}

- (void) pushDiscards:(NSUInteger)state {
	discards = [discards pushDiscards:state];
}

- (void) noDiscards {
	[discards noDiscards];
}

- (void) foldDiscards {
	discards = [discards foldDiscards];
}

- (BOOL) mustDiscard:(id)object {
	return [discards mustDiscard:object];
}

- (void) alwaysDiscard:(id)object inGlobalScope:(BOOL)global {
	[discards alwaysDiscard:object inGlobalScope:global];
}

- (void) dropDiscardsAfterState:(NSUInteger)state {
	discards = [discards dropDiscardsAfterState:state];
}

@end

#pragma mark - Stack

@implementation YASLAssembly (Stack)

- (BOOL) notEmpty {
	return !![stack count];
}

- (id) top {
	int idx = [stack count];
	while (--idx >= 0) {
		id top = stack[idx];
		if (![discards mustDiscard:top]) {
			return top;
		}
	}
	return nil;
}

- (void) push:(id)object {
	if ([discards mustDiscard:object])
		return;

	[stack addObject:object];
	if ([popped count]) {
		[popped removeLastObject];
	}
}

- (id) pushBack {
	id object = [popped lastObject];
	if (!object)
		return nil;

	[popped removeLastObject];

	if ([discards mustDiscard:object])
		return [self pushBack];

	[stack addObject:object];
	return object;
}

- (id) pop {
	id object = [self top];
	if (object) {
		[stack removeLastObject];
		[popped addObject:object];

		if ([discards mustDiscard:object])
			return [self pop];
	}

	return object;
}

- (id) popTillChunkMarker {
	return [self popTill:_chunkMarker];
}

- (id) popTill:(id)marker {
	id object = [self top];
	if (object) {
		if (object == marker) {
			return nil;
		}

		[stack removeLastObject];
		[popped addObject:object];

		if ([discards mustDiscard:object])
			return [self popTill:marker];
	}

	return object;
}

- (void) clear:(BOOL)noPopped {
	if (noPopped) {
		[stack removeAllObjects];
		[popped removeAllObjects];
		[self dropDiscardsAfterState:0];
	} else
		while ([self pop]);
}

- (NSArray *) objectsAbove:(id)marker {
	NSUInteger c = [stack count];
	NSUInteger idx = [stack indexOfObject:marker];


	NSArray *p = nil, *r = [NSMutableArray array];
	if (idx == NSNotFound) {
		NSUInteger pc = [popped count];
		NSUInteger pidx = [popped indexOfObject:marker];
		pidx = (pidx == NSNotFound) ? pc : pidx;
		p = [popped subarrayWithRange:NSMakeRange(0, pidx)];
	} else {
		idx++;
		p = popped;

		r = (idx < c) ? [stack subarrayWithRange:NSMakeRange(idx, c - idx)] : r;
	}

	NSMutableArray *t = [NSMutableArray arrayWithCapacity:[r count]];
	for (id o in [r reverseObjectEnumerator]) {
    [t addObject:o];
	}
	p = [p arrayByAddingObjectsFromArray:t];

	if ([discards hasDiscards]) {
		t = [NSMutableArray arrayWithCapacity:[p count]];
		for (id o in p) {
			if (![discards mustDiscard:o]) {
				[t addObject:o];
			}
		}
		p = t;
	}
	return p;
}

- (NSArray *) objectsAbove:(id)aboveMarker belove:(id)beloveMarkev {
	NSArray *above = [self objectsAbove:aboveMarker];

	NSUInteger idx = [above indexOfObject:beloveMarkev];
	if (idx != NSNotFound) {
		above = [above subarrayWithRange:NSMakeRange(idx, [above count] - idx)];
	} else
		above = @[];

	return above;
}

- (void) dropPopped {
	[popped removeAllObjects];
}

- (NSEnumerator *) enumerator:(BOOL)reverse {
	return reverse ? [stack reverseObjectEnumerator] : [stack objectEnumerator];
}

@end

#pragma mark - State

@implementation YASLAssembly (State)

- (NSUInteger) total {
	return [stack count] + [popped count];
}

- (NSUInteger) pushState {
	return [stack count];
}

- (void) popState:(NSUInteger)state {
	NSUInteger c = [stack count];

	if (c > state) {
		while (c-- > state)
			[self pop];
	} else if (c < state) {
		while (c++ < state)
			[self push:[popped lastObject]];
	}
}

- (void) restoreFullStack {
	[self popState:[stack count] + [popped count]];
}

@end

@implementation  YASLAssembly (StringRepresentation)

- (NSString *) description {
	return [NSString stringWithFormat:@"A %u->%u: [%@]", [stack count] + [popped count], [popped count], [self stackToString]];
}

- (NSString *) stackToString {
	return [self stackToString:NO till:nil];
}

- (NSString *) stackToStringFrom:(id)from till:(id)marker withContext:(BOOL)context {
	NSArray *stackReverse = [[stack reverseObjectEnumerator] allObjects];
	NSArray *all = [popped arrayByAddingObjectsFromArray:stackReverse];

	NSUInteger allCount = [all count];
	NSMutableArray *pre = [NSMutableArray arrayWithCapacity:allCount];
	NSMutableArray *chunk = [NSMutableArray arrayWithCapacity:allCount];
	NSMutableArray *post = [NSMutableArray arrayWithCapacity:allCount];
	BOOL isPre = YES, isChunk = NO, isPost = NO;
	for (id object in all) {
		if (object == from) {
			isPre = NO;
			isChunk = YES;
		}

		if (![self mustDiscard:object]) {
			if (isPre) [pre addObject:object];
			if (isChunk) [chunk addObject:object];
			if (isPost) [post addObject:object];
		}

		if (object == marker) {
			isChunk = NO;
			isPost = YES;
		}
	}

	NSUInteger contextSize = 5;

	if ([pre count] > contextSize) {
		[pre removeObjectsInRange:NSMakeRange(0, [pre count] - contextSize)];
	}

	if ([post count] > contextSize) {
		NSUInteger rest = [post count] - contextSize;
		[post removeObjectsInRange:NSMakeRange([post count] - rest, rest)];
	}

	NSString *delim = @"\u00B7";
	return [NSString stringWithFormat:@"%@\u3010%@\u3011%@", [pre componentsJoinedByString:delim], [chunk componentsJoinedByString:delim], [post componentsJoinedByString:delim]];
}

- (NSString *) stackToString:(BOOL)noPopped till:(id)marker {
	NSString *l = [@"" mutableCopy], *r = [@"" mutableCopy];
	if (!noPopped) {
		for (id obj in popped) {
			[(NSMutableString *)l appendFormat:@"%@%@", [l length] ? @"\u00B7" : @"", obj];
		}
	}
	for (id obj in [stack reverseObjectEnumerator]) {
		if (marker == obj)
			break;

    [(NSMutableString *)r appendFormat:@"%@%@", [r length] ? @"\u00B7" : @"", obj];
	}
	return [NSString stringWithFormat:@"%@^%@", l, r];
}

@end
