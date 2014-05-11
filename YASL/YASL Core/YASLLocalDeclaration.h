//
//  YASLLocalDeclaration.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

@class YASLDeclarationScope, YASLDataType, YASLCodeAddressReference, YASLTranslationDeclarator;
@interface YASLLocalDeclaration : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSUInteger index;
@property (nonatomic) YASLDataType *dataType;
@property (nonatomic) YASLTranslationDeclarator *declarator;
@property (nonatomic) YASLCodeAddressReference *reference;

@property (nonatomic, weak) YASLDeclarationScope *parentScope;

+ (instancetype) localDeclarationWithIdentifier:(NSString *)identifier;

- (NSUInteger) sizeOf;

@end
