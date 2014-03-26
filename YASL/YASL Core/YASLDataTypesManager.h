//
//  YASLDataTypes.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLDataType;
@protocol YASLDataTypesManagerProtocol <NSObject>

/*! Registers new type in manager. */
- (void) registerType:(YASLDataType *)type;
/*! Returns type with specified name if found, nil otherwise. Searches in parent manager, if not found localy. */
- (YASLDataType *) typeByName:(NSString *)name;

- (NSEnumerator *) enumTypes;

@end

@interface YASLDataTypesManager : NSObject <YASLDataTypesManagerProtocol>

@property (nonatomic, weak) YASLDataTypesManager *parentManager;

+ (instancetype) datatypesManagerWithParentManager:(YASLDataTypesManager *)parent;

@end
