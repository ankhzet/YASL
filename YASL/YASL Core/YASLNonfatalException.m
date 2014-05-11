//
//  YASLTokenizerException.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLNonfatalException.h"

@implementation YASLNonfatalException

+ (instancetype) exceptionAtLine:(NSUInteger)line andCollumn:(NSUInteger)collumn withMsg:(NSString *)msg, ... {
	va_list args;
  va_start(args, msg);
	NSString *reason = [[NSString alloc] initWithFormat:msg arguments:args];
  va_end(args);

	YASLNonfatalException *instance = (id)[self exceptionWithName:NSStringFromClass(self)
																													reason:reason
																												userInfo:nil];
	instance.atLine = line;
	instance.atCollumn = collumn;
	return instance;
}

- (NSString *) description {
	NSString *def = [super description];
	NSString *token = self.atToken ? [NSString stringWithFormat:@", %@", self.atToken] : @"";
	NSString *err = [NSString stringWithFormat:@"Error at (%lu: %u%@): %@", (unsigned long)self.atLine, self.atCollumn, token, def];
	return err;
}

@end

