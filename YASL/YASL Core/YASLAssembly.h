//
//  YASLAssembly.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLExceptionStack.h"

@class YASLTokenizer;
@interface YASLAssembly : YASLExceptionStack <NSCopying>

@property (nonatomic) NSMutableDictionary *userData;
@end


@interface YASLAssembly (Initialization)

/*! Push all tokens from assembly to stack in reverse order. */
- (id) initReverseAssembly:(YASLAssembly *)source;
/*! Push all tokens from array to stack. */
- (id) initWithArray:(NSArray *)source;
/*! Push all tokens from array to stack in reverse order. */
- (id) initReverseArray:(NSArray *)source;
/*! Push all tokens from tokenizer to stack in reverse order. */
- (id) initWithTokenizer:(YASLTokenizer *)tokenizer;

/*! Push all tokens from tokenizer to new assembly in reverse order. */
+ (YASLAssembly *) assembleTokens:(YASLTokenizer *)tokenizer;

@end

@interface YASLAssembly (Stack)

- (BOOL) notEmpty;
- (id) top;

- (void) push:(id)object;
- (id) pop;

- (NSUInteger) pushState;
- (void) popState:(NSUInteger)state;
- (void) restoreFullStack;

- (NSArray *) objectsAbove:(id)marker;
- (NSArray *) objectsAbove:(id)aboveMarker belove:(id)beloveMarkev;
- (void) clear:(BOOL)noPopped;
- (void) discardPopped;

- (NSEnumerator *) enumerator:(BOOL)reverse;

@end

@interface YASLAssembly (StringRepresentation)

- (NSString *) stackToString;
- (NSString *) stackToStringFrom:(id)from till:(id)marker;
- (NSString *) stackToString:(BOOL)noPopped till:(id)marker;

@end
