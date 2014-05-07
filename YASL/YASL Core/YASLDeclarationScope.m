//
//  YASLDeclarationScope.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDeclarationScope.h"
#import "YASLDataTypesManager.h"
#import "YASLLocalDeclaration.h"

@implementation YASLDeclarationScope {
	NSMutableDictionary *declarations;
}

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent {
	return [[self alloc] initWithParentScope:parent];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	self.parentScope = nil;
	declarations = [NSMutableDictionary dictionary];
	return self;
}

- (id)initWithParentScope:(YASLDeclarationScope *)parent {
	if (!(self = [self init]))
		return self;

	if ((self.parentScope = parent)) {
		self.localDataTypesManager = [YASLDataTypesManager datatypesManagerWithParentManager:self.parentScope.localDataTypesManager];
	}

	return self;
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	YASLLocalDeclaration *declaration = [YASLLocalDeclaration localDeclarationWithIdentifier:identifier];
	declaration.parentScope = self;
	return declarations[identifier] = declaration;
}

- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier {
	YASLLocalDeclaration *declaration = declarations[identifier];
	if ((!declaration) && self.parentScope)
		declaration = [self.parentScope localDeclarationByIdentifier:identifier];

	return declaration;
}

- (NSArray *) childScopes:(YASLDeclarationScope *)parentScope {
	return nil;
}

@end
