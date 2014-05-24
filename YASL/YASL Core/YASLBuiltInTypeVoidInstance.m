//
//  YASLBuiltInTypeVoidInstance.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBuiltInTypeVoidInstance.h"

@implementation YASLBuiltInTypeVoidInstance

- (id)init {
	if (!(self = [super init]))
		return self;

	self.name = YASLBuiltInTypeIdentifierVoid;
	self.defined = YES;
	return self;
}

- (NSUInteger) sizeOf {
	return 0;
}

@end
