//
//  YASLStackSpec.m
//  YASL
//  Spec for YASLStack
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLStack.h"
#import "YASLRAM.h"

SPEC_BEGIN(YASLStackSpec)

describe(@"YASLStack", ^{
	it(@"should properly initialize", ^{
		YASLRAM *ram = [YASLRAM ramWithSize:32];
		YASLStack *instance = [YASLStack stackForRAM:ram];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLStack class]];
		[[theValue(instance.top) should] equal:theValue(0)];
	});

	it(@"should properly push & pop", ^{
		YASLRAM *ram = [YASLRAM ramWithSize:64];
		YASLStack *stack = [YASLStack stackForRAM:ram];

		NSUInteger top = stack.top;

		[[theValue(top) should] equal:theValue(0)];

		[stack push:0x01020304];
		[stack push:0x05060708];
		[stack push:0x090a0b0c];
		[stack push:0x0d0e0f00];
		[[theValue([stack pop]) should] equal:theValue(0x0d0e0f00)];
		[[theValue([stack pop]) should] equal:theValue(0x090a0b0c)];
		[[theValue([stack pop]) should] equal:theValue(0x05060708)];
		[[theValue([stack pop]) should] equal:theValue(0x01020304)];
	});
});

SPEC_END
