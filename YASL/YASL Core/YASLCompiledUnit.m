//
//  YASLCompiledUnit.m
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCompiledUnit.h"
#import "YASLCoreLangClasses.h"

@implementation YASLCompiledUnit {
	NSMutableArray *owners;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	owners = [NSMutableArray array];

	return self;
}

- (YASLLocalDeclaration *) findSymbol:(NSString *)identifier {
	return [self.declarations localDeclarationByIdentifier:identifier];
}

@end

@implementation YASLCompiledUnit (ThreadOwnage)

- (NSEnumerator *) enumerateOwners {
	return [owners objectEnumerator];
}

- (void) usedByThread:(YASLThread *)thread {
	if ((!thread) || [self isUsedByThread:thread])
		return;

	[owners addObject:thread];
}

- (void) notUsedByThread:(YASLThread *)thread {
	if (thread)
		[owners removeObject:thread];
}

- (BOOL) isUsedByThread:(YASLThread *)thread {
	return thread && [owners containsObject:thread];
}

- (BOOL) usedByThreads {
	return !![owners count];
}


@end
