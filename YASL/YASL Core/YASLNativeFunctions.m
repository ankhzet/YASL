//
//  YASLNativeFunctions.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNativeFunctions.h"
#import "YASLNativeFunction.h"
#include "YASLCIOverride.h"

@interface YASLNativeFunctions () {
	NSMutableArray *functions;
	NSMutableDictionary *named;
}

- (void) initializeInstance;

@end

#pragma mark - Singleton support

static YASLNativeFunctions *_shared_YASLNativeFunctions_Instance = nil;

__attribute__((constructor))
static void construct_YASLNativeFunctions_Instance() {
	@autoreleasepool {
    _shared_YASLNativeFunctions_Instance = noARCCreateInstanceOfClass([YASLNativeFunctions class]);
		[_shared_YASLNativeFunctions_Instance initializeInstance];
	}
}

__attribute__((destructor))
static void destruct_YASLNativeFunctions_Instance() {
	@autoreleasepool {
    _shared_YASLNativeFunctions_Instance = nil;
	}
}

@implementation YASLNativeFunctions

+ (instancetype) sharedFunctions {
	return _shared_YASLNativeFunctions_Instance;
}

+ (id) allocWithZone:(NSZone *)zone {
  return [self sharedFunctions];
}

- (void) initializeInstance {
	functions = [NSMutableArray arrayWithObject:[NSNull null]];
	named = [NSMutableDictionary dictionary];
}

#pragma mark - Native functionality support

- (NSUInteger) getGUID {
	return [functions count];
}

- (NSUInteger) registerNativeFunction:(YASLNativeFunction *)function {
	NSUInteger guid = 0;
	@synchronized (functions) {
		// find function if already registered
		YASLNativeFunction *has = [self findByName:function.name];
		// use old guid, if registered earlier
		function.GUID = guid = has ? has.GUID : [self getGUID];
		function.ram = self.attachedRAM;
		function.cpu = self.attachedCPU;
		function.stack = self.attachedStack;
		// register new function implementation
		[functions setObject:function atIndexedSubscript:guid];
		named[function.name] = function;
	}
	return guid;
}

- (YASLNativeFunction *) findByName:(NSString *)name {
	return named[name];
}

- (YASLNativeFunction *) findByGUID:(NSUInteger)guid {
	return ((guid > 0) && (guid < [functions count])) ? functions[guid] : nil;
}

#pragma mark - Attachments

- (void) setAttachedRAM:(YASLRAM *)attachedRAM {
	if (_attachedRAM == attachedRAM) {
		return;
	}

	_attachedRAM = attachedRAM;
	for (YASLNativeFunction *function in functions) {
		if (function != (id)[NSNull null]) {
			function.ram = attachedRAM;
		}
	}
}

- (void) setAttachedCPU:(YASLCPU *)attachedCPU {
	if (_attachedCPU == attachedCPU) {
		return;
	}

	_attachedCPU = attachedCPU;
	for (YASLNativeFunction *function in functions) {
		if (function != (id)[NSNull null]) {
			function.cpu = attachedCPU;
		}
	}
}

- (void) setAttachedStack:(YASLStack *)attachedStack {
	if (_attachedStack == attachedStack) {
		return;
	}

	_attachedStack = attachedStack;
	for (YASLNativeFunction *function in functions) {
		if (function != (id)[NSNull null]) {
			function.stack = attachedStack;
		}
	}
}

@end
