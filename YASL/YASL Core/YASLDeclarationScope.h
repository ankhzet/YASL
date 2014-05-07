//
//  YASLDeclarationScope.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLLocalDeclaration, YASLDeclarationScope, YASLDataTypesManager;
@protocol YASLDeclarationScopeProtocol <NSObject>

- (YASLLocalDeclaration *) newLocalDeclaration:(NSString *)identifier;
- (YASLLocalDeclaration *) localDeclarationByIdentifier:(NSString *)identifier;
- (NSArray *) childScopes:(YASLDeclarationScope *)parentScope;

@end

@interface YASLDeclarationScope : NSObject <YASLDeclarationScopeProtocol>

@property (nonatomic) YASLDataTypesManager *localDataTypesManager;
@property (nonatomic, weak) YASLDeclarationScope *parentScope;

+ (instancetype) scopeWithParentScope:(YASLDeclarationScope *)parent;
- (id)initWithParentScope:(YASLDeclarationScope *)parent;

@end
