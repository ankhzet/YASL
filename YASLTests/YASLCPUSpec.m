//
//  YASLCPUSpec.m
//  YASL
//  Spec for YASLCPU
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLCPU.h"
#import "YASLRAM.h"
#import "YASLStack.h"
#import "YASLOpcodes.h"
#import "YASLNativeFunction.h"
#import "YASLNativeFunctions.h"
#import "YASLStrings.h"
#import "TestUtils.h"

SPEC_BEGIN(YASLCPUSpec)

describe(@"YASLCPU", ^{
	it(@"should properly initialize", ^{
		YASLCPU *instance = [YASLCPU new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLCPU class]];
	});

	context(@"instructions", ^{
		__block YASLCPU *cpu = nil;
		__block YASLRAM *ram = nil;
		__block YASLStack *stack = nil;

		beforeEach(^{
			cpu = [YASLCPU cpuWithRAMSize:256];
			ram = cpu->ram;
			stack = cpu->stack;
			stack.base = 16;
			stack.size = ram.size - stack.base;
			[cpu setReg:YASLRegisterIIP value:0];
		});

		it(@"should process different operand types & placement", ^{
			YASLInt immAddress = 128;
			YASLInt immediate = 11;
			YASLInt regOffsVal = 26;
			YASLInt regOffsVal2 = 57;
			YASLInt regOffset = 17;
			YASLInt r1Val = 7;
			YASLInt r2Val = 150;
			YASLInt r3Val = 100;
			[ram setInt:immediate at:immAddress]; // immediate value
			[ram setInt:regOffsVal at:r2Val + regOffset]; // immediate value
			[ram setInt:regOffsVal2 at:r3Val - regOffset]; // immediate value

			[cpu setReg:YASLRegisterIR1 value:r1Val]; // register value
			[cpu setReg:YASLRegisterIR2 value:r2Val]; // register value
			[cpu setReg:YASLRegisterIR3 value:r3Val]; // register value

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_ADD,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister,
									 YASLOperandTypeImmediate | YASLOperandTypePointer,
									 YASLRegisterIR1, 0
									 ); // OPC_ADD r1, [immAddress]
			CPU_PUTVAL(ramOffset, immAddress);
			YASLInt o1 = ramOffset;

			CPU_PUTINSTR(
									 ramOffset, OPC_ADD,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister,
									 YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_ADD r1, immAddress
			CPU_PUTVAL(ramOffset, immAddress);
			YASLInt o2 = ramOffset;

			CPU_PUTINSTR(
									 ramOffset, OPC_ADD,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer,
									 YASLOperandTypeImmediate | YASLOperandTypePointer,
									 YASLRegisterIR2, 0
									 ); // OPC_ADD [r2+regOffset], [immAddress]
			CPU_PUTVAL(ramOffset, immAddress);
			CPU_PUTVAL(ramOffset, regOffset);
			YASLInt o3 = ramOffset;

			CPU_PUTINSTR(
									 ramOffset, OPC_ADD,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer,
									 YASLOperandTypeImmediate,
									 YASLRegisterIR3, 0
									 ); // OPC_ADD [r3-regOffset], immediate
			CPU_PUTVAL(ramOffset, immediate);
			CPU_PUTVAL(ramOffset, -regOffset);
			YASLInt o4 = ramOffset;

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIIP]) should] equal:@(o1)];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(18)];

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIIP]) should] equal:@(o2)];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(146)];

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIIP]) should] equal:@(o3)];
			[[@([ram intAt:[cpu regValue:YASLRegisterIR2] + regOffset]) should] equal:@(regOffsVal + immediate)];

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIIP]) should] equal:@(o4)];
			[[@([ram intAt:[cpu regValue:YASLRegisterIR3] - regOffset]) should] equal:@(regOffsVal2 + immediate)];
		});

		it(@"should process OPC_ADD instruction", ^{
			YASLInt immediate = 11;
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_ADD,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister, YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_ADD r1, immediate
			CPU_PUTVAL(ramOffset, immediate);

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(18)];

		});
		
		it(@"should process OPC_SUB instruction", ^{
			YASLInt immediate = 11;
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_SUB,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister, YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_SUB r1, immediate
			CPU_PUTVAL(ramOffset, immediate);

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(-4)];

		});
		
		it(@"should process OPC_MUL instruction", ^{
			YASLInt immediate = 11;
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_MUL,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister, YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_MUL r1, immediate
			CPU_PUTVAL(ramOffset, immediate);

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(77)];

		});
		
		it(@"should process OPC_DIV instruction", ^{
			YASLInt immediate = 11;
			YASLInt r1Val = 88;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_DIV,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister, YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_DIV r1, immediate
			CPU_PUTVAL(ramOffset, immediate);

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(8)];

		});
		
		it(@"should process OPC_INC instruction", ^{
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_INC,
									 YASLOperandCountUnary,
									 YASLOperandTypeRegister, 0,
									 YASLRegisterIR1, 0
									 ); // OPC_INC r1

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(8)];
		});
		
		it(@"should process OPC_DEC instruction", ^{
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_DEC,
									 YASLOperandCountUnary,
									 YASLOperandTypeRegister, 0,
									 YASLRegisterIR1, 0
									 ); // OPC_DEC r1

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(6)];

		});
		
		it(@"should process OPC_MOV instruction", ^{
			YASLInt immediate = 11;
			YASLInt r1Val = 7;
			[cpu setReg:YASLRegisterIR1 value:r1Val];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_MOV,
									 YASLOperandCountBinary,
									 YASLOperandTypeRegister, YASLOperandTypeImmediate,
									 YASLRegisterIR1, 0
									 ); // OPC_MOV r1, immediate
			CPU_PUTVAL(ramOffset, immediate);

			[cpu processInstruction];
			[[@([cpu regValue:YASLRegisterIR1]) should] equal:@(11)];

		});

		it(@"should process OPC_NATIV instruction", ^{
			YASLNativeFunction *native = [[YASLNativeFunctions sharedFunctions] findByName:@"sqrt"];

			YASLInt ramOffset = 0;
			CPU_PUTINSTR(ramOffset, OPC_NATIV,
									 YASLOperandCountUnary,
									 YASLOperandTypeImmediate, 0,
									 0, 0
									 ); // OPC_NATIV ->current_thread
			CPU_PUTVAL(ramOffset, native.GUID);
			[stack pushf:0.16f];

			[cpu setReg:YASLRegisterIR0 value:0];
			[cpu processInstruction];
//			[[@((YASLFloat)[cpu regValue:YASLRegisterIR0]) should] equal:@(0.4f)];

		});

	});

});

SPEC_END
