//
//  YASLDataTypesManagerProtocol.h
//  YASLVM
//
//  Created by Ankh on 01.06.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

@class YASLDataType;
@protocol YASLDataTypesManagerProtocol <NSObject>

/*! Registers new type in manager. */
- (void) registerType:(YASLDataType *)type;
/*! Returns type with specified name if found, nil otherwise. Searches in parent manager, if not found localy. */
- (YASLDataType *) typeByName:(NSString *)name;

- (NSEnumerator *) enumTypes;

- (id<YASLDataTypesManagerProtocol>) parentManager;

@end

