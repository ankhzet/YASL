//
//  YASLToken.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLToken.h"

NSString *const YASLTokenKindNames[YASLTokenKindMAX] = {
	[YASLTokenKindEOF]        = @"EOF",
	[YASLTokenKindIdentifier] = @"Identifier",
	[YASLTokenKindString]     = @"String",
	[YASLTokenKindInteger]    = @"Integer",
	[YASLTokenKindFloat]      = @"Float",
	[YASLTokenKindBool]       = @"Bool",
	[YASLTokenKindSymbol]     = @"Symbol",
	[YASLTokenKindComment]    = @"Comment",
};

@implementation YASLToken

+ (instancetype) token:(NSString *)value withKind:(YASLTokenKind)kind {
	return [(YASLToken *)[self alloc] initToken:value withKind:kind];
}

- (id)initToken:(NSString *)value withKind:(YASLTokenKind)kind {
	if (!(self = [super init]))
		return self;

	_value = value;
	_kind = kind;
	return self;
}

+ (NSString *) tokenKindName:(YASLTokenKind)kind {
	return YASLTokenKindNames[kind];
}

- (NSString *) asString {
	return _value;
}

- (int) asInteger {
	switch (_kind) {
		case YASLTokenKindBool:
			return [self asBool] ? 1 : 0;
			break;
		case YASLTokenKindFloat:
			return [self asFloat];
			break;
		case YASLTokenKindIdentifier:
			return [self asBool] ? 1 : 0;
			break;
		default:
			return [_value intValue];
	}
}

- (float) asFloat {
	switch (_kind) {
		case YASLTokenKindBool:
			return [self asBool] ? 1.f : 0;
			break;
		case YASLTokenKindInteger:
			return (float)[self asInteger];
			break;
		default:
			return [_value floatValue];
	}
}

- (BOOL) asBool {
	switch (_kind) {
		case YASLTokenKindFloat:
			return [self asFloat];
			break;
		case YASLTokenKindInteger:
			return [self asInteger];
			break;
		default:
			return [_value boolValue];
	}
}

- (NSString *) description {
	return (self.kind != YASLTokenKindString) ? self.value : [NSString stringWithFormat:@"'%@'", self.value];
}

- (id) copyWithZone:(NSZone *)zone {
	YASLToken *instance = [YASLToken token:self.value withKind:self.kind];
	instance.line = self.line;
	instance.collumn = self.collumn;
	return instance;
}

@end
