//
//  YASLAssembly.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLExceptionStack.h"
#import "YASLDiscards.h"

@class YASLTokenizer;
@interface YASLAssembly : YASLExceptionStack <NSCopying> {
@public
	YASLDiscards *discards;
}

@property (nonatomic) NSMutableDictionary *userData;
@property (nonatomic) id chunkMarker;
@property (nonatomic) BOOL globalDiscards;

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

/*! @return Returns YES if there are objects in the stack. */
- (BOOL) notEmpty;
/*! @return Returns top object on the stack. */
- (id) top;

/*! Pushes object onto the stack. */
- (void) push:(id)object;
/*! Pops top object from stack. It also will be moved to assembly's 'popped' array. */
- (id) pop;
/*! If top stack object equals to `marker` - method returns nill, else - pops it out from stack, like as -[pop].  */
- (id) popTill:(id)marker;
- (id) popTillChunkMarker;
/*! Pushes back last popped object (all discarded objects in popped stack will be ignored.
 @return last popped object or nil, if no more objects.
 */
- (id) pushBack;

/*! Returns array of objects, pushed onto stack after specified object. If object not found - array of all previously popped objects returned. */
- (NSArray *) objectsAbove:(id)marker;
/*! Returns objects, that was pushed onto the stack after object `aboveMarker`, but before `beloveMarkev`. */
- (NSArray *) objectsAbove:(id)aboveMarker belove:(id)beloveMarkev;
/*! Clears stack.
 @param noPopped If NO - all objects from stack will be popped, else both stack and popped array will be cleared. */
- (void) clear:(BOOL)noPopped;
/*! Clear array of previously popped objects. */
- (void) dropPopped;

/*! 
 @brief Enumerator for stack array.
 @param reverse Enumerate in reverse order.
 */
- (NSEnumerator *) enumerator:(BOOL)reverse;

@end

@interface YASLAssembly (State)

/*! Returns current count of objects in stack. */
- (NSUInteger) pushState;
/*! Sets current count of objects in stack. If there are popped objects within limit - they will be pushed back to stack. */
- (void) popState:(NSUInteger)state;
/*! Push back all previously popped objects, except those, who propped via -[dropPopped]. */
- (void) restoreFullStack;

- (NSUInteger) total;

@end

@interface YASLAssembly (Discards) <YASLDiscardsManagerProtocol>

/*! Force receiver to discard same objects, as sourceAssembly discards. */
- (void) discardAs:(YASLAssembly *)sourceAssembly;

- (void) discardPopped:(YASLAssembly *)sourceAssembly;

- (void) pushDiscards:(NSUInteger)state;

@end

@interface YASLAssembly (StringRepresentation)

- (NSString *) stackToString;
- (NSString *) stackToStringFrom:(id)from till:(id)marker;
- (NSString *) stackToString:(BOOL)noPopped till:(id)marker;

@end
