//
//  YASLDeclarationScope.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLLocalDeclaration, YASLDeclarationScope, YASLDataTypesManager, YASLDeclarationPlacement;
@protocol YASLDeclarationScopeProtocol <NSObject>

/*!
 @brief Creates new declaration with specified identifier in current scope.
 @return New declaration descriptor instance.
 */

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier;
/*!
 @brief Searches declaration by identifier in current scope or it's parent scopes.
 @return Finded declaration.
 */
- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier;
/*!
 @brief Searches declaration by identifier.
 @param identifier Identifier of declaration to search.
 @param localScope Search only in local scope/everywhere.
 @return If localScope is YES - returns YES if declaration declared in current scope, NO - if not declared, or declared in outer scope.
 If localScope is NO - returns YES if declared in any scope.
 */
- (BOOL) isDeclared:(NSString *)identifier inLocalScope:(BOOL)localScope;

- (NSArray *) localDeclarations;

@end

@interface YASLDeclarationScope : NSObject <YASLDeclarationScopeProtocol>

@property (nonatomic) NSString *name;
@property (nonatomic) YASLDataTypesManager *localDataTypesManager;
@property (nonatomic, weak) YASLDeclarationScope *parentScope;
@property (nonatomic) YASLDeclarationPlacement *placementManager;

/*!
 @brief Returns array of child scopes for specified scope.
 */
@property (nonatomic) NSArray *childs;

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent;
- (id)initWithParentScope:(YASLDeclarationScope *)parent;

- (NSDictionary *) declarations;

- (NSUInteger) localDeclarationsDataSize;
- (NSUInteger) scopeDataSize;
- (NSUInteger) childScopesDataSize;

- (void) propagateReferences;

@end
