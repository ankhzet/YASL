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
	YASLStrings *stringsManager;
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

- (void) setStringsManager:(YASLStrings *)strings {
	stringsManager = strings;
}

- (NSString *) sourceLine:(NSUInteger)lineNumber {
	return codeSource ? codeLines[lineNumber] : @"";
}


- (NSString *) displayLabelAtIP:(YASLInt)ip {
	NSMutableSet *displayedLabels = [NSMutableSet set];

//	NSString *codeIdentifier = [codeSource.identifier lastPathComponent];
	for (NSArray *refOffs in labelRefs) {
		YASLCodeAddressReference * ref = refOffs[0];
		YASLInt address = [ref complexAddress];
    if (ip == address) {
			NSString *label = [NSString stringWithFormat:@"%@:",ref.name ? ref.name : [NSString stringWithFormat:@":?(%u)", address]];
			NSString *trimmed = [label stringByTrimmingCharactersInSet:newlines];
			[displayedLabels addObject:trimmed];
		}
	}
	return [NSString stringWithFormat:@"\n%@\n",[[displayedLabels allObjects] componentsJoinedByString:@"\n"]];
}

- (NSArray *) disassembleFrom:(YASLInt)startOffset to:(YASLInt)endOffset {
	NSUInteger is = sizeof(YASLCodeInstruction), os = sizeof(YASLInt);
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:(endOffset - startOffset) * is];
	if (endOffset < startOffset)
		return result;

	YASLInt ip = startOffset, newIP;

	YASLCodeInstruction *instr;
	YASLInstruction *instruction = [YASLInstruction instruction:nil];
	[instruction setLabelRefs:labelRefs];
	[instruction setStringsManager:stringsManager];
	YASLInt _opcode1 = 0, _opcode2 = 0;
	YASLInt *opcode1 = &_opcode1, *opcode2 = &_opcode2;
	YASLRAM *ram = self.cpu.ram;
	NSMutableSet *displayedLabels = [NSMutableSet set];
	NSUInteger lastLine = 0;
	do {
		YASLCodeDisassembly *codeLine = [YASLCodeDisassembly new];
		NSMutableSet *labelsSet = [NSMutableSet set];
		NSMutableSet *sourceSet = [NSMutableSet set];
		NSString *labels = [self displayLabelAtIP:ip];
		NSString *trimmed = [labels stringByTrimmingCharactersInSet:newlines];
		if ([trimmed length]) {
			NSMutableSet *tempSet = [NSMutableSet set];
			if (![displayedLabels member:trimmed]) {
				[tempSet addObjectsFromArray:[trimmed componentsSeparatedByCharactersInSet:newlines]];
				[displayedLabels addObject:trimmed];
			}
			for (NSString *label in tempSet) {
				if ([label hasPrefix:@"Line #"]) {
					NSInteger line = [[label substringFromIndex:6] integerValue];
					if (line == lastLine)
						continue;

					lastLine = line;
					codeLine->sourceLine = MAX(codeLine->sourceLine, line);
					NSString *source = [[self sourceLine:line - 1] stringByTrimmingCharactersInSet:whitespace];
					[sourceSet addObject:[NSString stringWithFormat:@"%.4lu: %@", line, source]];
				} else
					[labelsSet addObject:label];
			}
		}
		codeLine->labels = [[labelsSet allObjects] componentsJoinedByString:@"\n"];
		codeLine->sourceCode = [[[sourceSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSString *l1, NSString *l2) {
			NSInteger delta = [l1 integerValue] - [l2 integerValue];
			return delta ? delta / ABS(delta) : NSOrderedSame;
		}] componentsJoinedByString:@"\n"];

		codeLine->startIP = ip;

		newIP = [self.cpu disassemblyAtIP:ip instr:&instr opcode1:&opcode1 opcode2:&opcode2];
		[instruction setInstruction:instr];
		[instruction setImmediatePtr:[ram dataAt:(YASLInt)(ip + is)]];

		NSMutableString *dump = [@"" mutableCopy];
		NSUInteger delta = ((newIP - ip) - is) / os, offset = 0;
		YASLInt i = *(YASLInt *)[ram dataAt:ip];
		[dump appendFormat:@"%.4X %.2X", (i & 0xFFFF00) >> 8, i & 0xFF];

		while (offset++ < delta) {
			YASLInt i = *(YASLInt *)[ram dataAt:(YASLInt)(ip + is + (offset - 1) * os)];
			[dump appendFormat:@" %.8X", i & 0xFFFFFFFF];
		}
		codeLine->codeDump = dump;

		codeLine->instructionDisassembly = [instruction description];
		switch (instr->opcode) {
			case OPC_JMP:
			case OPC_JGE:
			case OPC_JGT:
			case OPC_JLE:
			case OPC_JLT:
			case OPC_JNZ:
			case OPC_JZ: {
				if (instr->operand1 != YASLOperandTypeImmediate)
					break;

				NSString *ip, *label = [instruction immediateStr:0 withPlusSign:NO];
				NSUInteger brace = [label rangeOfString:@"("].location;
				if (brace != NSNotFound)
					ip = [label substringFromIndex:brace + 1];
				else
					ip = label;

				codeLine->jumpIP = (YASLInt)[ip integerValue];
				break;
			}
			default:;
		}
		[result addObject:codeLine];

		ip = newIP;
	} while (ip < endOffset);

	return result;
}

@end

@implementation YASLCodeDisassembly

- (NSString *) description {
	return [NSString stringWithFormat:@"%@%@   %.6u: %@ %@"
					, [labels length] ? [labels stringByAppendingString:@"\n"] : @""
					, [sourceCode length] ? [sourceCode stringByAppendingString:@"\n"] : @""
					, startIP
					, [codeDump stringByPaddingToLength:25 withString:@" " startingAtIndex:0]
					, instructionDisassembly
					];
}

@end