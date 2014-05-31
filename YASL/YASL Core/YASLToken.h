//
//  YASLToken.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

typedef NS_ENUM(NSUInteger, YASLTokenKind) {
	YASLTokenKindEOF = 0,
	YASLTokenKindIdentifier,
	YASLTokenKindString,
	YASLTokenKindChar,
	YASLTokenKindInteger,
	YASLTokenKindFloat,
	YASLTokenKindBool,
	YASLTokenKindSymbol,
	YASLTokenKindComment,

	YASLTokenKindMAX
};

@interface YASLToken : NSObject <NSCopying>

@property (nonatomic) NSString *value;
@property (nonatomic) YASLTokenKind kind;
@property (nonatomic) NSUInteger line;
@property (nonatomic) NSUInteger collumn;

+ (instancetype) token:(NSString *)value withKind:(YASLTokenKind)kind;
+ (NSString *) tokenKindName:(YASLTokenKind)kind;

- (NSString *) asString;
- (int) asInteger;
- (float) asFloat;
- (BOOL) asBool;

@end
