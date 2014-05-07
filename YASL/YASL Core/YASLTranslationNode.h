//
//  YASLTranslationNode.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YASLTranslationNodeType) {
	YASLTranslationNodeTypeNone = 0,

	YASLTranslationNodeTypeConstant,
	YASLTranslationNodeTypeExpression,
	YASLTranslationNodeTypeInitializer,

	YASLTranslationNodeTypeMAX
};

@interface YASLTranslationNode : NSObject

@property (nonatomic) YASLTranslationNodeType type;
@property (nonatomic) NSMutableArray *subnodes;
@property (nonatomic, weak) YASLTranslationNode *parent;

// initialization
+ (instancetype) nodeWithType:(YASLTranslationNodeType)type;
- (id)initWithType:(YASLTranslationNodeType)type;

// subnode handling
- (void) addSubNode:(YASLTranslationNode *)subnode;
- (void) removeSubNode:(YASLTranslationNode *)subnode;

- (NSString *) toString;

@end
