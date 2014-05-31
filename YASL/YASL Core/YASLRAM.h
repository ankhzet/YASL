//
//  YASLRAM.h
//  YASL
//
//  Created by Ankh on 25.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

#define MEMORY_DEFAULT_SIZE (sizeof(YASLInt) * 1024)
#define MEMORY_FIXED_UNIT sizeof(YASLInt)

@interface YASLRAM : NSObject

@property (nonatomic)  YASLInt size;

+ (instancetype) ramWithSize:(YASLInt)size;

- (void *) dataAt:(YASLInt)offset;
- (void) setInt:(YASLInt)value at:(YASLInt)offset;
- (YASLInt) intAt:(YASLInt)offset;

@end
