//
//  YASLDeclarationScope.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLDeclarationScopeProtocol.h"

@class YASLDeclarationPlacement;
@interface YASLDeclarationScope : NSObject <YASLDeclarationScopeProtocol> {
@public
	id<YASLDataTypesManagerProtocol> localDataTypesManager;
}

@property (nonatomic) NSString *name;
@property (nonatomic, weak) YASLDeclarationScope *parentScope;
@property (nonatomic) YASLDeclarationPlacement *placementManager;

/*!
 @brief Returns array of child scopes for specified scope.
 */
@property (nonatomic) NSArray *childs;

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent;
- (id)initWithParentScope:(YASLDeclarationScope *)parent;

- (NSDictionary *) declarations;

- (void) includeDeclarations:(id<YASLDeclarationScopeProtocol>)declarations;

- (NSUInteger) localDeclarationsDataSize;
- (NSUInteger) scopeDataSize;
- (NSUInteger) childScopesDataSize;

- (void) propagateReferences;

@end
