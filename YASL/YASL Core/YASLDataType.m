//
//  YASLDataType.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataType.h"
#import "YASLAPI.h"

NSString *const YASLBuiltInTypeNames[] = {
	[YASLBuiltInTypeVoid] = _YASLBuiltInTypeIdentifierVoid,
	[YASLBuiltInTypeInt] = _YASLBuiltInTypeIdentifierInt,
	[YASLBuiltInTypeFloat] = _YASLBuiltInTypeIdentifierFloat,
	[YASLBuiltInTypeBool] = _YASLBuiltInTypeIdentifierBool,
	[YASLBuiltInTypeChar] = _YASLBuiltInTypeIdentifierChar,
};

@implementation YASLDataType

+ (instancetype) typeWithName:(NSString *)name {
	return [(YASLDataType *)[self alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name {
	if (!(self = [super init]))
		return self;

	_name = name;
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"(:%@:%@)", self.parent ? self.parent.name : @"", self.name];
}

- (NSUInteger) sizeOf {
	return sizeof(YASLInt);
}

- (BOOL) isSubclassOf:(YASLDataType *)parent {
	return (self == parent) || (self.parent && ((self.parent == parent) || [self.parent isSubclassOf:parent]));
}

+ (YASLBuiltInType) typeIdentifierToBuiltInType:(NSString *)identifier {
	for (YASLBuiltInType i = YASLBuiltInTypeUnknown; i < YASLBuiltInTypeMAX; i++) {
		if ([YASLBuiltInTypeNames[i] isEqualToString:identifier])
			return i;
	}
	return YASLBuiltInTypeUnknown;
}

+ (NSString *) builtInTypeToTypeIdentifier:(YASLBuiltInType)type {
	NSString *identifier = YASLBuiltInTypeNames[type];
	return identifier ? identifier : YASLBuiltInTypeNames[YASLBuiltInTypeUnknown];
}

- (YASLBuiltInType) builtInType {
	return [YASLDataType typeIdentifierToBuiltInType:self.name];
}

- (YASLBuiltInType) baseType {
	YASLBuiltInType type = [self builtInType];
	if ((type == YASLBuiltInTypeUnknown) && self.parent) {
		type = [self.parent baseType];
	}
	return type;
}

@end
