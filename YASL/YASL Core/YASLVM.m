//
//  YASLVM.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLVM.h"
#import "YASLCompiledUnit.h"
#import "YASLCoreLangClasses.h"

#import "YASLDisassembler.h"

@implementation YASLVM

- (YASLCompiledUnit *)runScript:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = [self scriptInStage:YASLUnitCompilationStagePrecompiled|YASLUnitCompilationStageCompiled bySource:source];

	if (!unit) {
		unit = [self.compiler compilationPass:source
															withOptions:@{ kCompilatorPrecompile:@YES }];

		if (unit.stage == YASLUnitCompilationStagePrecompiled) {
			YASLInt threadOffset = [self calcCodePlacement:unit.codeLength];
			[self.compiler compilationPass:source
												 withOptions:@{
																			 kCompilatorCompile:@YES,
																			 kCompilatorPlacementOffset:@(threadOffset)
																			 }];
		}

	}

	if (unit.stage == YASLUnitCompilationStageCompiled) {
		YASLInt stackOffset = [self.cpu threadsCount] * DEFAULT_THREAD_STACK_SIZE + DEFAULT_STACK_BASE;
		YASLLocalDeclaration *mainMethod = [unit findSymbol:@"main"];
		YASLInt mainSymbol = [mainMethod.reference complexAddress];

		YASLThread *thread = [self.cpu threadCreateWithEntryAt:mainSymbol andState:YASLThreadStateRunning andInitParam:0 waitable:NO];
		[thread setReg:YASLRegisterISP value:stackOffset];
		[thread setReg:YASLRegisterIBP value:stackOffset];
		[unit usedByThread:thread];

//		NSLog(@"Disassembling \"%@\":\n%@", source.identifier, [[self disassembly:source] componentsJoinedByString:@"\n"]);
	}
	return unit;
}

- (YASLInt) calcCodePlacement:(YASLInt)codeLength {
	NSRange r = NSMakeRange(0, 0);
	for (YASLCompiledUnit *unit in [self.compiler enumerateCompiledUnits]) {
		if (unit.stage != YASLUnitCompilationStageCompiled)
			continue;

		r = NSUnionRange(r, NSMakeRange(unit.startOffset, unit.codeLength));
	}

	return r.location + r.length;
}

- (YASLCompiledUnit *) scriptInStage:(YASLUnitCompilationStage)stage bySource:(YASLCodeSource *)source {
	NSEnumerator *compiled = [self.compiler enumerateCompiledUnits];
	for (YASLCompiledUnit *compiledUnit in compiled) {
    if (!(compiledUnit.stage & stage))
			continue;

		if (compiledUnit.source.identifier == source.identifier)
			return compiledUnit;
	}

	return nil;
}

- (NSArray *) disassembly:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = [self scriptInStage:YASLUnitCompilationStagePrecompiled|YASLUnitCompilationStageCompiled bySource:source];
	YASLDisassembler *disassembler = [YASLDisassembler disassemblerForCPU:self.cpu];
	[disassembler setLabelsRefs:[self.compiler cache:source.identifier data:kCacheStaticLabels]];
	NSString *disasm = [disassembler disassembleFrom:unit.startOffset to:unit.startOffset + unit.codeLength];
	return [disasm componentsSeparatedByString:@"\n"];
}

@end

@implementation YASLAbstractVMBuilder

- (YASLVM *) newVM {
	return [YASLVM new];
}

- (BOOL) attachRAM:(YASLVM *)vm {
	return !!vm.ram;
}

- (BOOL) attachStack:(YASLVM *)vm {
	return !!vm.stack;
}

- (BOOL) attachCPU:(YASLVM *)vm {
	return !!vm.cpu;
}

- (BOOL) attachCompiler:(YASLVM *)vm {
	return !!vm.compiler;
}

- (YASLVM *)buildVM {
	YASLVM *vm = [self newVM];

	if (![self attachRAM:vm])
		return nil;

	if (![self attachStack:vm])
		return nil;

	if (![self attachCPU:vm])
		return nil;

	if (![self attachCompiler:vm])
		return nil;

	return vm;
}

@end