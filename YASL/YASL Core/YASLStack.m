//
//  YASLStack.m
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStack.h"
#import "YASLRAM.h"

@implementation YASLStack {
	YASLInt topDummy;
}

+ (instancetype) stackForRAM:(YASLRAM *)ram {
	return [(YASLStack *)[self alloc] initForRAM:ram];
}

- (id)initForRAM:(YASLRAM *)ram {
	if (!(self = [super init]))
		return self;

	_size = (YASLInt)MIN(STACK_DEFAULT_SIZE, ram.size);
	_ram = ram;
	_top = &topDummy;
	topDummy = 0;
	return self;
}

- (void) push:(YASLInt)value {
	*((YASLInt *)[_ram dataAt:*_top]) = value;
	*_top += sizeof(YASLInt);
}

- (YASLInt) pop {
	*_top -= sizeof(YASLInt);
	return *((YASLInt *)[_ram dataAt:*_top]);
}

- (void) pushf:(YASLFloat)value {
	*((YASLFloat *)[_ram dataAt:*_top]) = value;
	*_top += sizeof(YASLFloat);
}

- (YASLFloat) popf {
	*_top -= sizeof(YASLFloat);
	return *((YASLFloat *)[_ram dataAt:*_top]);
}

- (void) pushSpace:(YASLInt)count {
	*_top += count;
}

- (void) popSpace:(YASLInt)count {
	*_top -= count;
}


@end
