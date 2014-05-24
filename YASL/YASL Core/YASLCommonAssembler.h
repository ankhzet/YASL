//
//  YASLAssembler.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAssembly.h"

@class YASLGrammar;
@interface YASLCommonAssembler : YASLAssembly

@end

@interface YASLCommonAssembler (AssemblingAndProcessing)

- (NSString *) grammarIdentifier;

/*! Assemble tokenized source with specified grammar.
 @return Resulting assembly.
 */
- (YASLAssembly *) assembleSource:(YASLAbstractTokenizer *)tokenized withGrammar:(YASLGrammar *)grammar;
- (id) assembleSource:(NSString *)source;
- (id) assembleFile:(NSString *)fileName;

@end

@interface YASLCommonAssembler (CommonProcessors)

/*! @brief Fetch all rest elements from stack (till chunk marker) into array and push on stack in place of them. */
- (void) fetchArray:(YASLAssembly *)assembly;
- (YASLAssembly *) reverseFetch:(YASLAssembly *)assembly;

/*! @brief Pop top element and push back as boxed integer. */
- (void) pushInt:(YASLAssembly *)assembly;
/*! @brief Pop top element and push back as boxed float. */
- (void) pushFloat:(YASLAssembly *)assembly;
/*! @brief Pop top element and push back as boxed bool. */
- (void) pushBool:(YASLAssembly *)assembly;
/*! @brief Pop top element and push back as string value. */
- (void) pushString:(YASLAssembly *)assembly;

@end
