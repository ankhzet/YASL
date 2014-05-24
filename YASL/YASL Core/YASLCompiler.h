//
//  YASLCompiler.h
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

extern NSString *const kCompilatorPrecompile;
extern NSString *const kCompilatorCompile;
extern NSString *const kCompilatorDropCaches;
extern NSString *const kCompilatorPlacementOffset;

extern NSString *const kCacheStaticLabels;
extern NSString *const kCachePrecompiledMachineCode;

@class YASLRAM, YASLLocalDeclarations, YASLDataTypesManager, YASLCompiledUnit, YASLCodeSource;
@interface YASLCompiler : NSObject

@property (nonatomic) YASLRAM *targetRAM;
@property (nonatomic) YASLLocalDeclarations *declarations;
@property (nonatomic) YASLDataTypesManager *globalDatatypesManager;

- (YASLCompiledUnit *) compilationPass:(YASLCodeSource *)source withOptions:(NSDictionary *)options;

- (BOOL) dropAssociatedCaches:(NSString *)sourceIdentifier;
- (id) cache:(NSString *)sourceIdentifier data:(NSString *)cacheIdentifier;

- (NSEnumerator *) enumerateCompiledUnits;

@end
