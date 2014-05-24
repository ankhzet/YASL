//
//  YASLNoNullsEnumerator.h
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLNoNullsEnumerator : NSEnumerator
+ (instancetype) enumeratorWithArray:(NSArray *)array reverse:(BOOL)reverse;
@end
