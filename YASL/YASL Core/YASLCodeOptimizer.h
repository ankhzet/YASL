//
//  YASLCodeOptimizer.h
//  YASL
//
//  Created by Ankh on 15.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLASMOptimizationStrategy.h"

@class YASLAssembly;
@interface YASLCodeOptimizer : NSObject <YASLOptimizationStrategyHelper>

- (void) optimize:(YASLAssembly *)a;

@end
