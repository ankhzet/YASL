//
//  YASLLocalDeclarations.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLDataTypesManager.h"
#import "YASLDeclarationScope.h"
#import "YASLDeclarationPlacement.h"

@class YASLDeclarationScope, YASLDataTypesManager;
@interface YASLLocalDeclarations : NSObject <YASLDataTypesManagerProtocol, YASLDeclarationScopeProtocol>

@property (nonatomic) YASLDataTypesManager *globalTypesManager;
@property (nonatomic) YASLDeclarationScope *currentScope;

+ (instancetype) declarationsManagerWithDataTypesManager:(YASLDataTypesManager *)typesManager;

- (YASLDeclarationScope *) pushScope;
- (YASLDeclarationScope *) popScope;

- (YASLDeclarationPlacement *) placementManager:(YASLDeclarationPlacementType)managerType;

@end
