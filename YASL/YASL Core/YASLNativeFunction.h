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
typedef YASLInt (*YASLNativeFunctionCallback)(id,SEL,YASLNativeFunction *, void *);

@interface YASLNativeFunction : NSObject

/*! Function name. Must be unique. */
@property (nonatomic) NSString *name;
/*! Function GUID. Used by assembler to generate function calls. Genereted by native functions holder wher function registered. */
@property (nonatomic) YASLInt GUID;
/*! Function parameters count. */
@property (nonatomic) NSUInteger params;
/*! Function return type. Nil, if void. */
@property (nonatomic) NSString *returns;

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
+ (instancetype) nativeWithName:(NSString *)name paramCount:(NSUInteger)params returnType:(NSString *)returns selector:(SEL)selector andReceiver:(id)receiver;

/*! Call callback implementation with specified parameters. */
- (YASLInt) callOnParamsBase:(void *)paramsBase;

/*!
 Resolve real address of param with specified index (1..n).
 */
- (void *) ptrToParam:(NSUInteger)paramNumber atBase:(void *)paramsBase;
- (YASLInt) intParam:(NSUInteger)paramNumber atBase:(void *)paramsBase;
- (YASLFloat) floatParam:(NSUInteger)paramNumber atBase:(void *)paramsBase;
- (NSString *) stringParam:(NSUInteger)paramNumber atBase:(void *)paramsBase;

@end
