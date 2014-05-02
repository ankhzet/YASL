//
//  YASLAssembly.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembly.h"
#import "YASLTokenizer.h"

@interface YASLAssembly () {
	NSMutableArray *stack, *popped;
}

@end

@implementation YASLAssembly (Initialization)

#pragma mark - Instantiation

- (id)init {
	if (!(self = [super init]))
		return self;

	stack = [NSMutableArray array];
	popped = [NSMutableArray array];
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
	[self fillWithArray:[source enumerator:NO]];
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

- (id) initWithTokenizer:(YASLTokenizer *)tokenizer {
	if (!(self = [self init]))
		return self;

	NSArray *tokens = [tokenizer allTokens];

	[self fillWithArray:[tokens reverseObjectEnumerator]];
	return self;
}

#pragma mark - Tokenizer assembly

+ (YASLAssembly *) assembleTokens:(YASLTokenizer *)tokenizer {
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

#pragma mark - Stack

- (BOOL) notEmpty {
	return [stack count];
}

- (id) top {
	return [stack lastObject];
}

- (void) push:(id)object {
	[stack addObject:object];
	if ([popped count]) {
		[popped removeLastObject];
	}
}

- (id) pop {
	id object = [self top];
	if (object) {
		[stack removeObject:object];
		[popped addObject:object];
	}
	return object;
}

- (void) clear:(BOOL)noPopped {
	if (noPopped) {
		[stack removeAllObjects];
		[popped removeAllObjects];
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
	return [p arrayByAddingObjectsFromArray:t];
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

- (void) discardPopped {
	[popped removeAllObjects];
}

#pragma mark - State

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

- (NSEnumerator *) enumerator:(BOOL)reverse {
	return reverse ? [stack reverseObjectEnumerator] : [stack objectEnumerator];
}

@end

@implementation  YASLAssembly (StringRepresentation)

- (NSString *) description {
	return [NSString stringWithFormat:@"A %u->%u: [%@]", [stack count] + [popped count], [popped count], [self stackToString]];
}

- (NSString *) stackToString {
	return [self stackToString:NO till:nil];
}

- (NSString *) stackToStringFrom:(id)from till:(id)marker {
	NSString *r = @"";
	NSMutableArray *stackReverse = [NSMutableArray arrayWithCapacity:[stack count]];
	for (id o in [stack reverseObjectEnumerator]) {
    [stackReverse addObject:o];
	}
	NSArray *all = [popped arrayByAddingObjectsFromArray:stackReverse];
	BOOL first = false;
	for (id obj in all) {
		if (!first) {
			if (obj != from)
				continue;
			else
				first = YES;
		}

		if (marker == obj)
			break;

    r = [NSString stringWithFormat:@"%@%@%@", r, [r length] ? @"\u00B7" : @"", obj];
	}
	return r;
}

- (NSString *) stackToString:(BOOL)noPopped till:(id)marker {
	NSString *l = @"", *r = @"";
	if (!noPopped) {
		for (id obj in popped) {
			l = [NSString stringWithFormat:@"%@%@%@", l, [l length] ? @"\u00B7" : @"", obj];
		}
		l = [NSString stringWithFormat:@"%@^", l];
	}
	for (id obj in [stack reverseObjectEnumerator]) {
		if (marker == obj)
			break;

    r = [NSString stringWithFormat:@"%@%@%@", r, [r length] ? @"\u00B7" : @"", obj];
	}
	return [NSString stringWithFormat:@"%@%@", l, r];
}

@end
