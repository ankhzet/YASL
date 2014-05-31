//
//  YASLMemoryManager.h
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLMemoryManagerDelegate.h"

@class YASLRAM;
@interface YASLMemoryManager : NSObject <YASLMemorymanagerDelegate>
@property (nonatomic) YASLRAM *ram;

+ (instancetype) memoryManagerForRAM:(YASLRAM *)ram;

- (void) serveGC;

@end
