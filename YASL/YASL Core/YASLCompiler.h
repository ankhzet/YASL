//
//  YASLCompiler.h
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCompiledUnit.h"

extern NSString *const kCompilatorPrecompile;
extern NSString *const kCompilatorCompile;
extern NSString *const kCompilatorDropCaches;
extern NSString *const kCompilatorPlacementOffset;

extern NSString *const kCompilatorOptimize;

extern NSString *const kCacheStaticLabels;

@class YASLRAM, YASLLocalDeclarations, YASLDataTypesManager;
@class YASLStrings, YASLCompiledUnit, YASLCodeSource;
@class YASLMemoryManager;
@interface YASLCompiler : NSObject

@property (nonatomic) YASLRAM *targetRAM;
@property (nonatomic) YASLStrings *stringsManager;
@property (nonatomic) YASLMemoryManager *memoryManager;

@property (nonatomic) YASLDataTypesManager *globalDatatypesManager;

- (YASLCompiledUnit *) compileScript:(YASLCodeSource *)source;
- (YASLCompiledUnit *) scriptInStage:(YASLUnitCompilationStage)stage bySource:(YASLCodeSource *)source strictMatch:(BOOL)strictMatch;
- (YASLCompiledUnit *) compilationPass:(YASLCodeSource *)source withOptions:(NSDictionary *)options;

- (NSRange) codeRange;

- (BOOL) dropAssociatedCaches:(NSString *)sourceIdentifier;
- (id) cache:(NSString *)sourceIdentifier data:(NSString *)cacheIdentifier;

- (NSEnumerator *) enumerateCompiledUnits;
- (void) dropUnit:(NSString *)sourceIdentifier;

@end
