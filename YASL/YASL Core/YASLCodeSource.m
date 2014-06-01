//
//  YASLCodeSource.m
//  YASL
//
//  Created by Ankh on 12.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLCodeSource.h"

@implementation YASLCodeSource

+ (instancetype) codeSource:(NSString *)identifier fromString:(NSString *)sourceString {
	YASLCodeSource *src = [self new];
	src.identifier = identifier;
	src.code = sourceString;
	return src;
}

+ (instancetype) codeSourceFromFile:(NSURL *)sourceFile {
	NSString *path = [sourceFile path];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSLog(@"Source file \"%@\" not exists.", [sourceFile lastPathComponent]);
		return nil;
	}

	NSError *error = nil;
	NSString *sourceString = [NSString stringWithContentsOfURL:sourceFile encoding:NSUTF8StringEncoding error:&error];
	if (!sourceString) {
		NSLog(@"Failed to load \"%@\" source file.", [sourceFile lastPathComponent]);
		return nil;
	}

	YASLCodeSource *src = [self new];
	src.identifier = [sourceFile path];
	src.code = sourceString;
	return src;
}

- (NSString *) description {
	return self.code;
}

+ (instancetype) codeSourceFromResource:(NSString *)resource withExtension:(NSString *)extension {
	NSURL *url = [[NSBundle mainBundle] URLForResource:resource withExtension:extension];
	return [self codeSourceFromFile:url];
}

@end
