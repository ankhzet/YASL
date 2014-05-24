//
//  YASLTranslationFunction.h
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationDeclarator.h"

@class YASLLocalDeclaration, YASLNativeFunction;
@interface YASLTranslationFunction : YASLTranslationDeclarator

@property (nonatomic, readonly, weak) YASLLocalDeclaration *declaration;
@property (nonatomic) YASLNativeFunction *native;

+ (instancetype) functionInScope:(YASLDeclarationScope *)scope withDeclaration:(YASLLocalDeclaration *)declaration;

- (NSString *) returnVarIdentifier;
- (NSString *) exitLabelIdentifier;

@end
