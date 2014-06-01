//
//  YASLEnumDataType.h
//  YASL
//
//  Created by Ankh on 25.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataType.h"

@interface YASLEnumDataType : YASLDataType

- (void) addEnum:(NSString *)identifier value:(NSUInteger)value;
- (void) addEnum:(NSString *)identifier;

+ (YASLEnumDataType *) hasEnum:(NSString *)identifier inManager:(id<YASLDataTypesManagerProtocol>)manager;
- (BOOL) hasEnum:(NSString *)identifier;
- (NSString *) hasValue:(NSUInteger)value;
- (NSUInteger) enumValue:(NSString *)identifier;

@end
