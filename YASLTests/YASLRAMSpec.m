//
//  YASLRAMSpec.m
//  YASL
//  Spec for YASLRAM
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLRAM.h"
#import "YASLCodeCommons.h"

SPEC_BEGIN(YASLRAMSpec)

describe(@"YASLRAM", ^{
	it(@"should properly initialize", ^{
		YASLRAM *instance = [YASLRAM new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLRAM class]];
		[[theValue(instance.size) should] equal:theValue((MEMORY_DEFAULT_SIZE / MEMORY_FIXED_UNIT + 1) * MEMORY_FIXED_UNIT)];
	});

	it(@"should alloc memory as multiples of 4 (32-bit based allocations)", ^{
		YASLRAM *instance = [YASLRAM new];

		[instance setSize:7];
		[[@(instance.size) should] equal:@(8)];

		[instance setSize:8];
		[[@(instance.size) should] equal:@(12)];

		[instance setSize:9];
		[[@(instance.size) should] equal:@(12)];

		[instance setSize:11];
		[[@(instance.size) should] equal:@(12)];

	});

	it(@"should properly access memory", ^{
		YASLRAM *ram = [YASLRAM ramWithSize:8];

		unsigned char *byte1 = [ram dataAt:0];
		unsigned char *byte2 = [ram dataAt:1];
		unsigned char *byte3 = [ram dataAt:2];
		unsigned char *byte4 = [ram dataAt:3];
		unsigned char *byte5 = [ram dataAt:4];
		unsigned char *byte6 = [ram dataAt:5];
		unsigned char *byte7 = [ram dataAt:6];
		unsigned char *byte8 = [ram dataAt:7];

		unsigned short *word1 = [ram dataAt:0];
		unsigned short *word2 = [ram dataAt:2];
		unsigned short *word3 = [ram dataAt:4];
		unsigned short *word4 = [ram dataAt:6];
		unsigned short *word5 = [ram dataAt:1];

		unsigned int *int1 = [ram dataAt:0];
		unsigned int *int2 = [ram dataAt:4];

		[[theValue(byte1) shouldNot] beNil];
		[[theValue(byte8) shouldNot] beNil];
		[[theValue((char *)word1) should] equal:theValue((char *)byte1)];
		[[theValue((char *)word2) should] equal:theValue((char *)byte3)];
		[[theValue((char *)word3) should] equal:theValue((char *)byte5)];
		[[theValue((char *)word4) should] equal:theValue((char *)byte7)];

		[[theValue((char *)int1) should] equal:theValue((char *)byte1)];
		[[theValue((char *)int2) should] equal:theValue((char *)byte5)];

		*int1 = 0xFFEEDDCC;
		*int2 = 0xBBAA9988;

		[[theValue(*word1) should] equal:theValue((unsigned short) 0xDDCC)];
		[[theValue(*word2) should] equal:theValue((unsigned short) 0xFFEE)];
		[[theValue(*word3) should] equal:theValue((unsigned short) 0x9988)];
		[[theValue(*word4) should] equal:theValue((unsigned short) 0xBBAA)];

		[[theValue(*byte1) should] equal:theValue((unsigned short) 0xCC)];
		[[theValue(*byte2) should] equal:theValue((unsigned short) 0xDD)];
		[[theValue(*byte3) should] equal:theValue((unsigned short) 0xEE)];
		[[theValue(*byte4) should] equal:theValue((unsigned short) 0xFF)];
		[[theValue(*byte5) should] equal:theValue((unsigned short) 0x88)];
		[[theValue(*byte6) should] equal:theValue((unsigned short) 0x99)];
		[[theValue(*byte7) should] equal:theValue((unsigned short) 0xAA)];
		[[theValue(*byte8) should] equal:theValue((unsigned short) 0xBB)];

		*word5 = 0x1234;

		[[theValue(*byte1) should] equal:theValue((unsigned short) 0xCC)];
		[[theValue(*byte2) should] equal:theValue((unsigned short) 0x34)];
		[[theValue(*byte3) should] equal:theValue((unsigned short) 0x12)];
		[[theValue(*byte4) should] equal:theValue((unsigned short) 0xFF)];
		[[theValue(*byte5) should] equal:theValue((unsigned short) 0x88)];
		[[theValue(*byte6) should] equal:theValue((unsigned short) 0x99)];
		[[theValue(*byte7) should] equal:theValue((unsigned short) 0xAA)];
		[[theValue(*byte8) should] equal:theValue((unsigned short) 0xBB)];
	});
});

SPEC_END
