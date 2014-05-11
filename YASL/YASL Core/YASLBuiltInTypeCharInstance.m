//
//  YASLBuiltInTypeCharInstance.m
//  YASL
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBuiltInTypeCharInstance.h"

@implementation YASLBuiltInTypeCharInstance

- (id)init {
	if (!(self = [super init]))
		return self;

	self.name = YASLBuiltInTypeIdentifierChar;
	self.defined = YES;
	return self;
}

- (NSUInteger) sizeOf {
	return sizeof(YASLChar);
}

@end
