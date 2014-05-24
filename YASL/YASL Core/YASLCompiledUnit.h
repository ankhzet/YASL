//
//  YASLCompiledUnit.h
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

typedef NS_ENUM(NSUInteger, YASLUnitCompilationStage) {
	YASLUnitCompilationStageNone        = 0,
	YASLUnitCompilationStagePrecompiled = 1 << 0,
	YASLUnitCompilationStageCompiled    = 1 << 1,
};

@class YASLCodeSource, YASLLocalDeclarations, YASLLocalDeclaration, YASLAssembly, YASLThread;
@interface YASLCompiledUnit : NSObject

@property (nonatomic) YASLCodeSource *source;
@property (nonatomic) YASLInt startOffset;
@property (nonatomic) YASLInt codeLength;
@property (nonatomic) YASLLocalDeclarations *declarations;
@property (nonatomic) YASLUnitCompilationStage stage;
@property (nonatomic) YASLAssembly *codeAssembly;

- (YASLLocalDeclaration *) findSymbol:(NSString *)identifier;

@end

@interface YASLCompiledUnit (ThreadOwnage)

- (void) usedByThread:(YASLThread *)thread;
- (void) notUsedByThread:(YASLThread *)thread;
- (BOOL) isUsedByThread:(YASLThread *)thread;
- (BOOL) usedByThreads;
- (NSEnumerator *) enumerateOwners;

@end
