//
//  YASLArrayDataType.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLArrayDataType.h"

@implementation YASLArrayDataType

- (id)init {
	if (!(self = [super init]))
		return self;

	_elements = 0;
	self.isPointer++;
	return self;
}

- (NSUInteger) sizeOf {
	return [super sizeOf] * _elements;
}

- (void) setElements:(NSUInteger)elements {
	_elements = elements;

	self.specifiers = @[[NSString stringWithFormat:@"[%@]", @(elements)]];
}

@end
