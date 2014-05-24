//
//  YASLCodeSource.h
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLCodeSource : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *code;

+ (instancetype) codeSource:(NSString *)identifier fromString:(NSString *)sourceString;
+ (instancetype) codeSourceFromFile:(NSURL *)sourceFile;

@end
