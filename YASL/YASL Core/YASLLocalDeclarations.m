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

#import "YASLExpressionSolver.h"

@interface YASLLocalDeclarations () {
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

	_globalTypesManager = nil;
	_expressionSolver = nil;

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

	self.expressionSolver = [YASLExpressionSolver solverInDeclarationScope:self];
}

- (YASLDeclarationScope *) pushScope {
	YASLDeclarationScope *newScope = [YASLDeclarationScope scopeWithParentScope:self.currentScope];
	return self.currentScope = newScope;
}

- (YASLDeclarationScope *) popScope {
	if (_currentScope.parentScope != nil)
		self.currentScope = _currentScope.parentScope;

	return self.currentScope;
}

#pragma mark - DataTypesManager interface implementation

- (void) registerType:(YASLDataType *)type {
	[self.currentScope.localDataTypesManager registerType:type];
}

- (YASLDataType *) typeByName:(NSString *)name {
	return 	[self.currentScope.localDataTypesManager typeByName:name];
}

- (NSEnumerator *)enumTypes {
	return [self.currentScope.localDataTypesManager enumTypes];
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	return [self.currentScope newLocalDeclaration:identifier];
}

- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier {
	return [self.currentScope localDeclarationByIdentifier:identifier];
}

- (BOOL) isDeclared:(NSString *)identifier inLocalScope:(BOOL)localScope {
	return [self.currentScope isDeclared:identifier inLocalScope:localScope];
}

- (NSArray *) localDeclarations {
	return [self.currentScope localDeclarations];
}

#pragma mark - Declaration placement

- (YASLDeclarationPlacement *) placementManager:(YASLDeclarationPlacementType)managerType {
	return placements[@(managerType)];
}

@end
