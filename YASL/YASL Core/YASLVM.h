//
//  YASLVM.h
//  YASL
//
//  Base YASL VM header files. Imports RAM, CPU and Stack headers.
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "YASLAPI.h"

#import "YASLRAM.h"
#import "YASLStack.h"

#import "YASLCPU.h"
#import "YASLThreadsAPI.h"
#import "YASLThread.h"
#import "YASLEventsAPI.h"
#import "YASLEvent.h"

#import "YASLCodeCommons.h"

#import "YASLNativeInterface.h"
#import "YASLNativeFunction.h"
#import "YASLNativeFunctions.h"

#import "YASLMemoryManager.h"
#import "YASLStrings.h"

#import "YASLCompiler.h"
#import "YASLCompiledUnit.h"
#import "YASLCodeSource.h"

@class YASLVM;
@interface YASLAbstractVMBuilder : NSObject

- (YASLVM *) buildVM;

- (YASLVM *) newVM;
- (BOOL) attachRAM:(YASLVM *)vm;
- (BOOL) attachStack:(YASLVM *)vm;
- (BOOL) attachCPU:(YASLVM *)vm;
- (BOOL) attachMemoryManager:(YASLVM *)vm;
- (BOOL) attachStringManager:(YASLVM *)vm;
- (BOOL) attachCompiler:(YASLVM *)vm;

@end

@interface YASLVM : YASLNativeInterface

@property (nonatomic) YASLRAM *ram;
@property (nonatomic) YASLStack *stack;
@property (nonatomic) YASLCPU *cpu;
@property (nonatomic) YASLMemoryManager *memManager;
@property (nonatomic) YASLStrings *stringManager;

@property (nonatomic) YASLCompiler *compiler;

- (YASLCompiledUnit *) runScript:(YASLCodeSource *)source;

- (YASLCompiledUnit *) scriptInStage:(YASLUnitCompilationStage)stage bySource:(YASLCodeSource *)source;
- (NSArray *) disassembly:(YASLCodeSource *)source;

@end