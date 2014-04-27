//
//  YASLNativeInterface.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNativeInterface.h"
#import "YASLNativeFunctions.h"
#import "YASLNativeFunction.h"

@implementation YASLNativeInterface

- (id)init {
	if (!(self = [super init]))
		return self;

	[self registerNativeFunctions];
	return self;
}

- (void) registerNativeFunctions {

}

- (NSUInteger) registerNativeFunction:(NSString *)name withParamCount:(NSUInteger)params returnType:(NSString *)returns withSelector:(SEL)selector {
	YASLNativeFunction *function = [YASLNativeFunction nativeWithName:name
																												 paramCount:params
																												 returnType:returns
																													 selector:selector
																												andReceiver:self];

	return [[YASLNativeFunctions sharedFunctions] registerNativeFunction:function];
}

@end
