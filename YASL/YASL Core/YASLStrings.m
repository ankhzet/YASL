//
//  YASLStrings.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStrings.h"
#import "YASLRAM.h"

@implementation YASLStrings

- (YASLInt) putStr:(NSString *)string onRam:(YASLRAM *)ram atOffset:(YASLInt)offset {
	YASLInt len = [string length];
	const char *raw = [string cStringUsingEncoding:NSASCIIStringEncoding];

	void *ptr = [ram dataAt:offset];
	memcpy(ptr, raw, sizeof(char) * len);
	*(char *)[ram dataAt:offset + len] = 0x00;

	return len + 1;
}

@end
