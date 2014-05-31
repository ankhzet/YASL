//
//  YASLStructDataType.h
//  YASLVM
//
//  Created by Ankh on 31.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataType.h"

@interface YASLStructDataType : YASLDataType

- (BOOL) addProperty:(NSString *)identifier withType:(YASLDataType *)type;
- (BOOL) hasProperty:(NSString *)identifier;
- (NSUInteger) propertyOffset:(NSString *)identifier;
- (YASLDataType *) propertyType:(NSString *)identifier;

@end
