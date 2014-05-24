//
//  YASLAssemblerSpec.m
//  YASL
//  Spec for YASLAssembler
//
//  Created by Ankh on 02.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"
#import "YASLDisassembler.h"
#import "YASLVMBuilder.h"
#import "YASLCoreLangClasses.h"

SPEC_BEGIN(YASLAssemblerSpec)

describe(@"YASLAssembler", ^{

	it(@"should properly initialize", ^{
		YASLAssembler *instance = [YASLAssembler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLAssembler class]];
	});

	it(@"should assemble script definition", ^{
		NSString *source = @"script test;";

		YASLAssembler *assembler = [YASLAssembler new];

		YASLTranslationUnit *result = [assembler assembleSource:source];
		[[result shouldNot] beNil];
		[[result should] beKindOfClass:[YASLTranslationUnit class]];
		[[result.name should] equal:@"test"];
	});


	it(@"should asemble expressions", ^{
		NSString *source1 = @"script test;\r\
		typedef int myInt;\r\
		int k = 10;\r\
		myInt l = 20;\r\
		int func(int param1, param2; bool param3) {\r\
		int u = 10 * (3 + param2);\r\
		int j = param1 + u;\
		if (l > u)\r\
			return l;\r\
		j++;\r\
		return param3 ? j + k : j + 1;\r\
		}\r\
		int h = func(2, 3, 9) + 1;\r\
		";

		YASLDataTypesManager *typeManager = [YASLDataTypesManager new];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		[typeManager registerType:[YASLBuiltInTypeFloatInstance new]];
		[typeManager registerType:[YASLBuiltInTypeBoolInstance new]];
		[typeManager registerType:[YASLBuiltInTypeCharInstance new]];
		YASLLocalDeclarations *globalDeclarationScope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLAssembler *assembler = [YASLAssembler new];
		[assembler setDeclarationScope:globalDeclarationScope];

		YASLTranslationUnit *result1 = [assembler assembleSource:source1];
		[[result1 shouldNot] beNil];
		NSLog(@"%@", result1);


		YASLDeclarationScope *globalScope = globalDeclarationScope.currentScope;

		YASLAssembly *assembly = [YASLAssembly new];
		[result1 assemble:assembly];
		[globalScope.placementManager calcPlacementForScope:globalScope];

		NSUInteger ramSize = 2048;
		YASLInt ip = 128;
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];
		YASLRAM *ram = vm.ram;
		YASLCPU *cpu = vm.cpu;
		memset([ram dataAt:0], 0, ramSize);
		[cpu setReg:YASLRegisterIIP value:ip];
		[cpu setReg:YASLRegisterISP value:DEFAULT_STACK_BASE];

		void *frame = [ram dataAt:ip], *codePtr = frame;
		[assembly push:OPC_(HALT)];
		assembly = [[YASLAssembly alloc] initReverseAssembly:assembly];
		NSMutableArray *labels = [@[] mutableCopy];
		while ([assembly notEmpty]) {
			id top = [assembly pop];
			if ([top isKindOfClass:[YASLOpcode class]]) {
				codePtr = [((YASLOpcode *)top) toCodeInstruction:codePtr];
			} else if ([top isKindOfClass:[YASLCodeAddressReference class]]) {
				YASLCodeAddressReference *ref = top;
				[labels addObject:@[ref, @(ip + (codePtr - frame))]];
			}
		}

//		[globalDeclarationScope.currentScope offsetDeclarationsBy:codePtr - frame];

		NSLog(@"\n\n\n");
//		[globalScope.placementManager calcPlacementForScope:globalScope];
		[globalScope.placementManager offset:(ip + (codePtr-frame)) scope:globalScope];

		[globalScope propagateReferences];

		for (NSArray *ref in labels) {
			((YASLCodeAddressReference *)ref[0]).address = [ref[1] intValue];
		}

		[assembly restoreFullStack];

		memset([ram dataAt:0], 0, ramSize);
		codePtr = frame;
		while ([assembly notEmpty]) {
			id top = [assembly pop];
			if ([top isKindOfClass:[YASLOpcode class]]) {
				codePtr = [((YASLOpcode *)top) toCodeInstruction:codePtr];
			}
		}

		YASLDisassembler *disassembler = [YASLDisassembler disassemblerForCPU:cpu];

		NSString *trace = [disassembler disassembleFrom:ip to:ip + (codePtr - frame) + 1];
		NSLog(@"ASM trace:\n%@", trace);
	});
});

SPEC_END
