//
//  YASLDeclarationPlacement.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLDeclarationScope.h"

typedef NS_ENUM(NSUInteger, YASLDeclarationPlacementType) {
	YASLDeclarationPlacementTypeInCode,
	YASLDeclarationPlacementTypeOnStack,
};

@class YASLLocalDeclaration;
@interface YASLDeclarationPlacement : NSObject

- (YASLDeclarationPlacementType) placementType;

- (void) calcPlacementForDeclaration:(YASLLocalDeclaration *)declaration inScopesManager:(id<YASLDeclarationScopeProtocol>)scopes;

@end
