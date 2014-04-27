//
//  YASLInstruction.h
//  YASL
//
//	YASLInstruction class used to convert code instructions to string representation.
//
//  Created by Ankh on 27.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

@interface YASLInstruction : NSObject {
	YASLCodeInstruction *instruction;
	void *immediates;
}

// instantiation
+ (instancetype) instruction:(YASLCodeInstruction *)i;
- (id)initWithInstruction:(YASLCodeInstruction *)i;

// setter/getter
- (void) setInstruction:(YASLCodeInstruction *)i;
- (YASLCodeInstruction *) instruction;
- (void) setImmediatePtr:(void *)ptr;

@end
