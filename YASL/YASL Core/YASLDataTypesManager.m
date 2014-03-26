//
//  YASLDataTypes.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataTypesManager.h"
#import "YASLDataType.h"
#import "YASLBuiltInTypeIntInstance.h"

@implementation YASLDataTypesManager {
	NSMutableDictionary *types;
}

+ (instancetype) datatypesManagerWithParentManager:(YASLDataTypesManager *)parent {
	return [[self alloc] initWithParentManager:parent];
}

- (id)initWithParentManager:(YASLDataTypesManager *)parent {
	if (!(self = [self init]))
		return self;

	self.parentManager = parent;
	return self;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	return self;
}

- (void) registerType:(YASLDataType *)type {
	if (!types)
		types = [NSMutableDictionary dictionary];

	types[type.name] = type;
	type.manager = self;
}

- (YASLDataType *) typeByName:(NSString *)name {
	YASLDataType *type = types[name];
	if ((!type) && self.parentManager)
		type = [self.parentManager typeByName:name];

	return type;
}

- (NSEnumerator *) enumTypes {
	return [[types allValues] objectEnumerator];
}

@end
