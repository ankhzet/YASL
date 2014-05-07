//
//  YASLDataType.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataType.h"
#import "YASLAPI.h"

NSString *const YASLBuiltInTypeVoid = @"void";
NSString *const YASLBuiltInTypeInt = @"int";
NSString *const YASLBuiltInTypeFloat = @"float";
NSString *const YASLBuiltInTypeBool = @"bool";
NSString *const YASLBuiltInTypeChar = @"char";



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

@end
