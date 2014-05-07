//
//  YASLDiscards.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YASLDiscards;
@protocol YASLDiscardsManagerProtocol <NSObject, NSCopying>

/*! Always ignore specified object, when pushing it onto the stack. If it was pushed before marked for discard - it will be ignored in next -[pop]. */
- (void) alwaysDiscard:(id)object inGlobalScope:(BOOL)global;
/*! Returns YES, if specified object marked for discard. */
- (BOOL) mustDiscard:(id)object;
/*! Clear all discard markers. */
- (void) noDiscards;
/*! Discard markers affects only state, when they had been made, or later. Folding will force current markers to affect any state.  */
- (YASLDiscards *) foldDiscards;
- (YASLDiscards *) dropDiscardsAfterState:(NSUInteger)stateToDrop;

@end

@interface YASLDiscards : NSObject <YASLDiscardsManagerProtocol> {
@public
	NSMutableSet *discardsSet;
	YASLDiscards *parent;
	YASLDiscards *child;
	NSUInteger state;
}

+ (instancetype) discardsForParent:(YASLDiscards *)parent andState:(NSUInteger)state;

- (YASLDiscards *) pushDiscards:(NSUInteger)pushState;
- (YASLDiscards *) popDiscards:(NSUInteger)tillState;

- (BOOL) hasDiscards;

@end
