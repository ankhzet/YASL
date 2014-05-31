//
//  YASLStructDataType.m
//  YASLVM
//
//  Created by Ankh on 31.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLStructDataType.h"

@interface YASLStructProperty : NSObject {
	@public
	NSString *identifier;
	YASLDataType *type;
	NSUInteger index;
}

@end

@implementation YASLStructProperty

@end

@implementation YASLStructDataType {
	NSMutableDictionary *properties;
}

- (NSUInteger) sizeOf {
	NSUInteger size = 0;
	for (YASLStructProperty *property in [properties allValues]) {
    size += [property->type sizeOf];
	}
	return size;
}

- (NSUInteger) propertyOffset:(NSString *)identifier {
	NSArray *props = [[properties allValues] sortedArrayUsingComparator:^NSComparisonResult(YASLStructProperty *p1, YASLStructProperty *p2) {
		NSInteger delta = p1->index - p2->index;
		return delta ? delta / ABS(delta) : NSOrderedSame;
	}];

	NSUInteger size = 0;
	for (YASLStructProperty *property in props)
		if ([property->identifier isEqualToString:identifier])
			break;
		else
	    size += [property->type sizeOf];

	return size;
}

- (BOOL) addProperty:(NSString *)identifier withType:(YASLDataType *)type {
	YASLStructProperty *property = properties[identifier];
	if (property)
		property->type = type;
	else {
		property = [YASLStructProperty new];
		property->identifier = identifier;
		property->type = type;
		property->index = [properties count];

		if (!properties)
			properties = [NSMutableDictionary dictionary];

		properties[identifier] = property;
		return NO;
	}

	return YES;
}

- (BOOL) hasProperty:(NSString *)identifier {
	return !!properties[identifier];
}

- (YASLDataType *) propertyType:(NSString *)identifier {
	YASLStructProperty *property = properties[identifier];
	return property ? property->type : nil;
}

@end
