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
	NSMutableDictionary *declarations;
}

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent {
	return [[self alloc] initWithParentScope:parent];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	self.parentScope = nil;
	_childs = [NSMutableArray array];
	declarations = [NSMutableDictionary dictionary];
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
	self.localDataTypesManager = [YASLDataTypesManager datatypesManagerWithParentManager:parentScope.localDataTypesManager];
	self.placementManager = parentScope.placementManager;
	[parentScope addChildScope:self];
}

- (void) addChildScope:(YASLDeclarationScope *)child {
	[(NSMutableArray *)_childs addObject:child];
}

#pragma mark - Declaration scope interface implementation

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier {
	YASLLocalDeclaration *declaration = [YASLLocalDeclaration localDeclarationWithIdentifier:identifier];
	declaration.parentScope = self;
	declaration.index = [declarations count];
	return declarations[identifier] = declaration;
}

- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier {
	YASLLocalDeclaration *declaration = declarations[identifier];
	if ((!declaration) && self.parentScope)
		declaration = [self.parentScope localDeclarationByIdentifier:identifier];

	return declaration;
}

- (BOOL) isDeclared:(NSString *)identifier inLocalScope:(BOOL)localScope {
	YASLLocalDeclaration *declaration = [self localDeclarationByIdentifier:identifier];
	return declaration && ((!localScope) || (declaration.parentScope == self));
}

- (NSDictionary *) declarations {
	return declarations;
}

- (NSArray *) localDeclarations {
	return [[declarations allValues] sortedArrayUsingComparator:^NSComparisonResult(YASLLocalDeclaration *d1, YASLLocalDeclaration *d2) {
		NSInteger delta = (d1.index - d2.index);
		return delta ? delta / ABS(delta) : 0;
	}];
}

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
	for (YASLLocalDeclaration *declaration in [self.declarations allValues]) {
    size += [declaration sizeOf];
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
	for (YASLLocalDeclaration *declaration in [self.declarations allValues]) {
		[declaration.reference updateReferents];
	}

	for (YASLDeclarationScope *child in self.childs) {
    [child propagateReferences];
	}
}

@end
