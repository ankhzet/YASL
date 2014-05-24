//
//  YASLNoNullsEnumerator.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNoNullsEnumerator.h"

@implementation YASLNoNullsEnumerator {
	NSArray *srcArray;
	NSInteger pointer, delta, max;
}


+ (instancetype) enumeratorWithArray:(NSArray *)array reverse:(BOOL)reverse {
	YASLNoNullsEnumerator *enumerator = [self new];
	enumerator->srcArray = array;
	enumerator->delta = reverse ? -1 : 1;
	enumerator->pointer = reverse ? [array count] : 0;
	enumerator->max = reverse ? 0 : [array count];
	return enumerator;
}

- (NSArray *) allObjects {
	NSMutableArray *fetched = [NSMutableArray arrayWithCapacity:[srcArray count]];
	id element;
	while ((element = [self nextObject])) {
		[fetched addObject:element];
	}
	return fetched;
}

- (id) nextObject {
	if (pointer == max) {
		return nil;
	}
	if (delta < 0) pointer += delta;
	id object = srcArray[pointer];
	if (delta > 0) pointer += delta;
	if (object == [NSNull null])
		return [self nextObject];

	return object;
}

@end
