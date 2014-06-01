//
//  YASLAssembler.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCommonAssembler.h"

@class YASLLocalDeclarations, YASLDeclarationScope, YASLCompiler;
@interface YASLAssembler : YASLCommonAssembler

@property (nonatomic) YASLLocalDeclarations *declarationScope;
@property (nonatomic, weak) YASLCompiler *parentCompiler;

- (YASLDeclarationScope *) scope;

@end
