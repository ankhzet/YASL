//
//  YASLNativeFunctionSpec.m
//  YASL
//  Spec for YASLNativeFunction
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "TestUtils.h"
#import "YASLNativeFunction.h"
#import "YASLNativeInterface.h"
#import "YASLVMBuilder.h"
#import "YASLNativeFunctions.h"
#import "YASLNativeFunction.h"

@interface TestInterface : YASLNativeInterface

@end

@implementation TestInterface

- (void) registerNativeFunctions {
	[super registerNativeFunctions];

	[self registerNativeFunction:@"f1" withParamCount:0 returnType:YASLBuiltInTypeIdentifierFloat withSelector:@selector(testFunc1:atParamBase:)];
	[self registerNativeFunction:@"f2" withParamCount:1 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(testFunc2:atParamBase:)];
	[self registerNativeFunction:@"f3" withParamCount:2 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(testFunc3:atParamBase:)];
	[self registerNativeFunction:@"f4" withParamCount:3 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(testFunc4:atParamBase:)];
}

- (YASLInt) testFunc1:(YASLNativeFunction *)native atParamBase:(void *)paramsBase {
	YASLFloat f = 10.f;
	return *(YASLInt *)&f;
}

- (YASLInt) testFunc2:(YASLNativeFunction *)native atParamBase:(void *)paramsBase {
	YASLInt p1 = [native intParam:1 atBase:paramsBase];
	[native.cpu setReg:YASLRegisterIR1 value:p1];
	return 20;
}

- (YASLInt) testFunc3:(YASLNativeFunction *)native atParamBase:(void *)paramsBase {
	YASLInt p1 = [native intParam:1 atBase:paramsBase];
	YASLInt p2 = [native intParam:2 atBase:paramsBase];
	[native.cpu setReg:YASLRegisterIR1 value:p1];
	[native.cpu setReg:YASLRegisterIR2 value:p2];
	return 30;
}

- (YASLInt) testFunc4:(YASLNativeFunction *)native atParamBase:(void *)paramsBase {
	YASLInt p1 = [native intParam:1 atBase:paramsBase];
	YASLFloat p2 = [native floatParam:2 atBase:paramsBase];
	YASLInt p3 = [native intParam:3 atBase:paramsBase];
	[native.cpu setReg:YASLRegisterIR1 value:p1];
	[native.cpu setReg:YASLRegisterIR2 valuef:p2];
	[native.cpu setReg:YASLRegisterIR3 value:p3];
	return 40;
}

@end

SPEC_BEGIN(YASLNativeFunctionSpec)

describe(@"YASLNativeFunction", ^{
//	it(@"should properly initialize", ^{
//		YASLNativeFunction *instance = [YASLNativeFunction new];
//		[[instance shouldNot] beNil];
//		[[instance should] beKindOfClass:[YASLNativeFunction class]];
//	});

	it(@"should ", ^{
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];
		YASLRAM *ram = vm.ram;
		YASLStack *stack = vm.stack;
		YASLCPU *cpu = vm.cpu;
		memset([ram dataAt:0], 0, ram.size);

		TestInterface *i = [TestInterface new];
		YASLNativeFunction *native1 = [[YASLNativeFunctions sharedFunctions] findByName:@"f1"];
		YASLNativeFunction *native2 = [[YASLNativeFunctions sharedFunctions] findByName:@"f2"];
		YASLNativeFunction *native3 = [[YASLNativeFunctions sharedFunctions] findByName:@"f3"];
		YASLNativeFunction *native4 = [[YASLNativeFunctions sharedFunctions] findByName:@"f4"];


		YASLInt ramOffset = 0;

		CPU_PUTINSTR(ramOffset, OPC_NATIV, YASLOperandCountUnary, YASLOperandTypeImmediate, 0, 0, 0);
		CPU_PUTVAL(ramOffset, native1.GUID);
		CPU_PUTINSTR(ramOffset, OPC_NATIV, YASLOperandCountUnary, YASLOperandTypeImmediate, 0, 0, 0);
		CPU_PUTVAL(ramOffset, native2.GUID);
		CPU_PUTINSTR(ramOffset, OPC_NATIV, YASLOperandCountUnary, YASLOperandTypeImmediate, 0, 0, 0);
		CPU_PUTVAL(ramOffset, native3.GUID);
		CPU_PUTINSTR(ramOffset, OPC_NATIV, YASLOperandCountUnary, YASLOperandTypeImmediate, 0, 0, 0);
		CPU_PUTVAL(ramOffset, native4.GUID);

		[cpu processInstruction];
		[[@([cpu regValuef:YASLRegisterIR0]) should] equal:10.f withDelta:0.1];

		[stack push:0x11];

		[cpu processInstruction];
		[[@((YASLInt)[cpu regValue:YASLRegisterIR0]) should] equal:@(20)];
		[[@((YASLInt)[cpu regValue:YASLRegisterIR1]) should] equal:@(0x11)];

		[stack push:0x22];
		[stack push:0x33];

		[cpu processInstruction];
		[[@((YASLInt)[cpu regValue:YASLRegisterIR0]) should] equal:@(30)];
		[[@((YASLInt)[cpu regValue:YASLRegisterIR1]) should] equal:@(0x22)];
		[[@((YASLInt)[cpu regValue:YASLRegisterIR2]) should] equal:@(0x33)];

		[stack push:0x44];
		[stack pushf:0.15];
		[stack push:0x66];

		[cpu processInstruction];
		[[@([cpu regValue:YASLRegisterIR0]) should] equal:@(40)];
		[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(0x44)];
		[[@([cpu regValuef:YASLRegisterIR2]) should] equal:0.15 withDelta:0.01];
		[[@([cpu regValue:YASLRegisterIR3]) should] equal:@(0x66)];

		[i class];
	});
});

SPEC_END
