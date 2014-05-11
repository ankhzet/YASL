//
//  YASLDeclarationPlacement.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YASLDeclarationPlacementType) {
	YASLDeclarationPlacementTypeInCode,
	YASLDeclarationPlacementTypeOnStack,
};

@class YASLLocalDeclaration, YASLDeclarationScope;
@interface YASLDeclarationPlacement : NSObject

@property (nonatomic) YASLDeclarationPlacement *chained;
@property (nonatomic) YASLDeclarationPlacementType placementType;

@property (nonatomic) BOOL offsetChildsByLocals;
@property (nonatomic) BOOL offsetByParentLocals;

+ (instancetype) placementWithType:(YASLDeclarationPlacementType)type;
- (YASLDeclarationPlacement *) chain:(YASLDeclarationPlacement *)next;

/*! All child scopes won't be ofsetted by receiver locals. */
- (YASLDeclarationPlacement *) notOfsettedChildsByLocals;
/*! Receiver will be offsetted by it's parents locals. */
- (YASLDeclarationPlacement *) ofsettedByParent;


- (void) calcPlacementForDeclaration:(YASLLocalDeclaration *)declaration;
- (void) calcPlacementForScope:(YASLDeclarationScope *)scope;
- (void) offset:(NSInteger)offset scope:(YASLDeclarationScope *)scope;

@end
