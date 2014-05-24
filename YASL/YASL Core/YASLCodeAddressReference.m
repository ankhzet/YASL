//
//  YASLCodeAddressReference.m
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCodeAddressReference.h"

@implementation YASLCodeAddressReference

+ (instancetype) referenceWithName:(NSString *)name {
	YASLCodeAddressReference *ref = [self new];
	ref.name = name;
	return ref;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	_references = [NSMutableArray array];
	return self;
}

- (YASLOpcodeOperand *) addReferent:(YASLOpcodeOperand *)operand {
	[(NSMutableArray *)_references addObject:operand];
	return operand;
}

- (YASLOpcodeOperand *) addNewOpcodeOperandReferent {
	return [self addReferent:IMM_(0)];
}

- (void) addressResolved:(YASLInt)referencedAddress {
	self.address = referencedAddress;
}

- (void) setAddress:(YASLInt)address {
	_address = address;
//	NSLog(@"%@ now references at %.4d", self.name, address + self.base);
	[self updateReferents];
}

- (YASLInt) complexAddress {
	return _base + _address;
}

- (void) updateReferents {
	NSNumber *address = @([self complexAddress]);
	for (YASLOpcodeOperand *operand in self.references) {
    operand->immediate = address;
	}
}

- (NSString *) description {
	NSString *offsets = self.address ? [NSString stringWithFormat:@"%@%d", self.address >= 0 ? @"+" : @"", self.address] : @"";
	offsets = self.base ? [NSString stringWithFormat:@"%d%@", self.base, offsets] : offsets;
	return [NSString stringWithFormat:@"<#%@%@>:\n", self.name ? self.name : @"anon", offsets];
}

@end
