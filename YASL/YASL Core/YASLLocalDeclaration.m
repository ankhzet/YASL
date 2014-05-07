//
//  YASLLocalDeclaration.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLLocalDeclaration.h"
#import "YASLDataType.h"
#import "YASLDeclarationInitializer.h"
#import "YASLAPI.h"

@implementation YASLLocalDeclaration

+ (instancetype) localDeclarationWithIdentifier:(NSString *)identifier {
	return [[self alloc] initWithIdentifier:identifier];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	self.identifier = nil;
	self.declarationInitializer = nil;
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier {
	if (!(self = [self init]))
		return self;

	self.identifier = identifier;
	return self;
}

- (NSUInteger) sizeOf {
	if (self.dataType) {
		return [self.dataType sizeOf];
	}

	return sizeof(YASLInt);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"(%@%@%@)", self.dataType ? self.dataType : @"", self.identifier, self.declarationInitializer ? self.declarationInitializer : @"<no value>"];
}

@end
