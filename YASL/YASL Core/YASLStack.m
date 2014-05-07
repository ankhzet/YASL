//
//  YASLStack.m
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStack.h"
#import "YASLRAM.h"

@implementation YASLStack

+ (instancetype) stackForRAM:(YASLRAM *)ram {
	return [(YASLStack *)[self alloc] initForRAM:ram];
}

- (id)initForRAM:(YASLRAM *)ram {
	if (!(self = [super init]))
		return self;

	_size = MIN(STACK_DEFAULT_SIZE, ram.size);
	_ram = ram;
	_top = 0;
	_base = MAX(0, ram.size - _size);
	return self;
}

- (void) push:(YASLInt)value {
	*((YASLInt *)[_ram dataAt:_top + _base]) = value;
	_top += sizeof(YASLInt);
}

- (YASLInt) pop {
	_top -= sizeof(YASLInt);
	return *((YASLInt *)[_ram dataAt:_top + _base]);
}

- (void) pushf:(YASLFloat)value {
	*((YASLFloat *)[_ram dataAt:_top + _base]) = value;
	_top += sizeof(YASLFloat);
}

- (YASLFloat) popf {
	_top -= sizeof(YASLFloat);
	return *((YASLFloat *)[_ram dataAt:_top + _base]);
}

- (void) pushSpace:(YASLInt)count {
	_top += sizeof(YASLInt) * count;
}

- (void) popSpace:(YASLInt)count {
	_top -= sizeof(YASLInt) * count;
}


@end
