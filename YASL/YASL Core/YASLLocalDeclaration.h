//
//  YASLLocalDeclaration.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLDeclarationScope, YASLDataType, YASLDeclarationInitializer, YASLTranslationDeclarator;
@interface YASLLocalDeclaration : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) YASLDataType *dataType;
@property (nonatomic) YASLDeclarationInitializer *declarationInitializer;
@property (nonatomic) NSUInteger declarationOffset;
@property (nonatomic) YASLTranslationDeclarator *declarator;

@property (nonatomic, weak) YASLDeclarationScope *parentScope;

+ (instancetype) localDeclarationWithIdentifier:(NSString *)identifier;

- (NSUInteger) sizeOf;

@end
