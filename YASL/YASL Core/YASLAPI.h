//
//  YASLAPI.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLAPI_h
#define YASL_YASLAPI_h


#define USECUSTOMLOGS 1

//#define VERBOSE_COMPILATION
//#define VERBOSE_SYNTAX_ERRORS
//#define VERBOSE_SYNTAX
//#define VERBOSE_ASSEMBLY

#ifdef USECUSTOMLOGS
#define NSLog NSLogShort

#endif

#define NSLogShort(format, ...) \
{\
NSMutableString *formattedString = [[NSString stringWithFormat:format, ##__VA_ARGS__] mutableCopy];\
[formattedString appendString:@"\n"];\
[(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput]\
writeData: [formattedString dataUsingEncoding: NSUTF8StringEncoding]];\
}

#define DEFAULT_CODEOFFSET (1024 * 64)

#define THREAD_POOL_SIZE 100
#define SCRIPT_POOL_SIZE 50
#define DEFAULT_CODEFRAME 1024 * 64
#define DEFAULT_THREAD_STACK_SIZE 1024 * 10
#define DEFAULT_STACK_SIZE THREAD_POOL_SIZE * DEFAULT_THREAD_STACK_SIZE
#define DEFAULT_USERMEM_SIZE (1024 * 1024 * 16)
#define DEFAULT_RAM_SIZE (DEFAULT_USERMEM_SIZE + (SCRIPT_POOL_SIZE * DEFAULT_CODEFRAME) + DEFAULT_STACK_SIZE)
#define DEFAULT_STACK_BASE DEFAULT_RAM_SIZE - DEFAULT_STACK_SIZE

#define _YASLBuiltInTypeIdentifierVoid @"void"
#define _YASLBuiltInTypeIdentifierInt @"int"
#define _YASLBuiltInTypeIdentifierFloat @"float"
#define _YASLBuiltInTypeIdentifierBool @"bool"
#define _YASLBuiltInTypeIdentifierChar @"char"
#define _YASLBuiltInTypeIdentifierString @"string"
#define _YASLAPITypeIdentifierHandle @"handle"

typedef int YASLInt;
typedef YASLInt YASLBool;
typedef float YASLFloat;
typedef unichar YASLChar;

typedef NS_ENUM(NSUInteger, YASLBuiltInType) {
	YASLBuiltInTypeVoid = 0,
	YASLBuiltInTypeUnknown = 0,
	YASLBuiltInTypeInt,
	YASLBuiltInTypeFloat,
	YASLBuiltInTypeBool,
	YASLBuiltInTypeChar,

	YASLBuiltInTypeMAX,
};

extern NSString *const YASLBuiltInTypeIdentifierUnknown;
extern NSString *const YASLBuiltInTypeIdentifierVoid;
extern NSString *const YASLBuiltInTypeIdentifierInt;
extern NSString *const YASLBuiltInTypeIdentifierFloat;
extern NSString *const YASLBuiltInTypeIdentifierBool;
extern NSString *const YASLBuiltInTypeIdentifierChar;
extern NSString *const YASLBuiltInTypeIdentifierString;

extern NSString *const YASLAPITypeHandle;

extern YASLInt YASL_INVALID_HANDLE;

extern YASLInt WEI_INFINITE;

#endif
