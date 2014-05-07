//
//  YASLBuiltInTypeInt.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBuiltInTypeIntInstance.h"
#import "YASLAPI.h"

@implementation YASLBuiltInTypeIntInstance

- (id)init {
	if (!(self = [super init]))
		return self;

	self.name = @"int";
	self.defined = YES;
	return self;
}

- (NSUInteger) sizeOf {
	return sizeof(YASLInt);
}

@end
