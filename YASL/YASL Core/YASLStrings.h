//
//  YASLStrings.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"
#import "YASLMemoryManagerDelegate.h"
#import "YASLNativeInterface.h"

@class YASLRAM;
@interface YASLStrings : YASLNativeInterface
@property (nonatomic) YASLRAM *ram;
@property (nonatomic) id<YASLMemorymanagerDelegate> memManager;

- (YASLInt) allocString:(NSString *)string;
- (NSString *) stringAt:(YASLInt)address;

@end
