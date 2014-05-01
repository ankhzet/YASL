//
//  YASLTokenizerException.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTokenizerException.h"

@implementation YASLTokenizerException

+ (instancetype) exceptionAtLine:(NSUInteger)line andCollumn:(NSUInteger)collumn withMsg:(NSString *)msg, ... {
	va_list args;
  va_start(args, msg);
	NSString *reason = [[NSString alloc] initWithFormat:msg arguments:args];
  va_end(args);

	YASLTokenizerException *instance = (id)[self exceptionWithName:NSStringFromClass(self)
																													reason:reason
																												userInfo:nil];
	instance.atLine = line;
	instance.atCollumn = collumn;
	return instance;
}

- (NSString *) description {
	NSString *def = [super description];
	NSString *pos = [NSString stringWithFormat:@"Error occured at line %u, collumn %u", self.atLine, self.atCollumn];
	return [NSString stringWithFormat:@"%@\n%@", def, pos];
}

@end

