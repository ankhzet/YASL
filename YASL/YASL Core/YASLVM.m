//
//  YASLVM.m
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLVM.h"
#import "YASLCompiledUnit.h"
#import "YASLCoreLangClasses.h"

#import "YASLDisassembler.h"

@implementation YASLVM

- (YASLCompiledUnit *)runScript:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = [self scriptInStage:YASLUnitCompilationStagePrecompiled|YASLUnitCompilationStageCompiled bySource:source];

	if (!unit) {
		unit = [self.compiler compilationPass:source
															withOptions:@{
																						kCompilatorPrecompile:@YES,
																						kCompilatorOptimize: @YES,
																						kCompilatorDropCaches: @YES,
																						}];

		if (unit.stage == YASLUnitCompilationStagePrecompiled) {
			YASLInt threadOffset = [self calcCodePlacement:unit.codeLength];
			[self.compiler compilationPass:source
												 withOptions:@{
																			 kCompilatorCompile:@YES,
																			 kCompilatorPlacementOffset:@(threadOffset),
																			 }];
		}

	}

	if (unit.stage == YASLUnitCompilationStageCompiled) {
		YASLThread *thread = [self.cpu threadCreateWithEntryAt:unit.startOffset andState:YASLThreadStateRunning andInitParam:0 waitable:NO];
		[unit usedByThread:thread];

#ifdef VERBOSE_COMPILATION
		NSLog(@"Disassembling \"%@\":\n%@", source.identifier, [[self disassembly:source] componentsJoinedByString:@"\n"]);
#endif
	}
	return unit;
}

- (YASLInt) calcCodePlacement:(YASLInt)codeLength {
	return [self.memManager allocMem:codeLength];
}

- (YASLCompiledUnit *) scriptInStage:(YASLUnitCompilationStage)stage bySource:(YASLCodeSource *)source {
	NSEnumerator *compiled = [self.compiler enumerateCompiledUnits];
	for (YASLCompiledUnit *compiledUnit in compiled) {
    if (!(compiledUnit.stage & stage))
			continue;

		if (compiledUnit.source.identifier == source.identifier)
			return compiledUnit;
	}

	return nil;
}

- (NSArray *) disassembly:(YASLCodeSource *)source {
	YASLCompiledUnit *unit = [self scriptInStage:YASLUnitCompilationStagePrecompiled|YASLUnitCompilationStageCompiled bySource:source];
	YASLDisassembler *disassembler = [YASLDisassembler disassemblerForCPU:self.cpu];
	[disassembler setLabelsRefs:[self.compiler cache:source.identifier data:kCacheStaticLabels]];
	[disassembler setCodeSource:source];
	return [disassembler disassembleFrom:unit.startOffset to:unit.startOffset + unit.codeLength];
}

- (void) registerNativeFunctions {
	[self registerNativeFunction:YASLNativeVM_log withParamCount:2 returnType:YASLBuiltInTypeIdentifierVoid withSelector:@selector(n_log:params:)];

	[self registerNativeFunction:YASLNativeVM_unloadScriptAssociatedWith withParamCount:1 returnType:YASLBuiltInTypeIdentifierInt withSelector:@selector(n_unloadScriptAssociatedWith:params:)];
}

- (YASLInt) n_unloadScriptAssociatedWith:(YASLNativeFunction *)native params:(void *)paramsBase {
	YASLInt threadHandle = [native intParam:1 atBase:paramsBase];
	if (!threadHandle)
		return YASL_INVALID_HANDLE;

	YASLThread *thread = [self.cpu thread:threadHandle];
	if (!thread)
		return YASL_INVALID_HANDLE;

	for (YASLCompiledUnit *unit in [self.compiler enumerateCompiledUnits]) {
		if ([unit isUsedByThread:thread]) {
			[unit notUsedByThread:thread];
			BOOL used = [unit usedByThreads];
			if (!used) {
				NSArray *childThreads = [self.cpu hasChilds:thread->parentCodeframe];
				if ([childThreads count]) {
					for (YASLThread *thread in childThreads) {
						[unit usedByThread:thread];
					}
				} else {
					[self.memManager deallocMem:unit.startOffset];
					[self.compiler dropUnit:unit.source.identifier];
				}
			}
			return used;
		}
	}
	return YASL_INVALID_HANDLE;
}

//TODO: freese this hell T_T
typedef char *(^StrResolve)(int strAddres);
YASLChar *_format(char *source, NSUInteger *length, YASLInt *params, StrResolve resolver);

- (YASLInt) n_log:(YASLNativeFunction *)native params:(void *)paramsBase {
	NSString *string = [native stringParam:1 atBase:paramsBase];
	YASLInt params = [native intParam:2 atBase:paramsBase];
	if (!params)
		return [native intParam:1 atBase:paramsBase];

	YASLInt *paramList = [_ram dataAt:params];
	const char *formatBuf = [string cStringUsingEncoding:NSASCIIStringEncoding];
	NSUInteger length = [string length];

	char *nullStr = malloc(7 * sizeof(char));
	[@"(null)" getCString:nullStr maxLength:7 encoding:NSASCIIStringEncoding];

	YASLChar *formatted = _format(formatBuf, &length, paramList, ^char *(int strAddres) {
		if (strAddres) {
			YASLInt size = [_memManager isAllocated:strAddres];
			if (size) {
				YASLChar *raw = [_ram dataAt:strAddres];
				NSUInteger len = size / sizeof(YASLChar) - 1;

				return [[NSString stringWithCharacters:raw length:len] cStringUsingEncoding:NSASCIIStringEncoding];
			}
		}

		return nullStr;
	});
	free(nullStr);

	NSLog(@"LOG: %@", [NSString stringWithCharacters:formatted length:length]);
	return 0;
}

@end

char *_baseInt(int i, int base, int padding);
YASLChar *_format(char *source, NSUInteger *length, YASLInt *params, StrResolve resolver) {
	const size_t chrSize = sizeof(YASLChar);
	char *ptr = source;
	__block NSUInteger len = *length * chrSize;
	__block YASLChar *result = malloc(len), *d = result, *e = result + len;

	void(^_realloc)() = ^() {
		long int offset = d - result;
		long int done = ptr - source;

		len += (*length - done) * chrSize;
		result = realloc(result, len);
		d = result + offset;
		e = result + len;
	};

	char c;
	while ((c = *ptr)) {
		ptr++;
		switch (c) {
			case '%': {
				char *converted;
				switch ((c = *ptr)) {
					case 's':
						converted = resolver(*params);
						break;
					case 'i': {
						converted = _baseInt(*params, 10, 0);
						break;
					}
					case 'b': {
						char *labels[] = {"false", "true"};
						converted = labels[!!*params];
						break;
					}
					case 0:
					default:
						*d = '%';
						continue;
				}
				while ((*d = *converted)) {
					d++;
					converted++;
					if (d >= e)
						_realloc();
				}
				params++;
				ptr++;
				continue;
			}

			default:
				*d = c;
		}
		d++;
	}

	*length = d - result;
	return realloc(result, *length);
}

#define MIN_BASE 2
#define MAX_BASE 36
#define MAX_NUM_LEN 100
char *_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
char *_baseInt(int i, int base, int padding) {
	base = MIN(MAX_BASE, MAX(MIN_BASE, base));
	int maxLen = sizeof(char) * MAX(MAX_NUM_LEN, padding);
	char *result = malloc(maxLen), *p = result + maxLen - 1;
	*p = 0;
	p--;
	char *start = p;

	bool baseTen = base == 10;
	bool sign = false;
	if (baseTen) {
		sign = i < 0;
		if (sign)
			i = -i;
	}
	while (i > 0) {
		int rest = i % base;
		i /= base;
		*p = *(_alphabet + rest);
		p--;
	}
	int len = (int)(start - p);
	if (!baseTen) {
		int delta = padding - len;
		if (delta > 0) {
			len += delta;
			while (delta-- > 0) {
				*p = '0';
				p--;
			}
		}
	} else {
		if (sign) {
			*p = '-';
			p--;
		}
	}
	p++;
	start = malloc(len + sizeof(char));
	memmove(start, p, len + sizeof(char));
	free(result);
	return start;
}

@implementation YASLAbstractVMBuilder

- (YASLVM *) newVM {
	return [YASLVM new];
}

- (BOOL) attachRAM:(YASLVM *)vm {
	return !!vm.ram;
}

- (BOOL) attachStack:(YASLVM *)vm {
	return !!vm.stack;
}

- (BOOL) attachCPU:(YASLVM *)vm {
	return !!vm.cpu;
}

- (BOOL) attachMemoryManager:(YASLVM *)vm {
	return !!vm.memManager;
}

- (BOOL) attachStringManager:(YASLVM *)vm {
	return !!vm.stringManager;
}

- (BOOL) attachCompiler:(YASLVM *)vm {
	return !!vm.compiler;
}

- (YASLVM *)buildVM {
	YASLVM *vm = [self newVM];

	if (![self attachRAM:vm])
		return nil;

	if (![self attachMemoryManager:vm])
		return nil;

	if (![self attachStringManager:vm])
		return nil;

	if (![self attachStack:vm])
		return nil;

	if (![self attachCPU:vm])
		return nil;

	if (![self attachCompiler:vm])
		return nil;

	return vm;
}

@end