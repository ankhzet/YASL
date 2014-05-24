//
//  YASLTranslationDeclarator.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationDeclarator.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTranslationDeclarator

- (NSString *) toString {
	NSString *pointer = [@"" stringByPaddingToLength:self.isPointer withString:@"*" startingAtIndex:0];
	NSString *specifiers = self.declaratorSpecifiers ? [self.declaratorSpecifiers componentsJoinedByString:@""] : @"";
	return [NSString stringWithFormat:@"(D:%@%@%@%@)", pointer, self.declaratorIdentifier, specifiers, [[[self nodesEnumerator:NO] allObjects] componentsJoinedByString:@" "]];
}

@end
