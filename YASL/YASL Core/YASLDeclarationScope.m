//
//  YASLDeclarationScope.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDeclarationScope.h"
#import "YASLCoreLangClasses.h"

@implementation YASLDeclarationScope {
	NSMutableDictionary *localDeclarations;
	NSMutableArray *includedDeclarations;
}

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent {
	return [[self alloc] initWithParentScope:parent];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	self.parentScope = nil;
	return self;
}

- (id)initWithParentScope:(YASLDeclarationScope *)parent {
	if (!(self = [self init]))
		return self;

	self.parentScope = parent;
	return self;
}

- (void) setParentScope:(YASLDeclarationScope *)parentScope {
	if (_parentScope == parentScope)
		return;

	_parentScope = parentScope;
	localDataTypesManager = [YASLDataTypesManager datatypesManagerWithParentManager:parentScope->localDataTypesManager];
	self.placementManager = parentScope.placementManager;
	[parentScope addChildScope:self];
}

- (void) addChildScope:(YASLDeclarationScope *)child {
	if (!_childs)
		_childs = [NSMutableArray array];
	[(NSMutableArray *)_childs addObject:child];
}

- (void) includeDeclarations:(id<YASLDeclarationScopeProtocol>)declarations {
	if (!includedDeclarations)
		includedDeclarations = [NSMutableArray array];

	[includedDeclarations addObject:declarations];
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) includedLocalDeclarationByIdentifier:(NSString *)identifier {
	for (YASLLocalDeclarations *declarations in includedDeclarations) {
    YASLLocalDeclaration *declaration = [declarations localDeclarationByIdentifier:identifier];
		if (declaration)
			return declaration;
	}
	return nil;
}

- (BOOL) isDeclaredInIncludes:(NSString *)identifier {
	for (YASLLocalDeclarations *declarations in includedDeclarations) {
    if ([declarations isDeclared:identifier inLocalScope:NO])
			return YES;
	}

	return NO;
}

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	YASLLocalDeclaration *declaration = [YASLLocalDeclaration localDeclarationWithIdentifier:identifier];
	return [self addLocalDeclaration:declaration];
}

- (YASLLocalDeclaration *) addLocalDeclaration:(YASLLocalDeclaration *)declaration {
	if (!localDeclarations)
		localDeclarations = [NSMutableDictionary dictionary];

	declaration.parentScope = self;
	declaration.index = [localDeclarations count];
	return localDeclarations[declaration.identifier] = declaration;
}

- (void) removeDeclaration:(YASLLocalDeclaration *)declaration {
	[localDeclarations removeObjectForKey:declaration.identifier];
}

- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier {
	YASLLocalDeclaration *declaration = localDeclarations[identifier];
	if ((!declaration) && self.parentScope)
		declaration = [self.parentScope localDeclarationByIdentifier:identifier];

	return declaration ? declaration : [self includedLocalDeclarationByIdentifier:identifier];
}

- (BOOL) isDeclared:(NSString *)identifier inLocalScope:(BOOL)localScope {
	YASLLocalDeclaration *declaration = [self localDeclarationByIdentifier:identifier];
	BOOL declared = declaration && ((!localScope) || (declaration.parentScope == self));
	return declared ? YES : localScope ? NO : [self isDeclaredInIncludes:identifier];
}

- (NSDictionary *) declarations {
	return localDeclarations;
}

- (NSArray *) localDeclarations {
	return localDeclarations ? [[localDeclarations allValues] sortedArrayUsingComparator:^NSComparisonResult(YASLLocalDeclaration *d1, YASLLocalDeclaration *d2) {
		NSInteger delta = (d1.index - d2.index);
		return delta ? delta / ABS(delta) : 0;
	}] : @[];
}

#pragma mark - Types manager protocol implementation

- (YASLDataType *) includedTypeByName:(NSString *)name {
	for (YASLLocalDeclarations *declarations in includedDeclarations) {
    YASLDataType *type = [declarations typeByName:name];
		if (type)
			return type;
	}
	return nil;
}

- (NSEnumerator *) enumIncludedTypes {
	NSMutableArray *types = [NSMutableArray array];
	for (YASLLocalDeclarations *declarations in includedDeclarations) {
    [types addObjectsFromArray:[[declarations enumTypes] allObjects]];
	}
	return [types objectEnumerator];
}

- (YASLDataType *) typeByName:(NSString *)name {
	YASLDataType *type = [localDataTypesManager typeByName:name];
	return type ? type : [self includedTypeByName:name];
}

- (NSEnumerator *)enumTypes {
	NSEnumerator *local = [localDataTypesManager enumTypes];
	NSEnumerator *included = [self enumIncludedTypes];
	return [[[local allObjects] arrayByAddingObjectsFromArray:[included allObjects]] objectEnumerator];
}

- (void) registerType:(YASLDataType *)type {
	[localDataTypesManager registerType:type];
}

- (id<YASLDataTypesManagerProtocol>) parentManager {
	return [localDataTypesManager parentManager];
}

#pragma mark - Declarations placement resolve

/*
 
 
 script
 
 int
 int
 
 :func
 	 param1 -12
	 param1 -8
   param2 -4
  :body
 	  retv 0
    :inner
      l1 4
      l2 8
 			l3 12
    end
	end
 end

 scope:
 	local1
 	local2
 	local3
 	
 	inner:
 		inner1
 		inner2
 
 		ininner1:
 			ininner1
 		end
 
 		ininner2:
 			ininner21
 			ininner22
 		end
 	end
 
 	scope data size = locals size + max(inners size)
 	inner offset = locals size
  locals offset = scope offset

 */

- (NSUInteger) localDeclarationsDataSize {
	NSUInteger size = 0;
	for (YASLLocalDeclaration *declaration in [localDeclarations allValues]) {
		BOOL takesSpace = ![declaration.declarator isSpecific:YASLTranslationNodeTypeFunction];
		if (takesSpace)
	    size += [declaration sizeOf];
//		else
//			NSLog(@"Zero space: %@, %d", declaration, (int)[declaration sizeOf]);
	}
	return size;
}

- (NSUInteger) scopeDataSize {
	NSUInteger local = [self localDeclarationsDataSize];
	NSUInteger child = [self childScopesDataSize];
	return local + child;
}

- (NSUInteger) childScopesDataSize {
	NSUInteger max = 0;
	for (YASLDeclarationScope *child in self.childs) {
    max = MAX(max, [child scopeDataSize]);
	}
	return max;
}

- (void) propagateReferences {
	for (YASLLocalDeclaration *declaration in [localDeclarations allValues]) {
		[declaration.reference updateReferents];
	}

	for (YASLDeclarationScope *child in self.childs) {
    [child propagateReferences];
	}
}

@end
