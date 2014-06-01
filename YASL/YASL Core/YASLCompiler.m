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

NSString *const kCompilatorPrecompile = @"kCompilatorPrecompile";
NSString *const kCompilatorCompile = @"kCompilatorCompile";
NSString *const kCompilatorDropCaches = @"kCompilatorDropCaches";
NSString *const kCompilatorPlacementOffset = @"kCompilatorPlacementOffset";

NSString *const kCompilatorOptimize = @"kCompilatorOptimize";

NSString *const kCacheStaticLabels = @"kCacheStaticLabels";

@implementation YASLCompiler {
	NSMutableDictionary *caches;
	NSMutableDictionary *units;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	caches = [NSMutableDictionary dictionary];
	units = [NSMutableDictionary dictionary];
	[self setupTypesManager];
	return self;
}

- (NSEnumerator *) enumerateCompiledUnits {
	return [units objectEnumerator];
}

- (void) setupTypesManager {
	_globalDatatypesManager = [YASLDataTypesManager datatypesManagerWithParentManager:nil];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeVoidInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeIntInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeFloatInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeBoolInstance new]];
	[_globalDatatypesManager registerType:[YASLBuiltInTypeCharInstance new]];

	YASLDataType *handleType = [YASLBuiltInTypeIntInstance new];
	handleType.name = YASLAPITypeHandle;
	handleType.parent = [_globalDatatypesManager typeByName:YASLBuiltInTypeIdentifierInt];
	[_globalDatatypesManager registerType:handleType];

	YASLDataType *pcharType = [YASLBuiltInTypeCharInstance new];
	pcharType.name = YASLBuiltInTypeIdentifierString;
	pcharType.parent = [_globalDatatypesManager typeByName:YASLBuiltInTypeIdentifierChar];
	pcharType.isPointer = 1;
	[_globalDatatypesManager registerType:pcharType];

}

- (YASLCompiledUnit *) newUnit:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = units[source.identifier] = [YASLCompiledUnit new];
	unit.source = source;
	[self reinitUnit:unit];
	return unit;
}

- (void) reinitUnit:(YASLCompiledUnit *)unit {
	unit.declarations = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:self.globalDatatypesManager];
	unit.declarations.stringsManager = self.stringsManager;
	caches[unit.source.identifier] = [NSMutableDictionary dictionary];
}

- (YASLCompiledUnit *) compilationPass:(YASLCodeSource *)source withOptions:(NSDictionary *)options {
	YASLCompiledUnit *unit = units[source.identifier];
	if (!unit)
		unit = [self newUnit:source];
	else {
		if (options[kCompilatorDropCaches]) {
			[self dropAssociatedCaches:source.identifier];
			[self reinitUnit:unit];
		} else
			if (options[kCompilatorPrecompile])
				@throw [YASLNonfatalException exceptionAtLine:0 andCollumn:0 withMsg:@"Trying to precompile already compiled unit (\"%@\") without clearing cache",source.identifier];
	}
	NSMutableDictionary *cache = caches[source.identifier];

	YASLDeclarationScope *globalScope = unit.declarations.currentScope;

	Class opcodeClass = [YASLOpcode class];

	@try {
		if (options[kCompilatorPrecompile]) {
			YASLTranslationUnit *translated;
			@autoreleasepool {
				YASLAssembler *assembler = [YASLAssembler new];
				assembler.parentCompiler = self;
				assembler.declarationScope = unit.declarations;

				translated = [assembler assembleSource:source];
				if (!translated)
					return unit;
			}

			unit.codeAssembly = [YASLAssembly new];
			[translated assemble:unit.codeAssembly];

			YASLCodeAddressReference *entryRef = [YASLCodeAddressReference referenceWithName:[unit.source.identifier lastPathComponent]];
			YASLLocalDeclaration *mainMethod = [unit findSymbol:@"main"];
			if (!mainMethod)
				NSLog(@"Failed to link \"main\" symbol");

			[unit.codeAssembly push:entryRef];
			[unit.codeAssembly push:OPC_(HALT)];

			unit.codeAssembly = [[YASLAssembly alloc] initReverseAssembly:unit.codeAssembly];
			[unit.codeAssembly push:OPC_(NOP)];
			if (mainMethod) {
				[unit.codeAssembly push:OPC_(JMP, [mainMethod.reference addNewOpcodeOperandReferent])];
				[unit.codeAssembly push:OPC_(PUSH, [entryRef addNewOpcodeOperandReferent])];
			} else {
				[unit.codeAssembly push:OPC_(JMP, [entryRef addNewOpcodeOperandReferent])];
			}

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
			free(frame);
			cache[kCacheStaticLabels] = labels;

			unit.stage = YASLUnitCompilationStagePrecompiled;
		}

		if (options[kCompilatorCompile]) {
			NSNumber *placementOffset = (NSNumber *)options[kCompilatorPlacementOffset];
			YASLInt codeBase = placementOffset ? (YASLInt)[placementOffset unsignedIntegerValue] : DEFAULT_CODEOFFSET;

			NSUInteger localsOffset = codeBase + unit.codeLength - [globalScope scopeDataSize];
			[globalScope.placementManager offset:localsOffset scope:globalScope];
			[globalScope propagateReferences];

			NSMutableArray *labels = caches[source.identifier][kCacheStaticLabels];
			for (NSArray *ref in labels) {
				((YASLCodeAddressReference *)ref[0]).address = codeBase + [ref[1] intValue];
			}
			for (YASLLocalDeclaration *local in [globalScope.declarations allValues]) {
				[labels addObject:@[local.reference, @(localsOffset)]];
			}

			[unit.codeAssembly restoreFullStack];

			void *frame = [self.targetRAM dataAt:codeBase], *codePtr = frame;
//			NSLog(@"compile to %p, %d, %lu", self.targetRAM, codeBase, (unsigned long)frame);
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
    NSLog(@"Compilation exception: %@\nStack trace:\n%@", [exception description], [exception callStackSymbols]);
	}

	return unit;
}

- (YASLCompiledUnit *) compileScript:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = [self scriptInStage:YASLUnitCompilationStagePrecompiled|YASLUnitCompilationStageCompiled bySource:source strictMatch:NO];

	if (!unit) {
		unit = [self compilationPass:source
															withOptions:@{
																						kCompilatorPrecompile:@YES,
																						kCompilatorOptimize: @YES,
																						kCompilatorDropCaches: @YES,
																						}];

		if (unit.stage == YASLUnitCompilationStagePrecompiled) {
			YASLInt codeOffset = [self calcCodePlacement:unit.codeLength];
			[self compilationPass:source
												 withOptions:@{
																			 kCompilatorCompile:@YES,
																			 kCompilatorPlacementOffset:@(codeOffset),
																			 }];
		}

	}
	
	return unit;
}

- (YASLInt) calcCodePlacement:(YASLInt)codeLength {
	return [self.memoryManager allocMem:codeLength];
}

- (NSRange) codeRange {
	NSRange r = NSMakeRange(0, 0);
	for (YASLCompiledUnit *compiledUnit in [self enumerateCompiledUnits]) {
		if (compiledUnit.stage == YASLUnitCompilationStageCompiled)
			r = NSUnionRange(r, NSMakeRange(compiledUnit.startOffset, compiledUnit.codeLength));
	}
	return r;
}

- (YASLCompiledUnit *) scriptInStage:(YASLUnitCompilationStage)stage bySource:(YASLCodeSource *)source strictMatch:(BOOL)strictMatch {
	NSEnumerator *compiled = [self enumerateCompiledUnits];
	for (YASLCompiledUnit *compiledUnit in compiled) {
		YASLUnitCompilationStage masked = compiledUnit.stage & stage;
    if (!(strictMatch ? masked == stage : !!masked))
			continue;

		if (compiledUnit.source.identifier == source.identifier)
			return compiledUnit;
	}

	return nil;
}

- (void) dropUnit:(NSString *)sourceIdentifier {
	[units removeObjectForKey:sourceIdentifier];
	[self dropAssociatedCaches:sourceIdentifier];
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
