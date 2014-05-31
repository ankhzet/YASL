//
//  YASLMemoryManagerDelegate.h
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASLVM_YASLMemoryManagerDelegate_h
#define YASLVM_YASLMemoryManagerDelegate_h

#import "YASLAPI.h"

@protocol YASLMemorymanagerDelegate <NSObject>

- (YASLInt) allocMem:(YASLInt)size;
- (YASLInt) deallocMem:(YASLInt)mem;
- (YASLInt) isAllocated:(YASLInt)mem;

@end



#endif
