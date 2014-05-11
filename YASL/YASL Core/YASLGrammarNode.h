//
//  YASLGrammarNode.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLGrammarNode, YASLAssembly;
typedef BOOL (^YASLGrammarNodeWalkBlock) (id userData, YASLGrammarNode *node);

@interface YASLGrammarNode : NSObject <NSCopying>

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL discard;

/*! String node type representation. */
- (NSString *) nodeType;

- (BOOL) hasChild:(YASLGrammarNode *)child;

/*! Subnode walk. */
- (BOOL) walkTreeWithBlock:(YASLGrammarNodeWalkBlock)walkBlock andUserData:(id)userdata;

/*! Syntax-check provided tokens-match assembly with grammar. Builds out syntax tree and pushes into resulting assembly. */
- (BOOL) match:(YASLAssembly *)match andAssembly:(YASLAssembly *)assembly;

/*! Node-type relative matching. Reimplemented in subclasses. */
- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly;

+ (void) raiseMatch:(YASLAssembly *)match error:(NSString *)msg, ...;

@end

@interface YASLGrammarNode (StringRepresentation)

- (NSString *) description:(NSMutableSet *)circular;
/*! Node description, based on its type and its subnodes. As nodes can be recursively connected, this method is not recursion-safe. */
- (NSString *) unsafeDescription:(NSMutableSet *)circular;

@end
