//
//  YASLGrammarFactory.h
//  YASL
//
//  Created by Ankh on 01.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* YASLUnifiedFileType;
extern YASLUnifiedFileType const YASLUnifiedFileTypeGrammar;

@class YASLGrammarNode;
@interface YASLGrammarFactory : NSObject

/*! Grammar factory singletone. */
+ (instancetype) sharedFactory;

/*! Returns syntax tree processor for specified grammar. Loads it, if not loaded yet. */
+ (YASLGrammarNode *) loadGrammar:(NSString *)grammarName;

/*! Returns syntax tree processor, if it is already loaded. */
- (YASLGrammarNode *) getGrammar:(NSString *)grammarName;

@end
