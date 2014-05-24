//
//  YASLAssembler.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCommonAssembler.h"

@class YASLTranslationUnit, YASLLocalDeclarations, YASLDeclarationScope;
@interface YASLAssembler : YASLCommonAssembler

@property (nonatomic) YASLLocalDeclarations *declarationScope;

- (YASLTranslationUnit *) assembleSource:(NSString *)source;

- (YASLDeclarationScope *) scope;

@end
