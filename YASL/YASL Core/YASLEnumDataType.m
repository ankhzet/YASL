//
//  YASLEnumDataType.m
//  YASL
//
//  Created by Ankh on 25.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLEnumDataType.h"
#import "YASLDataTypesManager.h"

@interface YASLEnum : NSObject {
	@public
	NSString *key;
	NSUInteger value;
	NSUInteger index;
	BOOL intermediateValue;
}

@end
@implementation YASLEnum
@end

@implementation YASLEnumDataType {
	NSMutableDictionary *enumValues;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	enumValues = [NSMutableDictionary dictionary];
	return self;
}

- (void) setManager:(YASLDataTypesManager *)manager {
	if (_manager == manager)
		return;

	_manager = manager;

	self.parent = [manager typeByName:YASLBuiltInTypeIdentifierInt];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"(enum %@)", self.name];
}

- (void) addEnum:(NSString *)identifier value:(NSUInteger)value intermediate:(BOOL)intermediate {
	YASLEnum *e = [YASLEnum new];
	e->key = identifier;
	e->value = value;
	e->intermediateValue = intermediate;
	e->index = [enumValues count];
	enumValues[identifier] = e;
	[self packValues];
}

- (void) addEnum:(NSString *)identifier value:(NSUInteger)value {
	[self addEnum:identifier value:value intermediate:YES];
}

- (void) addEnum:(NSString *)identifier {
	if ([self hasEnum:identifier])
		return;

	NSUInteger value = 0;
	while ([self hasValue:value])
		value++;

	[self addEnum:identifier value:value intermediate:NO];
}

- (BOOL) hasEnum:(NSString *)identifier {
	return !!enumValues[identifier];
}

- (NSUInteger) enumValue:(NSString *)identifier {
	YASLEnum *e = enumValues[identifier];
	return e ? e->value : 0;
}

- (NSString *) hasValue:(NSUInteger)value {
	for (YASLEnum *e in [enumValues allValues]) {
    if (e->value == value)
			return e->key;
	}

	return nil;
}

+ (YASLEnumDataType *) hasEnum:(NSString *)identifier inManager:(YASLDataTypesManager *)manager {
	while (manager) {
		for (YASLEnumDataType *dataType in [manager enumTypes]) {
			if (![dataType isKindOfClass:[YASLEnumDataType class]])
				continue;

			if ([dataType hasEnum:identifier])
				return dataType;
		}
		manager = manager.parentManager;
	}
	return nil;
}

- (void) packValues {
	NSMutableSet *values = [NSMutableSet setWithCapacity:[enumValues count]];
	NSArray *free = [NSMutableArray arrayWithCapacity:[enumValues count]];
	for (YASLEnum *e in [enumValues allValues]) {
    if (e->intermediateValue)
			[values addObject:@(e->value)];
		else
			[(NSMutableArray *)free addObject:e];
	}
	if (![free count])
		return;

	free = [free sortedArrayUsingComparator:^NSComparisonResult(YASLEnum *e1, YASLEnum *e2) {
		NSInteger delta = e1->index - e2->index;
		return delta ? delta / ABS(delta) : NSOrderedSame;
	}];
	NSUInteger value = 0;
	for (YASLEnum *e in free) {
    while ([values member:@(value)])
			value++;
		e->value = value;
		value++;
	}
}

@end
