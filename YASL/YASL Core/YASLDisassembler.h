//
//  YASLDisassembler.h
//  YASL
//
//  Created by Ankh on 10.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@class YASLCPU;
@interface YASLDisassembler : NSObject

@property (nonatomic) YASLCPU *cpu;

+ (instancetype) disassemblerForCPU:(YASLCPU *)cpu;

- (NSString *) disassembleFrom:(YASLInt)startOffset to:(YASLInt)endOffset;

- (void) setLabelsRefs:(NSArray *)labels;

@end
