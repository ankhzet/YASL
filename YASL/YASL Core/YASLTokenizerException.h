//
//  YASLTokenizerException.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLTokenizerException : NSException

@property (nonatomic) NSUInteger atLine;
@property (nonatomic) NSUInteger atCollumn;

+ (instancetype) exceptionAtLine:(NSUInteger)line andCollumn:(NSUInteger)collumn withMsg:(NSString *)msg, ...;

@end

