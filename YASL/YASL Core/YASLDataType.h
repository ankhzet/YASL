//
//  YASLDataType.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const YASLBuiltInTypeVoid;
extern NSString *const YASLBuiltInTypeInt;
extern NSString *const YASLBuiltInTypeFloat;
extern NSString *const YASLBuiltInTypeBool;
extern NSString *const YASLBuiltInTypeChar;

@interface YASLDataType : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL defined;
@property (nonatomic) YASLDataType *parent;
@property (nonatomic) NSArray *specifiers;
@property (nonatomic) NSUInteger isPointer;

+ (instancetype) typeWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;

- (NSUInteger) sizeOf;

@end
