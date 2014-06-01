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
	if (address) {
		NSSet *strings = [allocations keysOfEntriesPassingTest:^BOOL(id key, NSNumber *offset, BOOL *stop) {
			if ([offset intValue] == address)
				return *stop = YES;

			return NO;
		}];

		if (![strings anyObject])
			return nil;

		YASLInt size = [_memManager isAllocated:address];
		if (size) {
			YASLChar *raw = [_ram dataAt:address];
			NSUInteger len = size / sizeof(YASLChar) - 1;
			return [NSString stringWithCharacters:raw length:len];
		}
	}


	return nil;
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

	[self registerNativeFunction:YASLNativeStrings_strLen isVoid:NO withSelector:@selector(n_strLen:params:withParamCount:)];
	[self registerNativeFunction:YASLNativeStrings_strConc isVoid:NO withSelector:@selector(n_strConc:params:withParamCount:)];
	[self registerNativeFunction:YASLNativeStrings_strComp isVoid:NO withSelector:@selector(n_strComp:params:withParamCount:)];
}

- (YASLInt) n_strLen:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	YASLInt str = [native intParam:1 atBase:paramsBase withParamCount:params];
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

- (YASLInt) n_strComp:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	NSString *s1 = [native stringParam:1 atBase:paramsBase withParamCount:params];
	NSString *s2 = [native stringParam:2 atBase:paramsBase withParamCount:params];
	return [s1 compare:s2];
}

- (YASLInt) n_strConc:(YASLNativeFunction *)native params:(void *)paramsBase withParamCount:(NSUInteger)params {
	NSString *s2 = [native stringParam:2 atBase:paramsBase withParamCount:params];
	NSString *string = [[native stringParam:1 atBase:paramsBase withParamCount:params] stringByAppendingString:s2];
	return [self allocString:string];
}

@end
