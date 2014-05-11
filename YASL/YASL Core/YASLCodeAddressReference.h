//
//  YASLCodeAddressReference.h
//  YASL
//
//  Created by Ankh on 11.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLOpcode.h"

@interface YASLCodeAddressReference : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *references;
@property (nonatomic) YASLInt base;
@property (nonatomic) YASLInt address;

- (void) addReferent:(YASLOpcodeOperand *)operand;
- (void) addressResolved:(YASLInt)referencedAddress;
- (void) updateReferents;

@end
