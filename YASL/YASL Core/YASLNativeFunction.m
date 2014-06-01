//
//  YASLNativeFunction.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNativeFunction.h"
#import "YASLRAM.h"

@implementation YASLNativeFunction

+ (instancetype) nativeWithName:(NSString *)name isVoid:(BOOL)isVoid selector:(SEL)selector andReceiver:(id)receiver {
	YASLNativeFunction *instance = [self new];
	instance.name = name;
	instance.isVoid = isVoid;
	instance.selector = selector;
	instance.receiver = receiver;
	instance.callback = (YASLNativeFunctionCallback)[((NSObject *)receiver) methodForSelector:selector];
	return instance;
}

- (YASLInt) callOnParamsBase:(void *)paramsBase withParamCount:(NSUInteger)params {
	return _callback(_receiver, _selector, self, paramsBase, params);
}

/*
 
 method(p1, p2, p3)
 
 params 3
 p1 = 3 - 1 = 2
 p2 = 3 - 2 = 1
 p3 = 3 - 3 = 0

 */
- (void *) ptrToParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params {
	return (void *)((char *)paramsBase - (params - paramNumber) * sizeof(YASLInt));
}

- (YASLInt) intParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params {
	return *(YASLInt *)[self ptrToParam:paramNumber atBase:paramsBase withParamCount:params];
}

- (YASLFloat) floatParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params {
	return *(YASLFloat *)[self ptrToParam:paramNumber atBase:paramsBase withParamCount:params];
}

- (NSString *) stringParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params {
	YASLInt strPtr = *(YASLInt *)[self ptrToParam:paramNumber atBase:paramsBase withParamCount:params];
	if (strPtr) {
		YASLInt size = [_mm isAllocated:strPtr];
		if (size) {
			YASLChar *raw = [_ram dataAt:strPtr];
			NSUInteger len = size / sizeof(YASLChar) - 1;
			return [NSString stringWithCharacters:raw length:len];
		}
	}
	return nil;
}


@end
