//
//  YASLDataType.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@class YASLDataTypesManager;
@interface YASLDataType : NSObject <NSCopying> {
@protected
	YASLDataTypesManager *_manager;
}

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL defined;
@property (nonatomic) YASLDataType *parent;
@property (nonatomic) NSArray *specifiers;
@property (nonatomic) NSUInteger isPointer;
@property (nonatomic) YASLDataTypesManager *manager;

+ (instancetype) typeWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;

- (NSUInteger) sizeOf;

- (BOOL) isSubclassOf:(YASLDataType *)parent;

/*! If specified type identifier is a built-in type identifier, returns correspondive type enum value. */
+ (YASLBuiltInType) typeIdentifierToBuiltInType:(NSString *)identifier;
/*! If specified type enum is a built-in type, returns correspondive type identifier. */
+ (NSString *) builtInTypeToTypeIdentifier:(YASLBuiltInType)type;

/*! If receiver is a built-in type, returns correspondive type enum value. */
- (YASLBuiltInType) builtInType;
/*! Returns base type of receiver. */
- (YASLBuiltInType) baseType;

@end
