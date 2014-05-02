//
//  AZRLogicParser.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/ParseKit.h>

typedef NSString* YASLUnifiedFileType;
extern YASLUnifiedFileType const AZRUnifiedFileTypeGrammar;

@class PKParser;

@interface YASLCommonParser : NSObject

+ (NSURL *) getUnifiedFileURL:(NSString *)fileName fileType:(YASLUnifiedFileType)type;
+ (PKParser *) parserForGrammar:(NSString *)grammar assembler:(id)assembler;

@end
