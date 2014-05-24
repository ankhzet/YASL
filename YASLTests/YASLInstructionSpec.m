//
//  YASLInstructionSpec.m
//  YASL
//  Spec for YASLInstruction
//
//  Created by Ankh on 27.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "TestUtils.h"
#import "YASLInstruction.h"
#import "YASLVMBuilder.h"

SPEC_BEGIN(YASLInstructionSpec)

describe(@"YASLInstruction", ^{
	it(@"should properly initialize", ^{
		YASLInstruction *instance = [YASLInstruction new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLInstruction class]];
	});

	it(@"should parse unary instructions", ^{
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];
		YASLRAM *ram = vm.ram;
		memset([ram dataAt:0], 0, ram.size);

		YASLInt ramOffset = 0;
		YASLInstruction *i = [YASLInstruction new];

		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountUnary, YASLOperandTypeRegister, 0, YASLRegisterIR1, 0);
		CPU_PUTINSTR(ramOffset, OPC_JMP, YASLOperandCountUnary, YASLOperandTypeImmediate, 0, 0, 0);
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountUnary, YASLOperandTypeRegister | YASLOperandTypeImmediate, 0, YASLRegisterIR2, 0);
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountUnary, YASLOperandTypeRegister | YASLOperandTypePointer, 0, YASLRegisterIR3, 0);
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountUnary, YASLOperandTypeImmediate | YASLOperandTypePointer, 0, 0, 0);

		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 0]];
		[[[i description] should] equal:@"INC   R1"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 1]];
		[[[i description] should] equal:@"JMP   ###"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 2]];
		[[[i description] should] equal:@"INC   R2+###"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 3]];
		[[[i description] should] equal:@"INC   [R3]"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 4]];
		[[[i description] should] equal:@"INC   [###]"];
	});

	it(@"should parse binary instructions", ^{
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];
		YASLRAM *ram = vm.ram;
		memset([ram dataAt:0], 0, ram.size);

		YASLInt ramOffset = 0;
		YASLInstruction *i = [YASLInstruction new];

		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountUnary, YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer, 0, YASLRegisterIR1, 0);
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister,
								 YASLOperandTypeRegister,
								 YASLRegisterIR1, YASLRegisterIR2
								 );
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeImmediate | YASLOperandTypePointer,
								 YASLOperandTypeRegister,
								 0, YASLRegisterIR2
								 );
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister,
								 YASLOperandTypeImmediate,
								 YASLRegisterIR1, 0
								 );
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer,
								 YASLOperandTypeRegister,
								 YASLRegisterIR2, YASLRegisterIR3
								 );
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate,
								 YASLRegisterIR1, YASLRegisterIR2
								 );
		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer,
								 YASLRegisterIR1, YASLRegisterIR2
								 );

		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 0]];
		[[[i description] should] equal:@"INC   [R1+###]"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 1]];
		[[[i description] should] equal:@"INC   R1, R2"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 2]];
		[[[i description] should] equal:@"INC   [###], R2"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 3]];
		[[[i description] should] equal:@"INC   R1, ###"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 4]];
		[[[i description] should] equal:@"INC   [R2+###], R3"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 5]];
		[[[i description] should] equal:@"INC   R1, R2+###"];
		[i setInstruction:[ram dataAt:sizeof(YASLCodeInstruction) * 6]];
		[[[i description] should] equal:@"INC   R1+###, [R2+###]"];
		
	});

	it(@"should parse immediates", ^{
		YASLVMBuilder *builder = [YASLVMBuilder new];
		YASLVM *vm = [builder buildVM];
		YASLRAM *ram = vm.ram;
		memset([ram dataAt:0], 0, ram.size);

		YASLInt ramOffset = 0;
		YASLInstruction *i = [YASLInstruction new];

		CPU_PUTINSTR(ramOffset, OPC_INC, YASLOperandCountBinary,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate,
								 YASLOperandTypeRegister | YASLOperandTypeImmediate | YASLOperandTypePointer,
								 YASLRegisterIR1, YASLRegisterIR2
								 );
		[i setImmediatePtr:[ram dataAt:ramOffset]];
		CPU_PUTVAL(ramOffset, -18);
		CPU_PUTVAL(ramOffset, 12345);

		[i setInstruction:[ram dataAt:0]];
		[[[i description] should] equal:@"INC   R1+12345, [R2-18]"];
	});
});

SPEC_END
