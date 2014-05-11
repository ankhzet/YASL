//
//  YASLBuiltInTypeFloatInstance.m
//  YASL
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBuiltInTypeFloatInstance.h"

@implementation YASLBuiltInTypeFloatInstance

- (id)init {
	if (!(self = [super init]))
		return self;

	self.name = YASLBuiltInTypeIdentifierFloat;
	self.defined = YES;
	return self;
}

- (NSUInteger) sizeOf {
	return sizeof(YASLFloat);
}

@end
