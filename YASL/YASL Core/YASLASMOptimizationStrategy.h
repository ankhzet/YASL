//
//  YASLASMOptimizationStrategy.h
//  YASL
//
//  Created by Ankh on 16.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLOpcodes.h"

@protocol YASLOptimizationStrategyHelper <NSObject>

- (YASLOperandAccessType) opcodeOperandAccessType:(YASLOpcodes)opcode;
- (NSArray *) opcodesWithType:(YASLOperandAccessType)type strictMatch:(BOOL)strictMatch;

@end

@class YASLAssembly, YASLOpcode, YASLOpcodeOperand;
@interface YASLASMOptimizationStrategy : NSObject

@property (nonatomic) id<YASLOptimizationStrategyHelper> helper;
@property (nonatomic) YASLAssembly *assembly;
@property (nonatomic) NSUInteger baseState;


+ (instancetype) strategyForAssembly:(YASLAssembly *)assembly withHelper:(id<YASLOptimizationStrategyHelper>)helper;

/*!
 @brief Optimize supplied asm assembly with receiver strategy.
 @return Returns count of successful optimizations.
 */
- (NSUInteger) optimize;

@end

@interface YASLASMOptimizationStrategy (Protected)

/*! Run optimization on supplied assembly. */
- (NSUInteger) optimizationPass;
/*! Returns YES, if assembly contains piece of code, that, proubably, can be optimized. */
- (BOOL) applyable;
/*! If assembly contains piece of code, that can be optimized, then optimizes it and returns YES, NO otherwise. */
- (BOOL) applyStrategy;

@end

@interface YASLASMOptimizationStrategy (HelperMethods)
/*! Returns current assembly token pointer and restores assembly pointer to `baseState` position. */
- (NSUInteger) getCurentStateAndRestoreBaseState;
/*! Returns YES, if opcode at `opcodeIdx` is met in assembly earlier, than opcode at `otherOpcode`. */
- (BOOL) is:(NSUInteger)opcodeIdx earlierThan:(NSUInteger)otherOpcode;
/*! Returns index of opcode (from proposed list), that is most earlier met in assembly. */
- (NSUInteger) earliest:(NSArray *)states;

/*! Returns array of all known opcodes with specified operans access type. 
 @param type Type of opcodes to search for.
 @param strictMatch If NO - returns opcodes, that have any bit intersection with specified type, else - only exact matched opcodes.
 */
- (NSArray *) opcodesByAccessType:(YASLOperandAccessType)type strict:(BOOL)strictMatch;
/*! Returns array of operands, that impacts code-execution-flow, like JMP or CALL. */
- (YASLOpcode *) whoImpactsExecutionFlow;
/*! Returns array of operands, that read values of their first or second operand, like ADD or PUSH. */
- (YASLOpcode *) whoReads:(YASLOpcodeOperand *)operand;
/*! Returns array of operands, that write values to their first operand, like ADD or POP. */
- (YASLOpcode *) whoWrites:(YASLOpcodeOperand *)operand;
- (NSUInteger) reads:(NSArray *)operands;
- (NSUInteger) writes:(NSArray *)operands;
- (NSUInteger) impacts;

/*! Detects first operand in the rest of assembly, that contains in specified group and has first operand, that is equal to specified operand `operand`. */
- (YASLOpcode *) detectOpcodeInGroup:(NSArray *)group withFirstOperand:(YASLOpcodeOperand *)operand;
- (YASLOpcode *) detectOpcode:(YASLOpcodes)opCode;
- (YASLOpcode *) detectOpcodeWithFilter:(BOOL(^)(YASLOpcode *opcode))filter;
@end
