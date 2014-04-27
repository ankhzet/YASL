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

+ (instancetype) nativeWithName:(NSString *)name paramCount:(NSUInteger)params returnType:(NSString *)returns selector:(SEL)selector andReceiver:(id)receiver {
	YASLNativeFunction *instance = [self new];
	instance.name = name;
	instance.params = params;
	instance.returns = returns;
	instance.selector = selector;
	instance.receiver = receiver;
	instance.callback = (YASLNativeFunctionCallback)[((NSObject *)receiver) methodForSelector:selector];
	return instance;
}

- (YASLInt) callOnParamsBase:(void *)paramsBase {
	return _callback(_receiver, _selector, self, paramsBase);
}

/*
 
 method(p1, p2, p3)
 
 params 3
 p1 = 3 - 1 = 2
 p2 = 3 - 2 = 1
 p3 = 3 - 3 = 0

 */
- (void *) ptrToParam:(NSUInteger)paramNumber atBase:(void *)paramsBase {
	return (void *)((char *)paramsBase - (_params - paramNumber) * sizeof(YASLInt));
}

- (YASLInt) intParam:(NSUInteger)paramNumber atBase:(void *)paramsBase {
	return *(YASLInt *)[self ptrToParam:paramNumber atBase:paramsBase];
}

- (YASLFloat) floatParam:(NSUInteger)paramNumber atBase:(void *)paramsBase {
	return *(YASLFloat *)[self ptrToParam:paramNumber atBase:paramsBase];
}

- (NSString *) stringParam:(NSUInteger)paramNumber atBase:(void *)paramsBase {
	YASLInt strPtr = *(YASLInt *)[self ptrToParam:paramNumber atBase:paramsBase];
	if (strPtr) {
		char *raw = [_ram dataAt:strPtr];
		return [NSString stringWithCString:raw encoding:NSASCIIStringEncoding];
	} else
		return nil;
}


@end
