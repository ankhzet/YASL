//
//  YASLStrings.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@class YASLRAM;
@interface YASLStrings : NSObject

- (YASLInt) putStr:(NSString *)string onRam:(YASLRAM *)ram atOffset:(YASLInt)offset;

@end
