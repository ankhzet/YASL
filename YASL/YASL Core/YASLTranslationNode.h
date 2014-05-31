//
//  YASLTranslationNode.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLAPI.h"
#import "YASLExceptionStack.h"

typedef NS_ENUM(NSUInteger, YASLTranslationNodeType) {
	YASLTranslationNodeTypeNone = 0,

	YASLTranslationNodeTypeRoot,

	YASLTranslationNodeTypeExpression,
	YASLTranslationNodeTypeInitializer,
	YASLTranslationNodeTypeFunction,
	YASLTranslationNodeTypeArrayDeclarator,

	YASLTranslationNodeTypeMAX
};

@class YASLAssembly, YASLDeclarationScope, YASLDataType;
@interface YASLTranslationNode : YASLExceptionStack

@property (nonatomic) NSUInteger sourceLine;
@property (nonatomic) YASLTranslationNodeType type;
@property (nonatomic, weak) YASLTranslationNode *parent;
@property (nonatomic, readonly) YASLDeclarationScope *declarationScope;

// initialization
+ (instancetype) nodeInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type;
- (id)initInScope:(YASLDeclarationScope *)scope withType:(YASLTranslationNodeType)type;

- (YASLDataType *) typeByName:(NSString *)name;
- (NSEnumerator *) enumTypes;

@end

@interface YASLTranslationNode (SubNodesManagement)

// subnode handling
- (void) addSubNode:(YASLTranslationNode *)subnode;
- (void) removeSubNode:(YASLTranslationNode *)subnode;
- (NSUInteger) nodesCount;
- (NSEnumerator *) nodesEnumerator:(BOOL)reverse;
- (void) setSubNodes:(NSArray *)array;

/*! Returns n-th operand. If none, returns nil. */
- (id) nthOperand:(NSUInteger)idx;
/*! Sets n-th operand. If index is greater than current operands count - they will be assumed as nil. */
- (void) setNth:(NSUInteger)idx operand:(YASLTranslationNode *)operand;
- (id) leftOperand;
- (id) rigthOperand;
- (id) thirdOperand;

@end

@interface YASLTranslationNode (Debug)

- (NSString *) toString;

@end

@interface YASLTranslationNode (Assembling)

- (BOOL) unPointer:(YASLAssembly *)outAssembly;
- (void) assemble:(YASLAssembly *)assembly;
- (void) assemble:(YASLAssembly *)assembly unPointered:(BOOL)unPointered;

@end
