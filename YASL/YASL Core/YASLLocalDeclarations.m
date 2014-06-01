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

#import "YASLDataTypesManager.h"

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
	globalScope->localDataTypesManager = globalTypesManager;

	self.expressionSolver = [YASLExpressionSolver solverInDeclarationScope:self];
}

- (YASLDeclarationScope *) pushScope {
	return self.currentScope = [YASLDeclarationScope scopeWithParentScope:self.currentScope];
}

- (YASLDeclarationScope *) popScope {
	if (_currentScope.parentScope != nil)
		self.currentScope = _currentScope.parentScope;

	return self.currentScope;
}

#pragma mark - DataTypesManager interface implementation

- (void) registerType:(YASLDataType *)type {
	[self.currentScope registerType:type];
}

- (YASLDataType *) typeByName:(NSString *)name {
	return [self.currentScope typeByName:name];
}

- (NSEnumerator *)enumTypes {
	return [self.currentScope enumTypes];
}

- (id<YASLDataTypesManagerProtocol>) parentManager {
	return [self.currentScope parentManager];
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) addLocalDeclaration:(YASLLocalDeclaration *)declaration {
	return [self.currentScope addLocalDeclaration:declaration];
}

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	return [self.currentScope newLocalDeclaration:identifier];
}

- (void) removeDeclaration:(YASLLocalDeclaration *)declaration {
	[self.currentScope removeDeclaration:declaration];
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
