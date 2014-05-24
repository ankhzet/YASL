//
//  YASLCompiler.m
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCompiler.h"
#import "YASLCodeSource.h"
#import "YASLCompiledUnit.h"
#import "YASLBasicAssembler.h"
#import "YASLVM.h"
#import "YASLCodeOptimizer.h"

#define DEFAULT_CODEOFFSET 1000

NSString *const kCompilatorPrecompile = @"kCompilatorPrecompile";
NSString *const kCompilatorCompile = @"kCompilatorCompile";
NSString *const kCompilatorDropCaches = @"kCompilatorDropCaches";
NSString *const kCompilatorPlacementOffset = @"kCompilatorPlacementOffset";

NSString *const kCompilatorOptimize = @"kCompilatorOptimize";

NSString *const kCacheStaticLabels = @"kCacheStaticLabels";
NSString *const kCachePrecompiledMachineCode = @"kCachePrecompiledMachineCode";

@implementation YASLCompiler {
	NSMutableDictionary *caches;
	NSMutableDictionary *units;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	_globalDatatypesManager = [YASLDataTypesManager datatypesManagerWithParentManager:nil];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeVoidInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeIntInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeFloatInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeBoolInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeCharInstance new]];

	caches = [NSMutableDictionary dictionary];
	units = [NSMutableDictionary dictionary];
	return self;
}

- (NSEnumerator *) enumerateCompiledUnits {
	return [units objectEnumerator];
}

- (YASLCompiledUnit *) newUnit:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = units[source.identifier] = [YASLCompiledUnit new];
	unit.source = source;
	unit.declarations = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:self.globalDatatypesManager];
	caches[source.identifier] = [NSMutableDictionary dictionary];
	return unit;
}

- (YASLCompiledUnit *) compilationPass:(YASLCodeSource *)source withOptions:(NSDictionary *)options {
	YASLCompiledUnit *unit = units[source.identifier];
	if (!unit)
		unit = [self newUnit:source];
	else {
		if (options[kCompilatorDropCaches]) {
			[self dropAssociatedCaches:source.identifier];
			caches[source.identifier] = [NSMutableDictionary dictionary];
			unit.declarations = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:self.globalDatatypesManager];
		}
	}
	NSMutableDictionary *cache = caches[source.identifier];

	YASLDeclarationScope *globalScope = unit.declarations.currentScope;

	Class opcodeClass = [YASLOpcode class];

	@try {

		if (options[kCompilatorPrecompile]) {
			YASLAssembler *assembler = [YASLAssembler new];
			assembler.declarationScope = unit.declarations;

			YASLTranslationUnit *translated = [assembler assembleSource:source.code];
			if (!translated)
				return unit;

			unit.codeAssembly = [YASLAssembly new];
			[translated assemble:unit.codeAssembly];
			[unit.codeAssembly push:OPC_(HALT)];
			unit.codeAssembly = [[YASLAssembly alloc] initReverseAssembly:unit.codeAssembly];
			[unit.codeAssembly push:OPC_(HALT)];
			[globalScope.placementManager calcPlacementForScope:globalScope];

			if (options[kCompilatorOptimize]) {
				YASLCodeOptimizer *optimizer = [YASLCodeOptimizer new];
				[optimizer optimize:unit.codeAssembly];
			}

			NSUInteger frameSize = DEFAULT_CODEFRAME;
			void *frame = malloc(frameSize), *codePtr = frame;
			NSMutableArray *labels = [@[] mutableCopy];
			Class refClass = [YASLCodeAddressReference class];
			while ([unit.codeAssembly notEmpty]) {
				id top = [unit.codeAssembly pop];
				if ([top isKindOfClass:opcodeClass]) {
					codePtr = [((YASLOpcode *)top) toCodeInstruction:codePtr];
				} else if ([top isKindOfClass:refClass]) {
					YASLCodeAddressReference *ref = top;
					[labels addObject:@[ref, @(codePtr - frame)]];
				}

				NSUInteger codeSize = codePtr - frame;
				if (codeSize > (frameSize * 0.9)) {
					frameSize *= 1.5;
					frame = realloc(frame, frameSize);
					codePtr = (char *)frame + codeSize;
				}
			}

			unit.codeLength = codePtr - frame + [globalScope scopeDataSize];
			frame = realloc(frame, unit.codeLength);
			cache[kCacheStaticLabels] = labels;

			if (cache[kCachePrecompiledMachineCode]) {
				NSValue *cachePtr = cache[kCachePrecompiledMachineCode];
				if (cachePtr)
					free([cachePtr pointerValue]);
			}
			cache[kCachePrecompiledMachineCode] = [NSValue valueWithPointer:frame];
			unit.stage = YASLUnitCompilationStagePrecompiled;
		}

		if (options[kCompilatorCompile]) {
			NSNumber *placementOffset = (NSNumber *)options[kCompilatorPlacementOffset];
			NSUInteger codeBase = placementOffset ? [placementOffset unsignedIntegerValue] : DEFAULT_CODEOFFSET;

			[globalScope.placementManager offset:(codeBase + unit.codeLength) scope:globalScope];
			[globalScope propagateReferences];

			NSSet *labels = caches[source.identifier][kCacheStaticLabels];
			for (NSArray *ref in labels) {
				((YASLCodeAddressReference *)ref[0]).address = codeBase + [ref[1] intValue];
			}

			[unit.codeAssembly restoreFullStack];

			void *frame = [self.targetRAM dataAt:codeBase], *codePtr = frame;
			memset(frame, 0, unit.codeLength);
			while ([unit.codeAssembly notEmpty]) {
				id top = [unit.codeAssembly pop];
				if ([top isKindOfClass:opcodeClass]) {
					codePtr = [((YASLOpcode *)top) toCodeInstruction:codePtr];
				}
			}
			
			unit.stage = YASLUnitCompilationStageCompiled;
			unit.startOffset = codeBase;
		}
	}
	@catch (NSException *exception) {
    NSLog(@"Compilation exception: %@\nStack trace:\n%@", [exception description], [[exception callStackSymbols] componentsJoinedByString:@"\n"]);
	}

	return unit;
}

- (BOOL) dropAssociatedCaches:(NSString *)sourceIdentifier {
	id cache = caches[sourceIdentifier];
	if (!cache)
		return NO;

	[caches removeObjectForKey:sourceIdentifier];
	return YES;
}

- (id) cache:(NSString *)sourceIdentifier data:(NSString *)cacheIdentifier {
	NSMutableDictionary *cache = caches[sourceIdentifier];
	if (!cache)
		return nil;

	return cache[cacheIdentifier];
}

@end
