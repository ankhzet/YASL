//
//  YASLTranslationDeclarator.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationDeclarator.h"
#import "YASLCoreLangClasses.h"

@implementation YASLDeclaratorSpecifier

+ (instancetype) specifierWithType:(YASLTranslationNodeType)type param:(NSInteger)param andElems:(NSArray *)elems {
	YASLDeclaratorSpecifier *specifier = [self new];
	specifier.type = type;
	specifier.param = param;
	specifier.elements = elems;
	return specifier;
}

- (NSString *) description {
	switch (self.type) {
		case YASLTranslationNodeTypeArrayDeclarator:
			return [NSString stringWithFormat:@"[%u] = {%@}", self.param, [self.elements componentsJoinedByString:@", "]];
			break;

		case YASLTranslationNodeTypeFunction:
			return [NSString stringWithFormat:@"(%@)", [self.elements componentsJoinedByString:@", "]];
			break;

		default:
			break;
	}
	return @"<unknown declarator specifier>";
}

@end

@implementation YASLTranslationDeclarator

- (NSString *) toString {
	NSString *pointer = [@"" stringByPaddingToLength:self.isPointer withString:@"*" startingAtIndex:0];
	NSString *specifiers = self.declaratorSpecifiers ? [self.declaratorSpecifiers stackToString] : @"";
	return [NSString stringWithFormat:@"(D:%@%@%@%@)", pointer, self.declaratorIdentifier, specifiers, [[[self nodesEnumerator:NO] allObjects] componentsJoinedByString:@" "]];
}

- (void) addSpecifier:(YASLDeclaratorSpecifier *)specifier {
	if (!self.declaratorSpecifiers)
		self.declaratorSpecifiers = [YASLAssembly new];

	[self.declaratorSpecifiers push:specifier];
	self.type = specifier.type;
}

@end
