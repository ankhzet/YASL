//
//  YASLDisassembler.m
//  YASL
//
//  Created by Ankh on 10.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDisassembler.h"
#import "YASLCPU.h"
#import "YASLRAM.h"
#import "YASLInstruction.h"

@implementation YASLDisassembler

+ (instancetype) disassemblerForCPU:(YASLCPU *)cpu {
	YASLDisassembler *d = [self new];
	d.cpu = cpu;
	return d;
}

- (NSString *) disassembleFrom:(YASLInt)startOffset to:(YASLInt)endOffset {
	if (endOffset < startOffset)
		return @"";

	NSMutableString *result = [@"" mutableCopy];
	YASLInt ip = startOffset, newIP;

	YASLCodeInstruction *instr;
	YASLInstruction *instruction = [YASLInstruction instruction:nil];
	YASLInt _opcode1 = 0, _opcode2 = 0;
	YASLInt *opcode1 = &_opcode1, *opcode2 = &_opcode2;
	NSUInteger is = sizeof(YASLCodeInstruction), os = sizeof(YASLInt);
	do {
		newIP = [self.cpu disassemblyAtIP:ip Instr:&instr opcode1:&opcode1 opcode2:&opcode2];
		[instruction setInstruction:instr];
		[instruction setImmediatePtr:[self.cpu->ram dataAt:ip + is]];

		NSMutableString *dump = [@"" mutableCopy];
		NSUInteger delta = ((newIP - ip) - is) / os, offset = 0;
		YASLInt i = *(YASLInt *)[self.cpu->ram dataAt:ip];
		[dump appendFormat:@"%.4X %.2X ", (i & 0xFFFF00) >> 8, i & 0xFF];

		while (offset++ < delta) {
			YASLInt i = *(YASLInt *)[self.cpu->ram dataAt:ip + is + (offset - 1) * os];
			[dump appendFormat:@"%.8X ", i & 0xFFFFFFFF];
		}
		dump = [[dump stringByPaddingToLength:16 withString:@" " startingAtIndex:0] mutableCopy];

		[result appendFormat:@"\n%.6u: %@ %@", ip, dump, [instruction description]];
		ip = newIP;
	} while (ip < endOffset);

	return result;
}

@end
