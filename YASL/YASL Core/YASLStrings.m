//
//  YASLStrings.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStrings.h"
#import "YASLRAM.h"
#import "YASLNativesList.h"
#import "YASLNativeFunction.h"
#import "YASLNativeFunctions.h"

@implementation YASLStrings {
	NSMutableDictionary *allocations;
}

- (NSString *) stringAt:(YASLInt)address {
	NSSet *strings = [allocations keysOfEntriesPassingTest:^BOOL(id key, NSNumber *offset, BOOL *stop) {
		if ([offset intValue] == address)
			return *stop = YES;

		return NO;
	}];

	return [strings anyObject];
}

- (YASLInt) allocString:(NSString *)string {
	NSNumber *allocated = allocations[string];
	if (allocated) {
		return (YASLInt)[allocated intValue];
	}

	YASLInt len = (YASLInt)(([string length] + 1) * sizeof(YASLChar));
	YASLInt alloc = [_memManager allocMem:len];
	void *mem = [_ram dataAt:alloc];
	[string getCString:mem maxLength:len encoding:NSUTF16StringEncoding];
	*(YASLChar *)[_ram dataAt:alloc + len - sizeof(YASLChar)] = 0x0000;

	if (!allocations)
		allocations = [NSMutableDictionary dictionary];
	allocations[string] = @(alloc);

	return alloc;
}

@end

@implementation YASLStrings (NativeFuntions)

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:YASLNativeStrings_strLen withParamCount:1 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(n_strLen:params:)];
	[self registerNativeFunction:YASLNativeStrings_strConc withParamCount:2 returnType:YASLBuiltInTypeIdentifierChar withSelector:@selector(n_strConc:params:)];
	[self registerNativeFunction:YASLNativeStrings_strComp withParamCount:2 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(n_strComp:params:)];
}

- (YASLInt) n_strLen:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLInt str = [native intParam:1 atBase:paramsBase];
	YASLInt size = [_memManager isAllocated:str];
	if (!size)
		return 0;

	YASLInt len = 0;
	size /= sizeof(YASLChar);
	YASLChar *mem = [_ram dataAt:str];
	while (size-- > 0) {
		if (*mem == 0)
			break;
		mem++;
		len++;
	}
	return len;
}

- (YASLInt) n_strComp:(YASLNativeFunction *)native params:(void *)paramsBase {
	NSString *s1 = [native stringParam:1 atBase:paramsBase];
	NSString *s2 = [native stringParam:2 atBase:paramsBase];
	return [s1 compare:s2];
}

- (YASLInt) n_strConc:(YASLNativeFunction *)native params:(void *)paramsBase {
	NSString *s2 = [native stringParam:2 atBase:paramsBase];
	NSString *string = [[native stringParam:1 atBase:paramsBase] stringByAppendingString:s2];
	return [self allocString:string];
}

@end
