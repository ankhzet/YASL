//
//  YASLCodeOptimizer.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCodeOptimizer.h"
#import "YASLVM.h"
#import "YASLCoreLangClasses.h"
#import "YASLUnwantedMovCallStrategy.h"
#import "YASLUnwantedMovMovStrategy.h"
#import "YASLUnwantedMovPushStrategy.h"

@implementation YASLCodeOptimizer {
	NSDictionary *opcodeOperandsAccessTypes;
	NSDictionary *opcodeTypesCache;
	NSArray *optimizationStrategies;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	optimizationStrategies = @[
														 [YASLUnwantedMovCallStrategy class],
														 [YASLUnwantedMovMovStrategy class],
														 [YASLUnwantedMovPushStrategy class]
														 ];

	opcodeTypesCache = @{@NO:[NSMutableDictionary dictionary], @YES: [NSMutableDictionary dictionary]};
	opcodeOperandsAccessTypes =
	@{
		@(OPC_NOP):@(YASLOperandAccessTypeNone),

		// arithmetic
		@(OPC_ADD):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_SUB):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_MUL):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_DIV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_RST):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_INC):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst),
		@(OPC_DEC):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst),
		@(OPC_MOV):@(YASLOperandAccessTypeReadSecond| YASLOperandAccessTypeWriteFirst),
		@(OPC_INV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst),
		@(OPC_NEG):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst),

		// binary logic
		@(OPC_NOT):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst),
		@(OPC_OR):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_AND):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_XOR):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_SHL):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),
		@(OPC_SHR):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond | YASLOperandAccessTypeWriteFirst),

		// stack
		@(OPC_PUSH):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsStack),
		@(OPC_PUSHV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsStack),
		@(OPC_POP):@(YASLOperandAccessTypeWriteFirst | YASLOperandAccessTypeImpactsStack),
		@(OPC_POPV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsStack),
		@(OPC_SAVE):@(YASLOperandAccessTypeReadAll | YASLOperandAccessTypeImpactsStack),
		@(OPC_LOAD):@(YASLOperandAccessTypeWriteAll | YASLOperandAccessTypeImpactsStack),

		// routins
		@(OPC_CALL):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeModifiesR0 | YASLOperandAccessTypeImpactsFlow | YASLOperandAccessTypeImpactsStack),
		@(OPC_RET):@(YASLOperandAccessTypeImpactsFlow | YASLOperandAccessTypeImpactsStack),
		@(OPC_RETV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow | YASLOperandAccessTypeImpactsStack), // return and move stack pointer
		@(OPC_NATIV):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeModifiesR0 | YASLOperandAccessTypeImpactsStack),

		// branching
		@(OPC_JMP):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_TEST):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeReadSecond),
		@(OPC_JZ):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_JNZ):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_JGT):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_JLT):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_JGE):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),
		@(OPC_JLE):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeImpactsFlow),

		@(OPC_CVIF):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert int > float
		@(OPC_CVIB):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert int > bool
		@(OPC_CVFI):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert float > int
		@(OPC_CVFB):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert float > bool
		@(OPC_CVFC):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert float > char
		@(OPC_CVCF):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert char > float
		@(OPC_CVCB):@(YASLOperandAccessTypeReadFirst | YASLOperandAccessTypeWriteFirst), // convert char > bool

		@(OPC_HALT):@(YASLOperandAccessTypeImpactsFlow),
		};

	return self;
}

- (YASLOperandAccessType) opcodeOperandAccessType:(YASLOpcodes)opcode {
	return [opcodeOperandsAccessTypes[@(opcode)] unsignedIntegerValue];
}

- (NSArray *) opcodesWithType:(YASLOperandAccessType)type strictMatch:(BOOL)strictMatch {
	NSMutableDictionary *cacheStrict = opcodeTypesCache[@(strictMatch)];
	NSArray *cache = cacheStrict[@(type)];
	if (!cache) {
		NSMutableArray *fetched = [NSMutableArray array];
		for (NSNumber *opcodeNum in [opcodeOperandsAccessTypes allKeys]) {
			NSNumber *accessTypes = opcodeOperandsAccessTypes[opcodeNum];
			YASLOperandAccessType match = [accessTypes unsignedIntegerValue] & type;
			if (strictMatch ? (match == type) : (match)) {
				[fetched addObject:opcodeNum];
			}
		}
		cache = cacheStrict[@(type)] = fetched;
	}
	return cache;
}

- (void) optimize:(YASLAssembly *)a {
	NSUInteger applyes, passes = 0;
	do {
		passes++;
		applyes = 0;
		for (Class strategyClass in optimizationStrategies) {
			YASLASMOptimizationStrategy *strategy = [strategyClass strategyForAssembly:a withHelper:self];
			applyes += [strategy optimize];
		}
		if (applyes)
			NSLog(@"Optimizer pass #%u: applied %u minor optimizations", passes, applyes);
	} while (applyes);
}

@end
