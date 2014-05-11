//
//  YASLTranslationNode.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"

typedef NS_ENUM(NSUInteger, YASLTranslationNodeType) {
	YASLTranslationNodeTypeNone = 0,

	YASLTranslationNodeTypeRoot,

	YASLTranslationNodeTypeConstant,
	YASLTranslationNodeTypeExpression,
	YASLTranslationNodeTypeInitializer,
	YASLTranslationNodeTypeFunction,

	YASLTranslationNodeTypeMAX
};

@class YASLAssembly, YASLDeclarationScope;
@interface YASLTranslationNode : NSObject

@property (nonatomic) YASLTranslationNodeType type;
@property (nonatomic) NSMutableArray *subnodes;
@property (nonatomic, weak) YASLTranslationNode *parent;
@property (nonatomic, readonly) YASLDeclarationScope *declarationScope;

// initialization
+ (instancetype) nodeInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type;
- (id)initInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type;

// subnode handling
- (void) addSubNode:(YASLTranslationNode *)subnode;
- (void) removeSubNode:(YASLTranslationNode *)subnode;

- (NSString *) toString;

@end

@interface YASLTranslationNode (Assembling)

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer;

@end
