//
//  YASLVMBuilder.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLVMBuilder.h"

@implementation YASLVMBuilder

- (BOOL) attachRAM:(YASLVM *)vm {
	vm.ram = [YASLRAM ramWithSize:DEFAULT_RAM_SIZE];
	return !!vm.ram;
}

- (BOOL) attachStack:(YASLVM *)vm {
	vm.stack = [YASLStack stackForRAM:vm.ram];
	return !!vm.stack;
}

- (BOOL) attachCPU:(YASLVM *)vm {
	vm.cpu = [YASLCPU cpu];
	vm.cpu.ram = vm.ram;
	vm.cpu.stack = vm.stack;
	vm.cpu.memoryManager = vm.memManager;
	return !!vm.cpu;
}

- (BOOL) attachMemoryManager:(YASLVM *)vm {
	vm.memManager = [YASLMemoryManager memoryManagerForRAM:vm.ram];
	return !!vm.memManager;
}

- (BOOL) attachStringManager:(YASLVM *)vm {
	vm.stringManager = [YASLStrings new];
	vm.stringManager.ram = vm.ram;
	vm.stringManager.memManager = vm.memManager;
	return !!vm.stringManager;
}

- (BOOL) attachCompiler:(YASLVM *)vm {
	vm.compiler = [YASLCompiler new];
	vm.compiler.targetRAM = vm.ram;
	vm.compiler.stringsManager = vm.stringManager;
	vm.compiler.memoryManager = vm.memManager;
	return !!vm.compiler;
}

@end
