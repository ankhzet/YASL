//
//  YASLRAM.m
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLRAM.h"
#import "YASLCodeCommons.h"

@interface YASLRAM () {
	void *mem;
}

@end

@implementation YASLRAM

+ (instancetype) ramWithSize:(NSUInteger)size {
	return [(YASLRAM *)[self alloc] initWithSize:size];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	[self setSize:MEMORY_DEFAULT_SIZE];
	return self;
}

- (id)initWithSize:(NSUInteger)size {
	if (!(self = [super init]))
		return self;

	[self setSize:size];
	return self;
}

- (void)dealloc
{
	if (mem)
		free(mem);
}

#pragma mark - Common methods

- (void) setSize:(NSUInteger)size {
	size = (1 + size / MEMORY_FIXED_UNIT) * MEMORY_FIXED_UNIT;
	if (size == _size)
		return;

	void *memTemp = realloc(mem, size);

	if (memTemp) {
		_size = size;
		mem = memTemp;
	}
}

- (void *) dataAt:(NSUInteger)offset {
	return (void *)((char *)mem + offset);
}

- (void) setInt:(YASLInt)value at:(NSUInteger)offset {
	*(YASLInt *)[self dataAt:offset] = value;
}

- (YASLInt) intAt:(NSUInteger)offset {
	return *(YASLInt *)[self dataAt:offset];
}

@end
