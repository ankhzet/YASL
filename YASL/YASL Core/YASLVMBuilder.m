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
	vm.stack.size = DEFAULT_THREAD_STACK_SIZE;
	*vm.stack.top = DEFAULT_STACK_BASE;
	return !!vm.stack;
}

- (BOOL) attachCPU:(YASLVM *)vm {
	vm.cpu = [YASLCPU cpu];
	vm.cpu.ram = vm.ram;
	vm.cpu.stack = vm.stack;
	return !!vm.cpu;
}

- (BOOL) attachCompiler:(YASLVM *)vm {
	vm.compiler = [YASLCompiler new];
	[vm.compiler setTargetRAM:vm.ram];
	return !!vm.compiler;
}

@end
