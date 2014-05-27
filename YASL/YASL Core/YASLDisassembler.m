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
#import "YASLCodeAddressReference.h"
#import "YASLCodeSource.h"

@implementation YASLDisassembler {
	NSArray *labelRefs;
	NSArray *codeLines;
	YASLCodeSource *codeSource;
	NSCharacterSet *newlines, *whitespace;
}

+ (instancetype) disassemblerForCPU:(YASLCPU *)cpu {
	YASLDisassembler *d = [self new];
	d.cpu = cpu;
	return d;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	newlines = [NSCharacterSet newlineCharacterSet];
	whitespace = [NSCharacterSet whitespaceCharacterSet];
	return self;
}

- (void) setLabelsRefs:(NSArray *)labels {
	labelRefs = labels;
}

- (void) setCodeSource:(YASLCodeSource *)source {
	codeSource = source;
	codeLines = source ? [source.code componentsSeparatedByCharactersInSet:newlines] : nil;
}

- (NSString *) sourceLine:(NSUInteger)lineNumber {
	return codeSource ? codeLines[lineNumber] : @"";
}


- (NSString *) displayLabelAtIP:(YASLInt)ip {
	NSMutableSet *displayedLabels = [NSMutableSet set];

	NSString *codeIdentifier = [[codeSource.identifier lastPathComponent] stringByPaddingToLength:12 withString:@" " startingAtIndex:0];
	for (NSArray *refOffs in labelRefs) {
		YASLCodeAddressReference * ref = refOffs[0];
		NSUInteger address = [ref complexAddress];
    if (ip == address) {
			NSString *label = [NSString stringWithFormat:@"%@:",ref.name ? ref.name : [NSString stringWithFormat:@"ref (%u)", address]];
			NSString *trimmed = [label stringByTrimmingCharactersInSet:newlines];
			if ([trimmed hasPrefix:@"Line #"]) {
				NSInteger line = [[trimmed substringFromIndex:6] integerValue];
				trimmed = [NSString stringWithFormat:@"[%@:%.4u] %@", codeIdentifier, line, [[self sourceLine:line - 1] stringByTrimmingCharactersInSet:whitespace]];
			}
			[displayedLabels addObject:trimmed];
		}
	}
	return [NSString stringWithFormat:@"\n%@\n",[[displayedLabels allObjects] componentsJoinedByString:@"\n"]];
}

- (NSString *) disassembleFrom:(YASLInt)startOffset to:(YASLInt)endOffset {
	if (endOffset < startOffset)
		return @"";

	NSMutableString *result = [@"" mutableCopy];
	YASLInt ip = startOffset, newIP;

	YASLCodeInstruction *instr;
	YASLInstruction *instruction = [YASLInstruction instruction:nil];
	[instruction setLabelRefs:labelRefs];
	YASLInt _opcode1 = 0, _opcode2 = 0;
	YASLInt *opcode1 = &_opcode1, *opcode2 = &_opcode2;
	NSUInteger is = sizeof(YASLCodeInstruction), os = sizeof(YASLInt);
	YASLRAM *ram = self.cpu.ram;
	NSMutableSet *displayedLabels = [NSMutableSet set];
	do {
		NSString *labels = [self displayLabelAtIP:ip];
		NSString *trimmed = [labels stringByTrimmingCharactersInSet:newlines];
		if (![displayedLabels member:trimmed]) {
			[result appendString:labels];
			[displayedLabels addObject:trimmed];
		}

		newIP = [self.cpu disassemblyAtIP:ip Instr:&instr opcode1:&opcode1 opcode2:&opcode2];
		[instruction setInstruction:instr];
		[instruction setImmediatePtr:[ram dataAt:ip + is]];

		NSMutableString *dump = [@"" mutableCopy];
		NSUInteger delta = ((newIP - ip) - is) / os, offset = 0;
		YASLInt i = *(YASLInt *)[ram dataAt:ip];
		[dump appendFormat:@"%.4X %.2X ", (i & 0xFFFF00) >> 8, i & 0xFF];

		while (offset++ < delta) {
			YASLInt i = *(YASLInt *)[ram dataAt:ip + is + (offset - 1) * os];
			[dump appendFormat:@"%.8X ", i & 0xFFFFFFFF];
		}
		dump = [[dump stringByPaddingToLength:16 withString:@" " startingAtIndex:0] mutableCopy];

		[result appendFormat:@"  %.6u: %@ %@\n", ip, dump, [instruction description]];
		ip = newIP;
	} while (ip < endOffset);

	return result;
}

@end
