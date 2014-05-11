//
//  YASLConstantExpression.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationExpression.h"
#import "YASLAPI.h"

@class YASLDataType;
@interface YASLTranslationConstant : YASLTranslationExpression

@property (nonatomic) NSNumber *value;

+ (instancetype) constantInScope:(YASLDeclarationScope *)scope withType:(YASLDataType *)type andValue:(NSNumber *)value;

- (YASLInt) toInteger;
- (YASLFloat) toFloat;
- (YASLBool) toBool;
- (YASLChar) toChar;

@end
