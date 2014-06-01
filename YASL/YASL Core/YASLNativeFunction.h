//
//  YASLNativeFunction.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"
#import "YASLMemoryManagerDelegate.h"

@class YASLNativeFunction, YASLRAM, YASLCPU, YASLStack, YASLMemoryManager;
typedef YASLInt (*YASLNativeFunctionCallback)(id,SEL,YASLNativeFunction *, void *, NSUInteger);

@interface YASLNativeFunction : NSObject

/*! Function name. Must be unique. */
@property (nonatomic) NSString *name;
/*! Function GUID. Used by assembler to generate function calls. Genereted by native functions holder wher function registered. */
@property (nonatomic) YASLInt GUID;
/*! Function return type. NO, if void. */
@property (nonatomic) BOOL isVoid;

/*! Associated selector, that will be called when CPU processes native call instruction. */
@property (nonatomic) SEL selector;
@property (nonatomic) YASLNativeFunctionCallback callback;
@property (nonatomic, weak) id receiver;

@property (nonatomic) YASLRAM *ram;
@property (nonatomic) YASLCPU *cpu;
@property (nonatomic) id<YASLMemorymanagerDelegate> mm;
@property (nonatomic) YASLStack	*stack;

/*!
 @brief Create native function description object with specified parameters.
 */
+ (instancetype) nativeWithName:(NSString *)name isVoid:(BOOL)isVoid selector:(SEL)selector andReceiver:(id)receiver;

/*! Call callback implementation with specified parameters. */
- (YASLInt) callOnParamsBase:(void *)paramsBase withParamCount:(NSUInteger)params;

/*!
 Resolve real address of param with specified index (1..n).
 */
- (void *) ptrToParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params;
- (YASLInt) intParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params;
- (YASLFloat) floatParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params;
- (NSString *) stringParam:(NSUInteger)paramNumber atBase:(void *)paramsBase withParamCount:(NSUInteger)params;

@end
