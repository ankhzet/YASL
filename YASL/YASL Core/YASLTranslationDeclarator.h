//
//  YASLTranslationDeclarator.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"

@class YASLAssignmentExpression;
@interface YASLTranslationDeclarator : YASLTranslationNode

@property (nonatomic) NSString *declaratorIdentifier;
@property (nonatomic) NSArray *declaratorSpecifiers;
@property (nonatomic) NSUInteger isPointer;

@end
