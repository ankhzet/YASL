//
//  YASLTranslationDeclarator.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"

@interface YASLDeclaratorSpecifier : NSObject
@property (nonatomic) YASLTranslationNodeType type;
@property (nonatomic) NSInteger param;
@property (nonatomic) NSArray *elements;
+ (instancetype) specifierWithType:(YASLTranslationNodeType)type param:(NSInteger)param andElems:(NSArray *)elems;
@end

@class YASLDataType, YASLTranslationExpression, YASLLocalDeclarations;
@interface YASLTranslationDeclarator : YASLTranslationNode

@property (nonatomic) NSString *declaratorIdentifier;
@property (nonatomic) YASLAssembly *declaratorSpecifiers;
@property (nonatomic) NSUInteger isPointer;

- (void) addSpecifier:(YASLDeclaratorSpecifier *)specifier;
- (YASLDataType *) declareSpecific:(YASLTranslationExpression *)variable withDataType:(YASLDataType *)declarationDataType inScope:(YASLLocalDeclarations *)scope andAssembly:(YASLAssembly *)a;

@end
