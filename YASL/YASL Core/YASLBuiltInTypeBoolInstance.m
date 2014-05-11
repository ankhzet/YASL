//
//  YASLBuiltInTypeBoolInstance.m
//  YASL
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLBuiltInTypeBoolInstance.h"

@implementation YASLBuiltInTypeBoolInstance

- (id)init {
	if (!(self = [super init]))
		return self;

	self.name = YASLBuiltInTypeIdentifierBool;
	self.defined = YES;
	return self;
}

- (NSUInteger) sizeOf {
	return sizeof(YASLBool);
}

@end
