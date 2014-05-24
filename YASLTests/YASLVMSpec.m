//
//  YASLVMSpec.m
//  YASL
//  Spec for YASLVM
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLVMBuilder.h"

SPEC_BEGIN(YASLVMSpec)

describe(@"YASLVM", ^{
	it(@"should properly initialize", ^{
		YASLVM *instance = [YASLVM new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLVM class]];
	});

	it(@"should compile and run test script", ^{
		YASLVM *vm = [[YASLVMBuilder new] buildVM];
		[[vm shouldNot] beNil];
		[[vm.ram shouldNot]beNil];
		[[vm.stack shouldNot] beNil];
		[[vm.cpu shouldNot] beNil];
		[[vm.compiler shouldNot] beNil];

		NSURL *url = [[NSBundle mainBundle] URLForResource:@"test1" withExtension:@"yasl"];
		YASLCompiledUnit *unit = [vm runScript:[YASLCodeSource codeSourceFromFile:url]];
		[[unit shouldNot] beNil];
		[[theValue(unit.stage) should] equal:theValue(YASLUnitCompilationStageCompiled)];

		[vm.cpu run];
	});


	context(@"compilation", ^{
		YASLVM *vm = [[YASLVMBuilder new] buildVM];

		it(@"should compile loops", ^{
			NSDictionary *sources =
			@{
				@"result = 14; int c = 5; while (c-- > 0) result++;": @(19),
				@"result = 14; int c = 5; while (c-- > 0) { result++; if (result > 16) break; };": @(17),
				@"result = 14; int c = 5; while (c-- > 0) { if (c == 3) continue; result++; }": @(18),

				@"result = 14; for (int i = 10; i > 3; i--) { result++; }": @(21),
				@"result = 14; int i = 21; for (; i > 3; i--) { result++; }": @(32),
				@"result = 14; int i = 21; for (;; i--) { result++; if (i < 6) break; }": @(31),
				@"result = 14; int i = 21; for (; i > 2;) { i--; result++; }": @(33),
				@"result = 14; int i = 21; for (; i < 15 * 2; i += 2) { result++; }": @(19),
				};


			int i = 0;
			for (NSString *src in [sources allKeys]) {
				i++;
				NSString *identifier = [NSString stringWithFormat:@"loop%d", i];
				NSString *code = [NSString stringWithFormat:@"script %@;\nint main(void *arg){int result = 0;\n%@\nreturn result;\n}", identifier, src];

				YASLCompiledUnit *unit = [vm runScript:[YASLCodeSource codeSource:identifier fromString:code]];
				[[unit shouldNot] beNil];
				[[theValue(unit.stage) should] equal:theValue(YASLUnitCompilationStageCompiled)];
				[vm.cpu run];
				[[theValue([vm.cpu regValue:YASLRegisterIR0]) should] equal:theValue([sources[src] integerValue])];
				for (YASLThread *thread in [unit enumerateOwners])
					[vm.cpu thread:thread->handle terminate:0];

			}
			
		});

		it(@"should compile functions", ^{
			NSDictionary *sources =
			@{
				@"int test() {return 12;}": @(12),
				@"int _1() {return 1;} int test() {return _1() + 2;}": @(3),
				@"int a_1(int a, b, c) {return a;} int a_2(int a, b, c) {return b;} int a_3(int a, b, c) {return c;} int test() {return a_1(1,2,3) + a_2(4,5,6) + a_3(7,8,9);}": @(15),
				@"int _1() {return 1;} int _1() {return 2;} int test() {return _1() + 2;}": [NSNull null],
				};


			int i = 0;
			for (NSString *src in [sources allKeys]) {
				i++;
				NSString *identifier = [NSString stringWithFormat:@"func%d", i];
				NSString *code = [NSString stringWithFormat:@"script %@;\n%@\nint main(void *arg){return test();\n}", identifier, src];
				NSNumber *value = sources[src];

				YASLCompiledUnit *unit = [vm runScript:[YASLCodeSource codeSource:identifier fromString:code]];
				[[unit shouldNot] beNil];
				if (value == (id)[NSNull null]) {
					[[theValue(unit.stage) shouldNot] equal:theValue(YASLUnitCompilationStageCompiled)];
					continue;
				}
				[[theValue(unit.stage) should] equal:theValue(YASLUnitCompilationStageCompiled)];
				[vm.cpu run];
				[[theValue([vm.cpu regValue:YASLRegisterIR0]) should] equal:theValue([value integerValue])];
				for (YASLThread *thread in [unit enumerateOwners])
					[vm.cpu thread:thread->handle terminate:0];

			}
			
		});
	});

});

SPEC_END
