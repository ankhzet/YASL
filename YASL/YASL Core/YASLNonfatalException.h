//
//  YASLTokenizerException.h
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YASLNonfatalException : NSException

@property (nonatomic) NSUInteger atLine;
@property (nonatomic) NSUInteger atCollumn;
@property (nonatomic) NSString *atToken;
@property (nonatomic) NSUInteger stackGUID;

+ (instancetype) exceptionAtLine:(NSUInteger)line andCollumn:(NSUInteger)collumn withMsg:(NSString *)msg, ...;

@end

