//
//  YASLDeclarationPlacement.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDeclarationPlacement.h"
#import "YASLLocalDeclaration.h"

@implementation YASLDeclarationPlacement {
	NSMutableDictionary *scopedPlacements;
}

- (YASLDeclarationPlacementType) placementType {
	return YASLDeclarationPlacementTypeInCode;
}

/*! Calculates adress for specified declaration, based on space, tooked by another declarations in same scope.
 */
- (void) calcPlacementForDeclaration:(YASLLocalDeclaration *)declaration inScopesManager:(id<YASLDeclarationScopeProtocol>)scopes{
	// calc space, tooked by declarations in child scopes, and use it as new offset
	NSUInteger busy = [self spaceByScope:declaration.parentScope insScopeManager:scopes];
	declaration.declarationOffset = busy;

	// remember declaration for this scope
	NSMutableArray *declarations = [self declarationsInScope:declaration.parentScope];
	[declarations addObject:declaration];
}

- (NSUInteger) spaceByScope:(YASLDeclarationScope *)scope insScopeManager:(id<YASLDeclarationScopeProtocol>)scopes {
	NSUInteger busy = 0;
	NSArray *childScopes = [scopes childScopes:scope];
	for (YASLDeclarationScope *child in childScopes) {
    busy += [self spaceByScope:child insScopeManager:scopes];
	}
	NSArray *declarations = [self declarationsInScope:scope];
	if (![declarations count]) {
		return busy;
	}

	for (YASLLocalDeclaration *declaration in declarations) {
    busy += [declaration sizeOf];
	}

	return busy;
}

- (NSMutableArray *) declarationsInScope:(YASLDeclarationScope *)scope {
	NSValue *scopeHash = [NSValue valueWithPointer:&scope];
	NSMutableArray *declarations = scopedPlacements[scopeHash];
	if (!declarations) {
		declarations = scopedPlacements[scopeHash] = [NSMutableArray array];
	}
	return declarations;
}

@end
