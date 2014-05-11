//
//  YASLCodeAddressReference.m
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCodeAddressReference.h"

@implementation YASLCodeAddressReference

- (id)init {
	if (!(self = [super init]))
		return self;

	_references = [NSMutableArray array];
	return self;
}

- (void) addReferent:(YASLOpcodeOperand *)operand {
	[(NSMutableArray *)_references addObject:operand];
}

- (void) addressResolved:(YASLInt)referencedAddress {
	self.address = referencedAddress;
}

- (void) setAddress:(YASLInt)address {
	_address = address;
	NSLog(@"%@ now references at %.4d", self.name, address + self.base);
	[self updateReferents];
}

- (void) updateReferents {
	NSNumber *address = @(self.address + self.base);
	for (YASLOpcodeOperand *operand in self.references) {
    operand->immediate = address;
	}
}

@end
