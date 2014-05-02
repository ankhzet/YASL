//
//  NSObject+TabbedDescription.m
//  YASL
//
//  Created by Ankh on 30.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "NSObject+TabbedDescription.h"

@implementation NSObject (TabbedDescription)

- (NSString *) descriptionTabbed:(NSString *)tab {
	NSArray *lines = [[self description] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	BOOL newlined = [[lines lastObject] isEqualToString:@""];
	if (newlined) {
		lines = [lines mutableCopy];
		[(NSMutableArray *)lines removeLastObject];
	}

	NSString *result = [NSString stringWithFormat:@"%@%@", tab, [lines componentsJoinedByString:[NSString stringWithFormat:@"\n%@", tab]]];
	return newlined ? [result stringByAppendingString:@"\n"] : result;
}

+ (NSString *) progressTab:(NSString *)tab {
	return [NSString stringWithFormat:@"  %@", tab];
}

@end
