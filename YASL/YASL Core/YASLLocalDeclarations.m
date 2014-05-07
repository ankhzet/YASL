//
//  YASLLocalDeclarations.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLLocalDeclarations.h"
#import "YASLDeclarationScope.h"
#import "YASLLocalDeclaration.h"

#import "YASLDeclarationPlacement.h"
#import "YASLPlacementInCode.h"
#import "YASLPlacementOnStack.h"

@interface YASLLocalDeclarations () {
	NSMutableArray *scopes;
	NSMutableDictionary *placements;
}

@end

@implementation YASLLocalDeclarations

+ (instancetype) declarationsManagerWithDataTypesManager:(YASLDataTypesManager *)typesManager {
	return [[self alloc] initWithDataTypesManager:typesManager];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	scopes = [NSMutableArray array];
	self.globalTypesManager = nil;

	placements = [NSMutableDictionary dictionaryWithObjects:@[[YASLPlacementInCode new], [YASLPlacementOnStack new]]
																									forKeys:@[@(YASLDeclarationPlacementTypeInCode), @(YASLDeclarationPlacementTypeOnStack)]];

	return self;
}

- (id)initWithDataTypesManager:(YASLDataTypesManager *)typesManager {
	if (!(self = [self init]))
		return self;

	self.globalTypesManager = typesManager;
	return self;
}

- (void) setGlobalTypesManager:(YASLDataTypesManager *)globalTypesManager {
	if (_globalTypesManager == globalTypesManager) {
		return;
	}
	_globalTypesManager = globalTypesManager;
	YASLDeclarationScope *globalScope = [self pushScope];
	globalScope.localDataTypesManager = globalTypesManager;
}

- (YASLDeclarationScope *) pushScope {
	YASLDeclarationScope *newScope = [YASLDeclarationScope scopeWithParentScope:self.currentScope];
	[scopes addObject:newScope];

	return self.currentScope = newScope;
}

- (YASLDeclarationScope *) popScope {
	if ((self.currentScope = [scopes lastObject]) && ([scopes count] > 1)) // don't allow to pop out global scope
		[scopes removeLastObject];

	return self.currentScope;
}

- (NSArray *) childScopes:(YASLDeclarationScope *)parentScope {
	NSMutableArray *childs = [NSMutableArray array];
	for (YASLDeclarationScope *scope in scopes) {
		if (scope.parentScope == parentScope)
			[childs addObject:scope];
	}
	return childs;
}

#pragma mark - DataTypesManager interface implementation

- (void) registerType:(YASLDataType *)type {
	[self.currentScope.localDataTypesManager registerType:type];
}

- (YASLDataType *) typeByName:(NSString *)name {
	return 	[self.currentScope.localDataTypesManager typeByName:name];
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	return [self.currentScope newLocalDeclaration:identifier];
}

- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier {
	return [self.currentScope localDeclarationByIdentifier:identifier];
}

#pragma mark - Declaration placement

- (YASLDeclarationPlacement *) placementManager:(YASLDeclarationPlacementType)managerType {
	return placements[@(managerType)];
}

@end
