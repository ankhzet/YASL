//
//  YASLDeclarationScopeProtocol.h
//  YASLVM
//
//  Created by Ankh on 01.06.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLDataTypesManagerProtocol.h"

@class YASLLocalDeclaration, YASLDataType;
@protocol YASLDeclarationScopeProtocol <YASLDataTypesManagerProtocol>

/*!
 @brief Adds existing declaration to receiver scope, making it local. */
- (YASLLocalDeclaration *) addLocalDeclaration:(YASLLocalDeclaration *)declaration;

/*!
 @brief Creates new declaration with specified identifier in current scope.
 @return New declaration descriptor instance.
 */

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier;

- (void) removeDeclaration:(YASLLocalDeclaration *)declaration;

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

