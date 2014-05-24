//
//  YASLCompilerSpec.m
//  YASL
//  Spec for YASLCompiler
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLCompiler.h"
#import "YASLCodeSource.h"
#import "YASLCompiledUnit.h"

#import "YASLDisassembler.h"
#import "YASLVMBuilder.h"
#import "YASLCoreLangClasses.h"

SPEC_BEGIN(YASLCompilerSpec)

describe(@"YASLCompiler", ^{
	it(@"should properly initialize", ^{
		YASLCompiler *instance = [YASLCompiler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLCompiler class]];
	});

	it(@"should precompile scripts", ^{
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];

		YASLCompiler *compiler = [YASLCompiler new];
		[compiler setTargetRAM:vm.ram];

		NSString *testIdentifier = @"test";
		NSString *testCode = @"script test;";
		YASLCodeSource *source = [YASLCodeSource codeSource:testIdentifier fromString:testCode];
		YASLCompiledUnit *compiled = [compiler compilationPass:source withOptions:@{kCompilatorPrecompile:@YES}];

		[[compiled shouldNot] beNil];
		[[compiled.source.identifier should] equal:testIdentifier];
		[[theValue(compiled.stage) should] equal:theValue(YASLUnitCompilationStagePrecompiled)];

		[[theValue([compiler dropAssociatedCaches:testIdentifier]) should] beYes];

		NSUInteger threadOffset = 100;

		YASLCompiledUnit *_compiled = [compiler compilationPass:source withOptions:@{kCompilatorCompile:@YES, kCompilatorPlacementOffset: @(threadOffset)}];
		[[_compiled should] beIdenticalTo:compiled];

		YASLDisassembler *disassembler = [YASLDisassembler disassemblerForCPU:vm.cpu];
		[disassembler setLabelsRefs:[compiler cache:source.identifier data:kCacheStaticLabels]];
		NSString *disasm = [disassembler disassembleFrom:compiled.startOffset to:compiled.startOffset + compiled.codeLength];
		NSLog(@"%@", disasm);



		threadOffset = 100;
		NSURL *url = [[NSBundle mainBundle] URLForResource:@"test1" withExtension:@"yasl"];
		YASLCodeSource *source2 = [YASLCodeSource codeSourceFromFile:url];
		YASLCompiledUnit *compiled2 = [compiler
																	 compilationPass:source2
																	 withOptions:@{
																								 kCompilatorPrecompile:@YES,
																								 kCompilatorCompile:@YES,
																								 kCompilatorPlacementOffset: @(threadOffset)
																								 }];

		[disassembler setLabelsRefs:[compiler cache:source2.identifier data:kCacheStaticLabels]];
		disasm = [disassembler disassembleFrom:compiled2.startOffset to:compiled2.startOffset + compiled2.codeLength];
		NSLog(@"%@", disasm);
	});

});

SPEC_END
