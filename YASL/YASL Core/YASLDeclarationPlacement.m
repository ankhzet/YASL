//
//  YASLDeclarationPlacement.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDeclarationPlacement.h"
#import "YASLCoreLangClasses.h"

@implementation YASLDeclarationPlacement

+ (instancetype) placementWithType:(YASLDeclarationPlacementType)type {
	YASLDeclarationPlacement *placement = [self new];
	placement.placementType = type;
	placement.offsetChildsByLocals = YES;
	return placement;
}

- (YASLDeclarationPlacement *) chain:(YASLDeclarationPlacement *)next {
	self.chained = next;
	return next;
}

- (YASLDeclarationPlacement *) notOfsettedChildsByLocals {
	self.offsetChildsByLocals = NO;
	return self;
}

- (YASLDeclarationPlacement *) ofsettedByParent {
	self.offsetByParentLocals = YES;
	return self;
}


/*! Calculates adress for specified declaration, based on space, tooked by another declarations in same scope.
 */
- (void) calcPlacementForDeclaration:(YASLLocalDeclaration *)declaration {
	// calc space, tooked by declarations in child scopes, and use it as new offset
	NSUInteger busy = 0;//[self spaceByScope:declaration.parentScope withLocalDeclarations:NO];
	for (YASLLocalDeclaration *other in [declaration.parentScope localDeclarations]) {
    if (other.index >= declaration.index)
			continue;
		busy += [other sizeOf];
	}
	declaration.reference.address = busy;
}

- (NSUInteger) spaceByScope:(YASLDeclarationScope *)scope withLocalDeclarations:(BOOL)withDeclarations {
	NSUInteger busy, max = 0;

	for (YASLDeclarationScope *child in scope.childs) {
    max = MAX(max, [self spaceByScope:child withLocalDeclarations:YES]);
	}
	busy = max;

	if (withDeclarations) {
		NSArray *declarations = [scope localDeclarations];
		if (![declarations count]) {
			return busy;
		}

		for (YASLLocalDeclaration *declaration in declarations) {
			busy += [declaration sizeOf];
		}
	}

	return busy;
}

- (void) calcPlacementForScope:(YASLDeclarationScope *)scope {
	for (YASLLocalDeclaration *local in [scope.declarations allValues]) {
    [self calcPlacementForDeclaration:local];
	}

	NSUInteger locals = [scope localDeclarationsDataSize];
	for (YASLDeclarationScope *child in scope.childs) {
		[child.placementManager calcPlacementForScope:child];
		if (self.offsetChildsByLocals) {
			[child.placementManager offset:locals scope:child];
		}
	}

	[self.chained calcPlacementForScope:scope];
}

- (void) offset:(NSInteger)offset scope:(YASLDeclarationScope *)scope {
	if (self.offsetByParentLocals) {
		for (YASLLocalDeclaration *declaration in [scope.declarations allValues]) {
			declaration.reference.address += offset;
		}
		for (YASLDeclarationScope *child in scope.childs) {
			[child.placementManager offset:offset scope:child];
		}
	}

	[self.chained offset:offset scope:scope];
}

@end
