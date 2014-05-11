//
//  YASLTranslationUnit.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"

@interface YASLTranslationUnit : YASLTranslationNode

@property (nonatomic) NSString *name;

+ (instancetype) unitInScope:(YASLDeclarationScope *)scope withName:(NSString *)name;

@end
