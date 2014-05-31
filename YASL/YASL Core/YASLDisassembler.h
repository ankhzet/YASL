//
//  YASLDisassembler.h
//  YASL
//
//  Created by Ankh on 10.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@interface YASLCodeDisassembly : NSObject {
	@public
	/*! Starting IP. */
	YASLInt startIP;
	/*! Hexadecimal instruction and operands code dump in format XXXX XX XXXXXXXX XXXXXXXX. Four-bytes operands are optional (last two groups). */
	NSString *codeDump;
	/*! Instruction dissassembly in ASM, like 'MOV R0, [BP+14]'. */
	NSString *instructionDisassembly;
	/*! If instruction belongs to jump group (JMP, JNZ etc), then jumpIP will contain jump address if it is immediate value. */
	YASLInt jumpIP;

	/*! Labels, that are associated with this IP address. */
	NSString *labels;
	/*! Source code lines, if any. Source code line is provided only for first instruction of code, corresponded to that line. */
	NSString *sourceCode;
	NSUInteger sourceLine;
}
@end

@class YASLCPU, YASLCodeSource, YASLStrings;
@interface YASLDisassembler : NSObject

@property (nonatomic) YASLCPU *cpu;

+ (instancetype) disassemblerForCPU:(YASLCPU *)cpu;

- (NSArray *) disassembleFrom:(YASLInt)startOffset to:(YASLInt)endOffset;

- (void) setLabelsRefs:(NSArray *)labels;
- (void) setCodeSource:(YASLCodeSource *)source;
- (void) setStringsManager:(YASLStrings *)strings;

- (NSString *) sourceLine:(NSUInteger)lineNumber;

@end
